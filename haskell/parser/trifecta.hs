module Main where

import Text.Trifecta

import Parsers

main :: IO ()
main = do
    result <- parseFromFile parseDecls "jypes/1.jype"
    print result
