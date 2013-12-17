{-# LANGUAGE FlexibleContexts
  , RankNTypes
  , TypeOperators
  , DeriveDataTypeable
  , DeriveFunctor
  , ImpredicativeTypes
  , GADTs
  #-}

import Control.Applicative
import Data.Typeable

import Control.Eff
import Data.Void

-- source :== a :== b :== sink

-- http://d.hatena.ne.jp/hiratara/20131029/1383053821

{- Writer
-- | The request to remember a value of type w in the current environment
data Writer w v = Writer w v
    deriving (Typeable, Functor)

-- | Write a new value.
tell :: (Typeable w, Member (Writer w) r) => w -> Eff r ()
tell w = send $ \f -> inj $ Writer w $ f ()
-}

{- Reader
-- | The request for a value of type e from the current environment.
-- This environment is analogous to a parameter of type e.
newtype Reader e v = Reader (e -> v)
    deriving (Typeable, Functor)

-- | Get the current value from a Reader.
ask :: (Typeable e, Member (Reader e) r) => Eff r e
ask = send (inj . Reader)
-}

{- State
-- | Strict state effect
data State s w = State (s -> s) (s -> w)
  deriving (Typeable, Functor)

-- | Write a new value of the state.
put :: (Typeable e, Member (State e) r) => e -> Eff r ()
put = modify . const

-- | Return the current value of the state.
get :: (Typeable e, Member (State e) r) => Eff r e
get = send (inj . State id)

-- | Transform the state with a function.
modify :: (Typeable s, Member (State s) r) => (s -> s) -> Eff r ()
modify f = send $ \k -> inj $ State f $ \_ -> k ()
-}


data (:==:) i o v where
  Done :: (:==:) i o v
  Await :: (i -> v) -> (:==:) i o v
  Yield :: o -> (() -> v) -> (:==:) i o v
  deriving (Typeable, Functor)
  -- Done :: v -> (:==) i o v
  -- Yield :: o -> ((:==) i o v) -> (:==) i o v
  -- Await :: (i -> ((:==) i o v)) -> (:==) i o v

-- send :: (forall w. (a -> VE w r) -> Union r (VE w r)) -> Eff r a
-- inj  :: (Functor t, Typeable1 t, Member t r) => t v -> Union r v

await :: forall i o r. (Typeable i, Member (i :==: o) r) => Eff r i
await = send (inj . Await)

yield :: (Typeable o, Member (i :==: o) r) => o -> Eff r ()
yield o = send (inj . Yield o)

produce :: (Typeable o, Member (() :==: o) r) => [o] -> Eff r ()
produce = mapM_ yield

consume :: (Typeable i, Member (i :==: Void) r) => Eff r [i]
consume = do
  i <- await
  (i :) <$> consume

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
    go (Await cont) = loop (cont ())
    go (Yield o ve) = loop (ve ())

main :: IO ()
main = do
  print $ run $ runStream $ (produce [1..10]) |==| mapS (* 2) |==| consume
