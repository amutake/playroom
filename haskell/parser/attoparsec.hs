module Main where

import Data.Attoparsec
import qualified Data.ByteString as B

import Parsers

main :: IO ()
main = do
    bs <- B.readFile "jypes/1.jype"
    parseTest parseDecls bs
