{-# LANGUAGE FlexibleContexts, ConstraintKinds, GADTs, DeriveFunctor, TypeFamilies, DataKinds, TypeOperators #-}

module Stream where

import Prelude hiding (log)

import Control.Applicative
import Control.Monad.Effect
import Control.Effect.Lift

import Debug.Trace

log :: Show a => a -> a
log a = traceShow a a

data Await i v = Await (i -> v) v deriving (Functor)
type EffectAwait i es = (Member (Await i) es, i ~ AwaitType es)
type family AwaitType es where
    AwaitType (Await i ': es) = i
    AwaitType (e ': es) = AwaitType es

data Yield o v = Yield o deriving (Functor)
type EffectYield o es = (Member (Yield o) es, o ~ YieldType es)
type family YieldType es where
    YieldType (Yield o ': es) = o
    YieldType (e ': es) = YieldType es

await :: (EffectAwait i es) => Effect es (Maybe i)
await = send $ Await Just Nothing
-- Member (Await i) es => Await i (Maybe i) -> Effect es (Maybe i)

yield :: (EffectYield o es) => o -> Effect es ()
yield = send . Yield
-- Member (Yield o) es => Yield o () -> Effect es ()

produce :: (EffectYield o es) => [o] -> Effect es ()
produce = mapM_ yield

consume :: (EffectAwait i es) => Effect es [i]
consume = await >>= maybe (return []) (\i -> (i :) <$> consume)

awaitForever :: (EffectAwait i es) => (i -> Effect es v) -> Effect es ()
awaitForever f = await >>= maybe (return ()) (\i -> f i >> awaitForever f)

runStream :: Effect (Yield x ': es) ()
          -> Effect (Await x ': es) v
          -> Effect es v
runStream y a = handle return awaitHandler a
  where
--    awaitHandler :: Handler (Await x ': es) (Effect es v)
    awaitHandler = eliminate extractAwait defaultRelay
--    extractAwait :: Await x (Effect es v) -> Effect es v
    extractAwait (Await f v) = handle (const v) (yieldHandler f) y
--    yieldHandler :: (x1 -> Effect es1 v) -> Handler (Yield x ': es) (Effect es1 v)
    yieldHandler f = eliminate (extractYield f) defaultRelay
--    extractYield :: Yield x (Effect es1 v) -> Effect es v
    extractYield f (Yield o) = f o

example :: IO ()
example = do
    runLift $ runStream producer consumer
  where
    producer = do
        yield "hoge"
        yield "fuga"
    consumer = do
        awaitForever $ \str -> do
            lift $ putStrLn str
