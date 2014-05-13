{-# LANGUAGE DeriveFunctor
  , ConstraintKinds
  , DataKinds
  , FlexibleContexts
  , TypeOperators
  , TypeFamilies
  #-}

module Lower where

import Control.Monad.Effect
import Control.Comonad

data Lower w a = Lower (w a) deriving (Functor)

type EffectLower w es = (Member (Lower w) es, w ~ LowerType es, Comonad w)

type family LowerType es where
    LowerType (Lower w ': es) = w
    LowerType (e ': es) = LowerType es

lower :: (EffectLower w es) => w a -> Effect es a
lower = send . Lower

runLower :: Comonad w
         => Effect (Lower w ': es) a
         -> Effect es a
runLower = handle return handler
  where
    handler = eliminate trans defaultRelay
    trans (Lower w) = extract w
