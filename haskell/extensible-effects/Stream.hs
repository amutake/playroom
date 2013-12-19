{-# LANGUAGE FlexibleContexts
  , RankNTypes
  , TypeOperators
  , DeriveDataTypeable
  , DeriveFunctor
  , MultiParamTypeClasses
  , FlexibleInstances
  , KindSignatures
  , TypeFamilies
  #-}

module Stream where

import Control.Applicative
import Data.Typeable

import Control.Eff

-- http://d.hatena.ne.jp/hiratara/20131029/1383053821

data Await i v = Await (i -> v) v deriving (Typeable, Functor)
data Yield o v = Yield o v | Done v deriving (Typeable, Functor)

await :: (Typeable i, Member (Await i) r) => Eff r (Maybe i)
await = send $ \f -> inj $ Await (f . Just) $ f Nothing

yield :: (Typeable o, Member (Yield o) r) => o -> Eff r ()
yield o = send $ \f -> inj $ Yield o (f ())

produce :: (Typeable o, Member (Yield o) r) => [o] -> Eff r ()
produce = mapM_ yield

consume :: (Typeable i, Member (Await i) r) => Eff r [i]
consume = await >>= maybe (return []) (\i -> (i :) <$> consume)

awaitForever :: (Typeable i, Member (Await i) r) => (i -> Eff r ()) -> Eff r ()
awaitForever f = await >>= maybe (return ()) (\i -> f i >> awaitForever f)

mapS :: (Typeable i, Typeable o, Member (Await i) r, Member (Yield o) r)
     => (i -> o) -> Eff r ()
mapS f = awaitForever $ \i -> yield (f i)

type family Uni r1 r2
type instance Uni () r2 = r2
type instance Uni (t :> r1) r2 = t :> (Uni r1 r2)

infixl 8 |==|
(|==|) :: Typeable x
       => Eff (Yield x :> r1) ()
       -> Eff (Await x :> r2) v
       -> Eff (Uni r1 r2) v
m1 |==| m2 = loop (admin m1) (admin m2)
  where
    loop _ (Val v) = return v
    loop v@(Val _) (E u) = case decomp u of
      Left u' -> send (<$> unsafeReUnion u') >>= loop v
      Right (Await _ stop) -> loop v stop
    loop (E u1) (E u2) = case decomp u2 of
      Left u2' -> send (<$> unsafeReUnion u2') >>= loop (E u1)
      Right (Await next stop) -> case decomp u1 of
        Left u1' -> send (<$> unsafeReUnion u1') >>= flip loop stop
        Right (Yield x v) -> loop v (next x)
        Right (Done v) -> loop v stop
