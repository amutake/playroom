module Main where

import Test.SmallCheck
import Test.SmallCheck.Series

import Types

testNat :: IO ()
testNat = smallCheck 100 $ \(Positive n) -> n == (nat2int . int2nat) n
