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

data (:==:) i o v = Done v
                  | Await (i -> (:==:) i o v)
                  | Yield o ((:==:) i o v)
                  deriving (Typeable, Functor)

type Producer o v = forall i. (:==:) i o v
type Consumer i v = forall o. (:==:) i o v
-- send :: (forall w. (a -> VE w r) -> Union r (VE w r)) -> Eff r a
-- inj  :: (Functor t, Typeable1 t, Member t r) => t v -> Union r v

await :: (Typeable i, Member (i :==: o) r) => Eff r i
await = send $ inj . Await . (Done .)
  -- send $ \f -> inj $ Await $ \i -> Done $ f i

awaitMaybe :: (Typeable i, Member (i :==: o) r) => Eff r (Maybe i)
awaitMaybe = send $ \f -> inj $ Await $ Done . f . Just
  -- send $ \f -> inj $ Await $ \i -> Done $ f $ Just i

yield :: (Typeable o, Member (i :==: o) r) => o -> Eff r ()
yield o = send $ \f -> inj $ Yield o $ Done $ f ()
  -- send $ \f -> inj $ Yield o $ Done $ f ()

produce :: (Typeable o, Member (i :==: o) r) => [o] -> Eff r ()
produce = mapM_ yield

consume :: (Typeable i, Member (i :==: Void) r) => Eff r [i]
consume = do
  i <- awaitMaybe
  case i of
    Just i' -> (i' :) <$> consume
    Nothing -> return []

(|==|) :: (Member (i :==: x) r1, Member (x :==: o) r2, Member (i :==: o) r)
       => Eff r1 a
       -> Eff r2 b
       -> Eff r b
e1 |==| e2 = undefined

mapS :: (Typeable i, Typeable o, Member (i :==: o) r) => (i -> o) -> Eff r ()
mapS f = await >>= yield . f

runStream :: Eff ((() :==: Void) :> r) v
          -> Eff r v
runStream m = loop (admin m)
  where
    -- loop :: VE v ((() :==: Void) :> r) -> Eff r v
    loop (Val v) = return v
    loop (E u) = handleRelay u loop go
    go (Done ve) = loop ve
    go (Await cont) = loop $ extract $ cont ()
    go (Yield _ stream) = loop $ extract stream
    -- extract :: (:==:) () o v -> v
    extract (Done v) = v
    extract (Await cont) = extract $ cont ()
    extract (Yield _ stream) = extract stream

main :: IO ()
main = do
  let eff = runStream $ (produce [1..10]) |==| mapS (* 2) |==| consume :: Eff () [Int]
  print $ run eff
