{-# LANGUAGE OverloadedStrings #-}

module Tag where

import Control.Applicative
import Control.Monad
import Control.Monad.Trans
import Data.Char
import Data.Conduit
import Data.Maybe
import qualified Data.Conduit.List as CL
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Traversable as TR
import Data.XML.Types
import Text.XML.Stream.Parse

import Data.HashMap.Lazy (HashMap)
import qualified Data.HashMap.Lazy as HM

import Cloud.AWS.Lib.FromText

import Debug.Trace

data SimpleXML = Map (HashMap Text [SimpleXML])
               | Content Text
               deriving (Show)

tagChoice :: (MonadThrow m)
          => Text
          -> (SimpleXML -> Maybe a)
          -> ConduitM Event o m (Maybe a)
tagChoice name conv = do
  e <- dropWS
  case e of
    Just EventBeginElement{} -> do
      Just (Map hmap) <- getXML
      let xml = head <$> HM.lookup name hmap
      return $ xml >>= conv
    _ -> return Nothing

getXML :: (MonadThrow m)
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
