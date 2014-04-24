module Main where

import Control.Monad
import Data.Attoparsec
import qualified Data.ByteString as B

import Parsers
import Util

main :: IO ()
main = do
    paths <- getFiles
    forM_ paths $ \path -> do
      bs <- B.readFile $ "jypes/" ++ path
      parseTest parseDecls bs
