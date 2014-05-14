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

data Yield o v = Yield o v deriving (Functor)
type EffectYield o es = (Member (Yield o) es, o ~ YieldType es)
type family YieldType es where
    YieldType (Yield o ': es) = o
    YieldType (e ': es) = YieldType es

await :: (EffectAwait i es) => Effect es (Maybe i)
await = send $ Await Just Nothing

yield :: (EffectYield o es) => o -> Effect es ()
yield = send . flip Yield ()

produce :: (EffectYield o es) => [o] -> Effect es ()
produce = mapM_ yield

consume :: (EffectAwait i es) => Effect es [i]
consume = await >>= maybe (return []) (\i -> (i :) <$> consume)

awaitForever :: (EffectAwait i es) => (i -> Effect es v) -> Effect es ()
awaitForever f = await >>= maybe (return ()) (\i -> f i >> awaitForever f)

runStream :: Effect (Yield x ': es) a
          -> Effect (Await x ': es) b
          -> Effect es b
runStream y a = handle return awaitHandler a
  where
    -- awaitHandler :: Handler (Await x ': es) (Effect es b)
    awaitHandler = eliminate bindAwait defaultRelay

    -- bindAwait :: Await x (Effect es b) -> Effect es b
    bindAwait (Await f v) = handle (const v) (yieldHandler f) y

    yieldHandler :: (x -> Effect es b) -> Handler (Yield x ': es) (Effect es b)
    yieldHandler f = eliminate (bindYield f) defaultRelay

    bindYield :: (x -> Effect es b) -> Yield x (Effect es b) -> Effect es b
    bindYield f (Yield o v) = do
        something <- f o
        something v
    -- f o が次の await
    -- v が次の yield
    -- await してから yield された値を持ってくる

example :: IO ()
example = runLift $ runStream producer consumer
  where
    producer = do
        yield "hoge"
        yield "fuga"
    consumer = awaitForever $ lift . putStrLn
