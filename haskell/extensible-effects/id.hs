{-# LANGUAGE FlexibleContexts
  , DeriveDataTypeable
  , DeriveFunctor
  , TypeOperators
  #-}

import Prelude hiding (id)
import Data.Typeable

import Control.Eff

newtype Id v = Id v deriving (Typeable, Functor)

id :: (Member Id r) => v -> Eff r v
id v = send (\f -> inj . Id $ f v)

runId :: Eff (Id :> r) v -> Eff r v
runId m = loop (admin m)
  where
    -- loop :: VE v (Id :> r) -> Eff r v
    loop (Val v) = return v -- v :: v
    loop (E u) = handleRelay u loop (\(Id ve) -> loop ve) -- u :: Union (Id :> r) (VE v (Id :> r))

main :: IO ()
main = do
  print . run . runId . id $ "aaa"
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
