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

runStream :: Eff (Yield x :> r) ()
          -> Eff (Await x :> r) v
          -> Eff r v
runStream m1 m2 = loop (admin m1) (admin m2) -- admin m1 :: VE () (Yield x :> r), admin m2 :: VE v (Await x :> r)
  where
    -- loop :: VE () ((Yield x) :> r) -> VE v ((Await x) :> r) -> Eff r v
    loop _ (Val v) = return v -- v :: v
    loop v@(Val _) (E u) = handleRelay u (loop v) $ \(Await _ stop) -> stop Stop -- u :: Union (Await x :> r) (VE v (Await x :> r))
    -- u1 :: Union (Yield x :> r) (VE () (Yield x :> r)), u2 :: Union (Await x :> r) (VE v (Await x :> r))
    loop (E u1) (E u2) = handleRelay u2 (loop (E u1)) $ \(Await next stop) -> do -- next :: x -> Either Stop (Await i (VE v (Await x :> r))), stop :: Stop -> VE v (Await x :> r)
                      -- handleRelay :: Union (Await x :> r) (VE v (Await x :> r))
                      --             -> (VE v (Await x :> r) -> Eff r v)
                      --             -> (Await x (VE v (Await x :> r)) -> Eff r v)
                      --             -> Eff r v
      handleRelay u1 (\ve -> loop ve (stop Stop)) $ \(Yield x next') -> -- x :: x, next :: Either Stop (Yield x (VE () (Yield x :> r)))
        -- handleRelay :: Union (Yield x :> r) (VE () (Yield x :> r))
        --             -> (VE () (Yield x :> r) -> Eff r v)
        --             -> (Yield x (VE () (Yield x :> r)) -> Eff r v)
        --             -> Eff r v
        case next' of
          Left Stop -> next x
        loop $ extract $ f x -- :: Eff r (VE r (Yield x :> r))

    go (Done ve) = loop ve
    go (Await cont) = loop $ extract $ cont ()
    go (Yield _ stream) = loop $ extract stream
    -- extract :: (:==:) () o v -> v
    extract (Done v) = v
    extract (Await cont) = extract $ cont ()
    extract (Yield _ stream) = extract stream

{-
admin :: Eff r w -> VE w r

data VE w r
  = Val w
  | E !(Union r (VE w r))

handleRelay :: Typeable1 t
            => Union (t :> r) v
            -> (v -> Eff r a)
            -> (t v -> Eff r a)
            -> Eff r a
-}


main :: IO ()
main = do
  let eff = runStream (produce [1..10]) consume
  print $ run eff
