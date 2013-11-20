{-# LANGUAGE OverloadedStrings #-}
import Control.Applicative ((<$>))
import Control.Monad.Trans.Resource
import Data.Conduit (($$), ConduitM)
import Data.String
import Data.Text (Text, unpack)
import Data.XML.Types (Event)
import System.Environment
import Text.XML.Stream.Parse

data Item = Item
    { itemName :: Text
    , itemPrice :: Maybe Int
    , itemQuantity :: Int
    } deriving Show

parseItem :: ConduitM Event o (ResourceT IO) (Maybe Item)
parseItem = tagNoAttr "item" $ do
  Just name <- tagNoAttr "name" content
  price <- fmap (read . unpack) <$> tagNoAttr "price" content
  Just quantity <- fmap (read . unpack) <$> tagNoAttr "quantity" content
  return $ Item name price quantity

parseItems :: ConduitM Event o (ResourceT IO) (Maybe [Item])
parseItems = tagNoAttr "items" $ many parseItem

main :: IO ()
main = do
  path : [] <- getArgs
  items <- runResourceT $
    parseFile def (fromString path) $$ force "items required" parseItems
  print items
