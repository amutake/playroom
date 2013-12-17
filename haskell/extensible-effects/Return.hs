{-# LANGUAGE FlexibleContexts
  , DeriveDataTypeable
  , DeriveFunctor
  , TypeOperators
  #-}

module Return where

import Data.Typeable

import Control.Eff
import Control.Eff.Trace

data Return a v = Return a (a -> v) deriving (Typeable, Functor)

returnE :: (Typeable a, Member (Return a) r) => a -> Eff r a
returnE a = send $ \f -> inj . Return a $ const $ f a

hoge :: (Typeable a, Member (Return a) r) => a -> Eff r a
hoge a = send $ inj . Return a

runReturn :: (Typeable a) => Eff (Return a :> r) v -> Eff r v
runReturn m = loop (admin m)
  where
    loop (Val v) = return v
    loop (E u) = handleRelay u loop $ \(Return a f) -> loop $ f a

test :: (Member (Return Int) r, Member Trace r) => Eff r ()
test = do
  trace $ show (0 :: Int)
  n <- returnE (0 :: Int)
  trace $ show n
  n' <- returnE n
  trace $ show n'

testmain :: IO ()
testmain = runTrace $ runReturn (test :: Eff (Return Int :> Trace :> ()) ())
