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
-- Member (Await i) es => Await i (Maybe i) -> Effect es (Maybe i)

yield :: (EffectYield o es) => o -> Effect es ()
yield o = send $ Yield o ()
-- Member (Yield o) es => Yield o () -> Effect es ()

produce :: (EffectYield o es) => [o] -> Effect es ()
produce = mapM_ yield

consume :: (EffectAwait i es) => Effect es [i]
consume = await >>= maybe (return []) (\i -> (i :) <$> consume)

awaitForever :: (EffectAwait i es) => (i -> Effect es v) -> Effect es ()
awaitForever f = await >>= maybe (return ()) (\i -> f i >> awaitForever f)

runStream :: (Show x, Show a, Show b) => Effect (Yield x ': es) a
          -> Effect (Await x ': es) b
          -> Effect es b
runStream y a = handle return awaitHandler a
  where
--    awaitHandler :: Handler (Await x ': es) (Effect es b)
    awaitHandler = eliminate extractAwait defaultRelay
--    eliminate :: (Await x (Effect es v) -> Effect es v)
--              -> Handler es (Effect es v)
--              -> Handler (Await x : es) (Effect es v)
--    defaultRelay :: Handler es (Effect es v)
    extractAwait :: Await x (Effect es b) -> Effect es b
    extractAwait (Await f v) = handle (const v) (yieldHandler f) y
    yieldHandler :: (x -> Effect es b) -> Handler (Yield x ': es) (Effect es b)
    yieldHandler f = eliminate (extractYield f) $ relay yieldRelay
    extractYield :: (x -> Effect es b) -> Yield x (Effect es (x -> b)) -> Effect es (x -> b)
    extractYield f (Yield o v) = v $ f o
--    yieldRelay :: Member e es => e ((x -> Effect es b) -> Effect es b) -> (x -> Effect es b) -> Effect es b
    yieldRelay e f = _ -- sendEffect $ fmap ($ f) e

-- runS :: Effect (Yield x ': es) a
--      -> Effect (Await x ': es) b
--      -> Effect es b
-- runS y a = handle return awaitHandler a
--   where
--     awaitHandler = eliminate extractAwait defaultRelay
--     extractAwait (Await f v) = handle (const v) (yieldHandler f) y
--     yieldHandler f = eliminate (extractYield f) defaultRelay
--     extractYield f (Yield o v) =

example :: IO ()
example = do
    b <- runLift $ runStream producer consumer
    print b
  where
    producer = do
        yield "hoge"
        return False
        -- yield "hoge"
        -- yield "fuga"
        -- return True
    consumer = do
        a <- await
        lift $ maybe (putStrLn "nothing") putStrLn (a :: Maybe String)
        b <- await
        lift $ print b
        return True
        -- awaitForever $ \str -> do
        --     lift $ putStrLn str
