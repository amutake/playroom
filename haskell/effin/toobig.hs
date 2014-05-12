{-# LANGUAGE FlexibleContexts, ConstraintKinds, GADTs #-}

module Main where

import Control.Effect

newtype TooBig = TooBig Int deriving (Show)

ex2 :: (EffectException TooBig es) => Effect es Int -> Effect es Int
ex2 m = do
    v <- m
    if v > 5 then raise (TooBig v) else return v

exRec :: (EffectException TooBig es) => Effect es Int -> Effect es Int
exRec m = except m handler
  where
    handler (TooBig n) | n <= 7 = return n
    handler e = raise e

main :: IO ()
main = do
    print $ runEffect $ runException $ runList $ exRec $ ex2 $ choose [1..9]
    print $ runEffect $ runList $ runException $ exRec $ ex2 $ choose [1..9]

    print $ runEffect $ runException $ runList $ exRec $ ex2 $ choose [5,7,1]
    print $ runEffect $ runList $ runException $ exRec $ ex2 $ choose [5,7,1]
