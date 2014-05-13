{-# LANGUAGE FlexibleContexts, ConstraintKinds, GADTs, DeriveFunctor, TypeFamilies, DataKinds, TypeOperators
  , ExistentialQuantification
  #-}

module Stream2 where

import Control.Applicative
import Control.Monad.Effect
import Data.Void

data Stream i o v = Yield o
                  | Await (i -> v) v
                  deriving (Functor)

type EffectStream i o es = (Member (Stream i o) es, i ~ AwaitType es, o ~ YieldType es)
type EffectStream2 i o es = (Member (Stream i o) es, (i, o) ~ StreamType es)

type family StreamType es where
    StreamType (Stream i o ': es) = (i, o)
    StreamType (e ': es) = StreamType es

type EffectAwait i es = (Member (Stream i Void) es, i ~ AwaitType es)

type family AwaitType es where
    AwaitType (Stream i o ': es) = i
    AwaitType (e ': es) = AwaitType es

type family YieldType es where
    YieldType (Stream i o ': es) = o
    YieldType (e ': es) = YieldType es

await :: forall i o es. Member (Stream i o) es => Effect es (Maybe i)
await = send $ Await Just Nothing
-- send :: Member (Stream i o) es => Stream i o (Maybe i) -> Effect es (Maybe i)

yield :: (EffectStream i o es) => o -> Effect es ()
yield = send . Yield
-- Member (Yield o) es => Yield o () -> Effect es ()

produce :: (EffectStream i o es) => [o] -> Effect es ()
produce = mapM_ yield

consume :: (EffectStream i o es) => Effect es [i]
consume = await >>= maybe (return []) (\i -> (i :) <$> consume)

awaitForever :: (EffectStream i o es) => (i -> Effect es v) -> Effect es ()
awaitForever f = await >>= maybe (return ()) (\i -> f i >> awaitForever f)

runStream :: Effect (Stream i o ': es) v
          -> Effect es v
runStream = handle return handler
  where
    handler = undefined
