{-# LANGUAGE TypeFamilies, TypeOperators, DataKinds, ConstraintKinds, DeriveFunctor, FlexibleContexts #-}

module State where

import Control.Monad.Effect

newtype State s a = State (s -> (a, s))
  deriving Functor

type EffectState s es = (Member (State s) es, s ~ StateType es)
type family StateType es where
    StateType (State s ': es) = s
    StateType (e ': es) = StateType es

state :: (EffectState s es) => (s -> (a, s)) -> Effect es a
state = send . State

runState :: s -> Effect (State s ': es) a -> Effect es (a, s)
runState = flip $ handle point
    $ eliminate stateHandler
    $ relay stateRelay
  where
    point x s = return (x, s)
    stateHandler :: State s (s -> Effect es (a, s)) -> s -> Effect es (a, s)
    stateHandler (State k) s = let (k', s') = k s in k' s'
    stateRelay :: Member e es => e (s -> Effect es (a, s)) -> s -> Effect es (a, s)
    stateRelay x s = sendEffect $ fmap ($ s) x

-- インラインにすると型注釈なしでもエラーが起きないこともある(extensible-effects よりはマシ)
-- 型が合っても思い通りに動かないこともある

-- runState :: s -> Effect (State s ': es) a -> Effect es (a, s)
-- runState = flip $ handle (\a s -> return (a, s)) stateHandler
--   where
--     stateHandler = eliminate extractState $ relay stateRelay
--     extractState (State f) s = let (f', s') = f s in f' s'
--     stateRelay e s = sendEffect $ fmap ($ s) e

test :: IO ()
test = do
    print $ runEffect $ runState 0 $ do
        s <- state $ \s -> (s, s + 1)
        s' <- state $ \s -> (s, s + 1)
        s'' <- state $ \s -> (s, s + 10)
        return $ s + s' + s''
