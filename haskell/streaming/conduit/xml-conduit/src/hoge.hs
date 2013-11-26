{-# LANGUAGE OverloadedStrings #-}

import Cloud.AWS.Lib.FromText
import Control.Applicative
import Control.Monad
import Data.Conduit
import qualified Data.HashMap.Lazy as HM
import Data.Maybe
import Data.String
import Data.Text (Text)
import qualified Data.Traversable as TR
import Data.XML.Types
import Text.XML.Stream.Parse
import System.Environment

import Tag

import Debug.Trace

data Hoge = Hoge { hogeId :: Int, itemSet :: [Item] } deriving (Show)
data Item = Item { a :: Text, b :: Text, c :: Maybe C } deriving (Show)
data C = C { c1 :: Text } deriving (Show)

tr :: Show a => a -> a
tr a = traceShow a a

textConv :: SimpleXML -> Text
textConv (Content t) = t
textConv _ = error "textConv"

hogeConv :: SimpleXML -> Maybe Hoge
hogeConv (Map hmap) = Hoge
  <$> (HM.lookup "id" hmap >>= fromText . textConv . head)
  <*> (HM.lookup "itemSet" hmap >>= itemSetConv . head)

itemSetConv :: SimpleXML -> Maybe [Item]
itemSetConv (Map hmap) = xmls >>= TR.traverse itemConv
  where
    xmls = HM.lookup "item" hmap

itemConv :: SimpleXML -> Maybe Item
itemConv (Map hmap) = Item
  <$> (textConv <$> join (listToMaybe <$> HM.lookup "a" hmap))
  <*> (textConv <$> join (listToMaybe <$> HM.lookup "b" hmap))
  <*> TR.sequenceA (cConv <$> join (listToMaybe <$> HM.lookup "c" hmap))

cConv :: SimpleXML -> Maybe C
cConv (Map hmap) = C
  <$> (textConv . head <$> HM.lookup "c1" hmap)

hogeTag :: (MonadThrow m) => ConduitM Event o m (Maybe Hoge)
hogeTag = tagChoice "hoge" hogeConv

main :: IO ()
main = do
  path : [] <- getArgs
  hoge <- runResourceT $
    parseFile def (fromString path) $$ force "hoge required" hogeTag
  print hoge




{-

<hogeSet>
  <item>
    <a>a</a>
    <b>b</b>
  </item>
  <item>
    <b>b</b>
    <a>a</a>
  </item>
  <item>
    <a>a</a>
    <b>b</b>
    <c>
      <c1>c1</c1>
    </c>
  </item>
</hogeSet>


hogeSet
|-- item
|   |-- a - a
|   `-- b - b
`-- item
    |-- b - b
    `-- a - a


Map [ (hogeSet, [ Map [ (item, [ Map [ (a, a)
                                     , (b, b)
                                     ]
                               , Map [ (b, b)
                                     , (a, a)
                                     ]
                               , Map [ (a, a)
                                     , (b, b)
                                     , (c, Map [ (c1, c1)
                                               ])
                                     ]
                               ])]])]

Map (HM.fromList [ (hogeSet, [ Map (HM.fromList [ (item, [ Map (HM.fromList [ (

-}

-- getXML (<a>a</a>) == Map (HM.fromList [(a, [Content a])])
-- getXML (<b>b</b>) == Map (HM.fromList [(b, [Content b])])
-- getXML (<c><c1>c1</c1>) == Map (HM.fromList [(c, [Map (HM.fromList [(c1, Content c1)])])])

-- getSubXML (<a>...</c>) == Map (HM.fromList [ (a, [Content a])
--                                            , (b, [Content b])
--                                            , (c, [Map (HM.fromList [(c1, [Content c1])])])
--                                            ])
