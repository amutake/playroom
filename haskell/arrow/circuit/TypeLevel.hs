{-# LANGUAGE GADTs, DataKinds, KindSignatures, StandaloneDeriving, NoImplicitPrelude, TypeOperators, TypeFamilies, UndecidableInstances #-}

module TypeLevel where

import Prelude (Functor (..), undefined, Eq (..), Int, (-), (>), otherwise)
import GHC.TypeLits hiding (Nat)

data Nat where
    Z :: Nat
    S :: Nat -> Nat

type family (:-:) n m where
    Z :-: m = Z
    (S n) :-: (S m) = n :-: m

data SNat n where
    SZ :: SNat Z
    SS :: SNat n -> SNat (S n)

data Fin n where
    FZ :: Fin n
    FS :: Fin n -> Fin (S n)

data SFin n m where -- n を超えない m
    SFZ :: SFin n Z
    SFS :: SFin n m -> SFin (S n) (S m)


data Vect n a where
    Nil :: Vect Z a
    (:-) :: a -> Vect n a -> Vect (S n) a

infixr 5 :-

deriving instance Eq a => Eq (Vect n a)

instance Functor (Vect n) where
    fmap _ Nil = Nil
    fmap f (x :- xs) = f x :- fmap f xs

zip :: Vect n a -> Vect n b -> Vect n (a, b)
zip Nil Nil = Nil
zip (a :- as) (b :- bs) = (a, b) :- zip as bs
zip _ _ = undefined

map :: (a -> b) -> Vect n a -> Vect n b
map = fmap

head :: Vect (S n) a -> a
head (a :- _) = a

tail :: Vect (S n) a -> Vect n a
tail (_ :- as) = as

last :: Vect (S n) a -> a
last (a :- Nil) = a
last (_ :- as@(_ :- _)) = last as

init :: Vect (S n) a -> Vect n a
init (_ :- Nil) = Nil
init (a :- as@(_ :- _)) = a :- init as

take :: SFin n m -> Vect n a -> Vect m a
take SFZ _ = Nil
take (SFS n) (a :- as) = a :- take n as
take _ _ = undefined

replicate :: SNat n -> a -> Vect n a
replicate SZ _ = Nil
replicate (SS n) a = a :- replicate n a

-----------------------
-- conversion functions
-----------------------

type family IntToNat n where
    IntToNat 0 = Z
    IntToNat n = S (IntToNat (n - 1))

intToSNat :: Int -> SNat (IntToNat n)
intToSNat n
    | n == 0 = SZ
    | n > 0 = SS (intToSNat (n - 1))
    | otherwise = undefined
