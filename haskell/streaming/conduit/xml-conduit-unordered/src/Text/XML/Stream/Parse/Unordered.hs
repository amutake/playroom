module Text.XML.Stream.Parse.Unordered
  ( SimpleXML (..)
  , tagUnordered
  , withParser
  , withParserM
  , withItems
  , contentText
  ) where

import Control.Applicative
import Control.Monad
import Control.Monad.Trans
import Data.Char
import Data.Conduit
import qualified Data.Conduit.List as CL
import Data.Maybe
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Traversable as TR
import Data.XML.Types
import Text.XML.Stream.Parse

import Data.HashMap.Lazy (HashMap)
import qualified Data.HashMap.Lazy as HM

import Debug.Trace
tr :: Show a => a -> a
tr a = traceShow a a


data SimpleXML = Map (HashMap Text [SimpleXML])
               | Content Text
               deriving (Show)

tagUnordered :: MonadThrow m
          => Text
          -> (SimpleXML -> m a)
          -> ConduitM Event o m (Maybe a)
tagUnordered name conv = do
  e <- dropWS
  case e of
    Just EventBeginElement{} -> do
      xmlm <- getXML
      case xmlm of
        Just xml -> lift $ liftM Just $ withParser xml name conv
        Nothing -> return Nothing
    _ -> return Nothing

getXML :: MonadThrow m
       => ConduitM Event o m (Maybe SimpleXML)
getXML = do
  e <- dropWS
  case e of
    Just (EventBeginElement name _) -> do
      CL.drop 1
      xmls <- getXMLList
      let xml = Map $ HM.singleton (nameLocalName name) $ case xmls of
            [Content _] -> xmls
            _ -> [Map $ foldr (HM.unionWith (++) . toHMap) HM.empty xmls]
      e' <- dropWS
      case e' of
        Just (EventEndElement name')
          | name == name' -> CL.drop 1 >> return (Just xml)
        _ -> lift $ monadThrow $ XmlException ("Expected end tag: " ++ show name) e'
    Just (EventContent (ContentText t)) -> CL.drop 1 >> return (Just $ Content t)
    _ -> return Nothing
  where
    getXMLList = do
      e <- dropWS
      case e of
        Just EventEndElement{} -> return []
        _ -> do
          xml <- getXML
          case xml of
            Just xml' -> (xml' :) <$> getXMLList
            Nothing -> return []
    toHMap (Map hmap) = hmap
    toHMap _ = error "toHMap: invalid structure"

dropWS :: Monad m => ConduitM Event o m (Maybe Event)
dropWS = do -- drop white space
  e <- CL.peek
  if isWS e then CL.drop 1 >> dropWS else return e
  where
    isWS e = case e of -- is white space
      Just EventBeginDocument -> True
      Just EventEndDocument -> True
      Just EventBeginDoctype{} -> True
      Just EventEndDoctype -> True
      Just EventInstruction{} -> True
      Just EventBeginElement{} -> False
      Just EventEndElement{} -> False
      Just (EventContent (ContentText t))
        | T.all isSpace t -> True
        | otherwise -> False
      Just (EventContent ContentEntity{}) -> False
      Just EventComment{} -> True
      Just EventCDATA{} -> False
      Nothing -> False

-- (.:) :: FromXML a => SimpleXML ->

withParser :: MonadThrow m
           => SimpleXML
           -> Text -- ^ element name
           -> (SimpleXML -> m a) -- ^ parser
           -> m a
withParser (Map hmap) name parse =
  case HM.lookup name hmap >>= listToMaybe of
    Just xml -> parse xml
    Nothing -> monadThrow $ XmlException ("withParser: " ++ show name ++ " not found") Nothing
withParser (Content _) _ _ = monadThrow $ XmlException "withParser: unexpected content" Nothing

withParserM :: MonadThrow m
            => SimpleXML
            -> Text
            -> (SimpleXML -> m a)
            -> m (Maybe a)
withParserM (Map hmap) name parse =
  case HM.lookup name hmap >>= listToMaybe of
    Just xml -> liftM Just $ parse xml
    Nothing -> return Nothing
withParserM (Content _) _ _ = return Nothing

withItems :: MonadThrow m
          => SimpleXML
          -> Text -- ^ element name of item list
          -> Text -- ^ element name of item
          -> (SimpleXML -> m a) -- ^ item parser
          -> m [a]
withItems (Map hmap) set item parse =
  case HM.lookup set hmap >>= listToMaybe of
    Just (Map hmap') -> case HM.lookup item hmap' of
      Just xmls -> mapM parse xmls
      Nothing -> return []
    Just (Content _) -> monadThrow $ XmlException "withItems: unexpected content" Nothing
    Nothing -> monadThrow $ XmlException "withItems: item set not exist" Nothing
withItems (Content _) _ _ _ = monadThrow $ XmlException "withItems" Nothing -- TODO

contentText :: MonadThrow m => SimpleXML -> m Text
contentText (Map hmap) = monadThrow $ XmlException "contentText: expected content" Nothing -- TODO
contentText (Content t) = return t
