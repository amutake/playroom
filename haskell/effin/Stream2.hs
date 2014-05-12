{-# LANGUAGE FlexibleContexts, ConstraintKinds, GADTs, DeriveFunctor, TypeFamilies, DataKinds, TypeOperators #-}

module Stream2 where

import Control.Applicative
import Control.Monad.Effect

data Stream i o v = Yield o
                  | Await (i -> v)
                  deriving (Functor)

type EffectStream i o es = (Member (Stream i o) es, i ~ AwaitType es, o ~ YieldType es)

type family AwaitType es where
    AwaitType (Stream i o ': es) = i
    AwaitType (e ': es) = AwaitType es

type family YieldType es where
    YieldType (Stream i o ': es) = o
    YieldType (e ': es) = YieldType es

await :: (EffectStream i o es) => Effect es (Maybe i)
await = sendEffect $ Await (return . Just)
-- send :: Member (Stream i o) es => Stream i o (Maybe i) -> Effect es (Maybe i)

yield :: (EffectStream i o es) => o -> Effect es ()
yield o = sendEffect $ Yield o
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
    awaitHandler :: Handler (Await x ': es) (Effect es v)
    awaitHandler = eliminate extractAwait $ defaultRelay
    extractAwait :: Await x (Effect es v) -> Effect es v
    extractAwait (Await f v) = v
