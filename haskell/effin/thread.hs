{-# LANGUAGE FlexibleContexts, ConstraintKinds, GADTs #-}

module Main where

import Control.Effect

go :: (EffectState Int es, EffectLift IO es) => Effect es ()
go = do
    n <- state $ \n -> (n, n + 1)
    lift $ print n

main :: IO ()
main = do
    runLift $ evalState 0 $ runSync $ do
        fork go
        fork go
        go
