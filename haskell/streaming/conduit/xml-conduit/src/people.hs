{-# LANGUAGE OverloadedStrings #-}
import Control.Monad.Trans.Resource
import Data.Conduit (($$), ConduitM)
import Data.String
import Data.Text (Text, unpack)
import Data.XML.Types (Event)
import System.Environment
import Text.XML.Stream.Parse

data Person = Person Int Text deriving Show

parsePerson :: ConduitM Event o (ResourceT IO) (Maybe Person)
parsePerson = tagName "person" (requireAttr "age") $ \age -> do
  name <- content
  return $ Person (read $ unpack age) name

parsePeople :: ConduitM Event o (ResourceT IO) (Maybe [Person])
parsePeople = tagNoAttr "people" $ many parsePerson

main :: IO ()
main = do
  path : [] <- getArgs
  people <- runResourceT $
    parseFile def (fromString path) $$ force "people required" parsePeople
  print people
