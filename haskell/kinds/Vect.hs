{-# LANGUAGE GADTs, DataKinds, KindSignatures #-}

data Nat = O | S Nat

data Vect :: Nat -> * -> * where
    Nil :: Vect O a
    Cons :: a -> Vect n a -> Vect (S n) a

singleton :: a -> Vect (S O) a
singleton a = Cons a Nil

two a b = Cons a $ Cons b Nil
