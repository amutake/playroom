{-# LANGUAGE FlexibleContexts #-}

module Main where

import Control.Monad.Reader

intstr :: (MonadReader Int m, MonadReader String m) => m (Int, String)
intstr = do
    n <- ask
    str <- ask
    return (n * 2, reverse str)
