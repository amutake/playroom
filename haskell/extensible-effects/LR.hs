{-# LANGUAGE FlexibleContexts
  , DeriveDataTypeable
  , DeriveFunctor
  , TypeOperators
  , RankNTypes
  #-}
module LR where

import Data.Typeable

import Control.Eff

data LR l r = L l | R (l -> r)  deriving (Typeable, Functor)

left :: (Typeable l, Member (LR l) r) => l -> Eff r ()
left l = send $ const $ inj $ L l

right :: (Typeable l, Member (LR l) r) => Eff r l
right = send $ inj . R

runLR :: (Typeable l) => Eff (LR l :> r) v -> Eff r v
runLR m = loop (admin m)
  where
    loop (Val v) = return v
    loop (E u) = handleRelay u loop $ \lr -> case lr of
      L l -> loop $ case cast l of
        Nothing -> error "err l"
        Just x -> x
      R r -> loop $ case cast r of
        Nothing -> error "err r"
        Just x -> x
