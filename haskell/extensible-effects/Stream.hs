{-# LANGUAGE FlexibleContexts
  , RankNTypes
  , TypeOperators
  , DeriveDataTypeable
  , DeriveFunctor
  , ImpredicativeTypes
  , GADTs
  , ExistentialQuantification
  , PolymorphicComponents
  , LiberalTypeSynonyms
  , ScopedTypeVariables
  #-}

module Stream where

import Control.Applicative
import Data.Typeable

import Control.Eff
import Data.Void

-- source :==: a :==: b :==: sink

-- http://d.hatena.ne.jp/hiratara/20131029/1383053821

data Stop = Stop
data Await i v = Await (i -> Either Stop (Await i v)) (Stop -> v)
data Yield o v = Yield o (Either Stop (Yield o v))

-- send :: (forall w. (a -> VE w r) -> Union r (VE w r)) -> Eff r a
-- inj  :: (Functor t, Typeable1 t, Member t r) => t v -> Union r v

await :: (Typeable i, Member (Await i) r) => Eff r (Maybe i)
await = send $ \f -> inj $ Await $ \i -> undefined

yield :: (Typeable o, Member (Yield o) r) => o -> Eff r ()
yield o = send $ \f -> inj $ Yield o $ undefined

produce :: (Typeable o, Member (Yield o) r) => [o] -> Eff r ()
produce = mapM_ yield

consume :: (Typeable i, Member (Await i) r) => Eff r [i]
consume = await >>= maybe (return []) (\i -> (i :) <$> consume)

mapS :: (Typeable i, Typeable o, Member (Await i) r, Member (Yield o) r)
     => (i -> o) -> Eff r ()
mapS f = await >>= maybe (return ()) (yield . f)

combine :: (Typeable x, Member (Yield x) r1, Member (Await x) r2)
        => Eff r1 v
        -> Eff r2 v'
        -> Eff r v'
combine = undefined

runStream :: Eff ((Yield x) :> r) v
          -> Eff ((Await x) :> r) v
          -> Eff r v
runStream m1 m2 = loop (admin m1) (admin m2)
  where
    -- loop :: VE v ((Yield x) :> r) -> VE v ((Await x) :> r) -> Eff r v
    loop _ (Val v) = return v
    loop (Val _) (E u) = handleRelay u loo
    loop (E u1) (E u2) = handleRelay u2 loop $ \(Await f) -> do
      handleRelay u1 loop $ \(Yield x d) ->
        loop $ extract $ f x

    go (Done ve) = loop ve
    go (Await cont) = loop $ extract $ cont ()
    go (Yield _ stream) = loop $ extract stream
    -- extract :: (:==:) () o v -> v
    extract (Done v) = v
    extract (Await cont) = extract $ cont ()
    extract (Yield _ stream) = extract stream

main :: IO ()
main = do
  let eff = runStream (produce [1..10]) consume
  print $ run eff
