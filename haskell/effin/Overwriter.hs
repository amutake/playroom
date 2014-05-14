{-# LANGUAGE MultiParamTypeClasses
  , TypeFamilies
  , DeriveFunctor
  , TypeOperators
  , TypeFamilies
  , DataKinds
  , FlexibleContexts
  , FlexibleInstances
  , UndecidableInstances

  , ScopedTypeVariables
  #-}

module Overwriter where

import Control.Monad.Effect

data Overwriter e v = Overwriter e v deriving (Functor)

class (Member (Overwriter e) es, e ~ OverwriterType es) => EffectOverwriter e es
instance (Member (Overwriter e) es, e ~ OverwriterType es) => EffectOverwriter e es

type family OverwriterType es where
    OverwriterType (Overwriter e ': es) = e
    OverwriterType (e ': es) = OverwriterType es

overwrite :: (EffectOverwriter e es) => e -> Effect es ()
overwrite e = send $ Overwriter e ()

runOverwriter :: Effect (Overwriter e ': es) v
              -> Effect es (v, Maybe e)
runOverwriter = handle point handler
  where
    point v = return (v, Nothing)
    handler = eliminate bind defaultRelay
    bind :: Overwriter e (Effect es (v, Maybe e)) -> Effect es (v, Maybe e)
    bind (Overwriter e v) = do
        (v', e') <- v -- v は次のエフェクト。最後のエフェクトは point によって出てきたやつ
        case e' of
            Nothing -> return (v', Just e)
            Just _ -> return (v', e')

test :: IO ()
test = do
    let (v, n :: Maybe ()) = runEffect $ runOverwriter $ do
        return "no"
    print v
    print n
    print $ runEffect $ runOverwriter $ do
        overwrite "hoge"
        overwrite "fuga"
