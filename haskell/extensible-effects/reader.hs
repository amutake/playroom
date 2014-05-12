{-# LANGUAGE FlexibleContexts #-}

module Main where

import Control.Eff
import Control.Eff.Reader.Lazy

intstr :: (Member (Reader Int) r, Member (Reader String) r) => Eff r String
intstr = do
    n <- ask
    str <- ask
    return $ show (n :: Int) ++ (str :: String)
