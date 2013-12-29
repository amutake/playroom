{-# LANGUAGE MonadComprehensions #-}

import Data.Maybe
import Data.Monoid

fizzbuzz :: Int -> String
fizzbuzz n = fromMaybe (show n) $
  [ "Fizz" | n `mod` 3 == 0 ] <>
  [ "Buzz" | n `mod` 5 == 0 ]

main :: IO ()
main = mapM_ (putStrLn . fizzbuzz) [1..100]
