{-# LANGUAGE RankNTypes, MultiParamTypeClasses, FlexibleInstances #-}

module Types where

import Data.List

class ChurchEncoding a b where -- a is church encoding of b
    fromChurch :: a -> b
    toChurch :: b -> a

data ChurchNat = ChurchNat { unChurchNat :: forall e. e -> (e -> e) -> e }
-- type Nat = forall e. e -> (e -> e) -> e

zero :: ChurchNat
zero = ChurchNat const

succ' :: ChurchNat -> ChurchNat
succ' n = ChurchNat $ \z s -> s (unChurchNat n z s)

instance Integral n => ChurchEncoding ChurchNat n where
    fromChurch n = unChurchNat n 0 succ
    toChurch n = iterate succ' zero `genericIndex` n

data ChurchList a = ChurchList { unChurchList :: forall e. e -> (a -> e -> e) -> e }

nil :: ChurchList a
nil = ChurchList const

cons :: a -> ChurchList a -> ChurchList a
cons x xs = ChurchList $ \n c -> c x (unChurchList xs n c)

instance ChurchEncoding (ChurchList a) [a] where
    fromChurch xs = unChurchList xs [] (:)
    toChurch [] = nil
    toChurch (x:xs) = cons x (toChurch xs)

data ChurchBool = ChurchBool { unChurchBool :: forall e. e -> e -> e }

ifThenElse :: ChurchBool -> a -> a -> a
ifThenElse c t f = unChurchBool c t f

true :: ChurchBool
true = ChurchBool const

false :: ChurchBool
false = ChurchBool $ \_ f -> f

instance ChurchEncoding ChurchBool Bool where
    fromChurch b = unChurchBool b True False
    toChurch b
        | b = true
        | otherwise = false
