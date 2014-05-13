{-# LANGUAGE TypeFamilies
  , TypeOperators
  , DataKinds
  , ConstraintKinds
  , DeriveFunctor
  , FlexibleContexts
  #-}

module Hoge where

import Control.Monad.Effect

data Hoge s v = Hoge (s -> s) (s -> v) deriving (Functor)

type EffectHoge s es = (Member (Hoge s) es, s ~ HogeType es)

type family HogeType es where
    HogeType (Hoge s ': es) = s
    HogeType (e ': es) = HogeType es

hoge :: (EffectHoge s es) => (s -> s) -> Effect es s
hoge f = send $ Hoge f f

fuga :: (EffectHoge s es) => (s -> v) -> Effect es v
fuga f = send $ Hoge id f

runHoge :: Effect (Hoge s ': es) v
        -> Effect es v
runHoge
