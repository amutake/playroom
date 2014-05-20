{-# LANGUAGE RankNTypes, MultiParamTypeClasses, FlexibleInstances #-}

module Types where

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
    toChurch n
        | n < 0 = error "must be a positive number"
        | n == 0 = zero
        | otherwise = succ' $ toChurch $ pred n

data ChurchList a = ChurchList { unChurchList :: forall e. e -> (a -> e -> e) -> e }

nil :: ChurchList a
nil = ChurchList const

cons :: a -> ChurchList a -> ChurchList a
cons x xs = ChurchList $ \n c -> c x (unChurchList xs n c)

instance ChurchEncoding (ChurchList a) [a] where
    fromChurch xs = unChurchList xs [] (:)
    toChurch [] = nil
    toChurch (x:xs) = cons x (toChurch xs)
