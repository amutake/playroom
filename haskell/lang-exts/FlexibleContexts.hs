{-# LANGUAGE FlexibleContexts, FlexibleInstances, MultiParamTypeClasses #-}

module FlexibleContexts where

class (Show a, Show b) => FC a b
instance (Show a, Show b) => FC a b

fc :: FC a b => a -> String
fc a = show a
