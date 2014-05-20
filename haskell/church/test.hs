{-# LANGUAGE FlexibleContexts #-}

module Main where

import Test.SmallCheck
import Test.SmallCheck.Series

import Types

testNat :: IO ()
testNat = smallCheck 100 $ \(NonNegative n) -> n == (from . to) n
  where
    to :: Int -> ChurchNat
    to = toChurch
    from :: ChurchNat -> Int
    from = fromChurch

testList :: IO ()
testList = smallCheck 5 $ \xs -> xs == (from . to) xs
  where
    to :: [Int] -> ChurchList Int
    to = toChurch
    from :: ChurchList Int -> [Int]
    from = fromChurch
