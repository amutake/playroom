{-# LANGUAGE RankNTypes #-}

module Types where

data ChurchNat = ChurchNat { unChurchNat :: forall e. e -> (e -> e) -> e }
-- type Nat = forall e. e -> (e -> e) -> e

zero :: ChurchNat
zero = ChurchNat const

succ' :: ChurchNat -> ChurchNat
succ' n = ChurchNat $ \z s -> s (unChurchNat n z s)

int2nat :: Int -> ChurchNat
int2nat n
    | n < 0 = error "must be a positive number"
    | n == 0 = zero
    | otherwise = succ' $ int2nat $ pred n

nat2int :: ChurchNat -> Int
nat2int n = unChurchNat n 0 succ
