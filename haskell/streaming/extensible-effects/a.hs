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

-- source :== a :== b :== sink

-- http://d.hatena.ne.jp/hiratara/20131029/1383053821

-- send :: (forall w. (a -> VE w r) -> Union r (VE w r)) -> Eff r a
-- inj  :: (Functor t, Typeable1 t, Member t r) => t v -> Union r v

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


data (:==) i o v where
  Done :: undefined
  -- Done :: v -> (:==) i o v
  -- Yield :: o -> ((:==) i o v) -> (:==) i o v
  -- Await :: (i -> ((:==) i o v)) -> (:==) i o v

type Src o = forall i. i :== o
type Snk i = forall o. i :== o

await :: (Typeable i, Member (Snk i) r) => Eff r (Maybe i)
await = send $ \f -> -- f :: Maybe i -> VE w r
  inj $ Done $

yield :: (Typeable o, Member (Src o) r) => o -> Eff r ()
yield o = undefined -- send (inj . Yield o)

sourceList :: (Typeable o, Member (forall i. i :== o) r) => [o] -> Eff r ()
sourceList = mapM_ yield

consume :: (Typeable i, Member (forall o. i :== o) r) => Eff r [i]
consume = do
  i <- await
  case i of
    Just i' -> (i' :) <$> consume
    Nothing -> return []

runStream :: (Typeable i, Typeable o)
          => Eff ((forall i'. i' :== o) :> r) ()
          -> Eff ((forall o'. i :== o') :> r) b
          -> Eff r b
runStream e1 e2 = undefined

main :: IO ()
main = do
  print $ run $ runStream (sourceList [1..10]) consume
