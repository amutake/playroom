module Main where

import Text.Parsec.String

import Parsers

main :: IO ()
main = do
    result <- parseFromFile parseDecls "jypes/1.jype"
    print result
