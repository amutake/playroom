{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Conduit
import Data.String
import Data.XML.Types
import Control.Applicative
import Control.Monad
import System.Environment
import Text.XML.Stream.Parse

import Cloud.AWS.Lib.FromText
import Text.XML.Stream.Parse.Unordered

import Debug.Trace
tr :: Show a => a -> a
tr a = traceShow a a

data Hoge = Hoge
  { hogeId :: Int
  , hogeFugaSet :: [Fuga]
  } deriving (Show)

data Fuga = Fuga
  { fugaName :: Text
  , fugaDesc :: Text
  , fugaFoo :: Maybe Foo
  } deriving (Show)

data Foo = Foo
  { fooBar :: Text
  } deriving (Show)

value :: (MonadThrow m, FromText a) => SimpleXML -> m a
value = contentText >=> fromText

hoge :: (MonadThrow m, Applicative m) => SimpleXML -> m Hoge
hoge xml = Hoge
  <$> withParser xml "id" value
  <*> withItems xml "fugaSet" "fuga" fuga

fuga :: (MonadThrow m, Applicative m) => SimpleXML -> m Fuga
fuga xml = Fuga
  <$> withParser xml "name" contentText
  <*> withParser xml "desc" contentText
  <*> withParserM xml "foo" foo

foo :: (MonadThrow m, Applicative m) => SimpleXML -> m Foo
foo xml = Foo
  <$> withParser xml "bar" contentText

hogeTag :: (MonadThrow m, Applicative m) => ConduitM Event o m (Maybe Hoge)
hogeTag = tagUnordered "hoge" hoge

main :: IO ()
main = do
  path : [] <- getArgs
  hoge <- runResourceT $
    parseFile def (fromString path) $$ force "hoge required" hogeTag
  print hoge
