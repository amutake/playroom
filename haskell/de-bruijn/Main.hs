{-# LANGUAGE GADTs #-}

module Main where

-- core definitions

data Nat = O | S Nat deriving (Eq, Show)

data Exp = Var Nat | App Exp Exp | Abs Exp deriving (Show)

subst :: Nat -> Exp -> Exp -> Exp
subst n (Var n') e
    | n == n' = e
    | otherwise = Var n'
subst n (App e1 e2) e = App (subst n e1 e) (subst n e2 e)
subst n (Abs e') e = Abs (subst (S n) e' e)

eval :: Exp -> Exp
eval (Var n) = Var n
eval (App (Abs e1) e2) = eval (subst O e1 e2)
eval (App e1 e2) = eval (App (eval e1) (eval e2))
eval (Abs e) = Abs (eval e)

-- utility functions

nat2int :: Nat -> Int
nat2int O = 0
nat2int (S n) = succ (nat2int n)

int2nat :: Int -> Nat
int2nat 0 = O
int2nat n
    | n > 0 = S (int2nat (pred n))
    | otherwise = undefined

op2nat :: (Int -> Int -> Int) -> Nat -> Nat -> Nat
op2nat op n m = int2nat (nat2int n `op` nat2int m)

instance Num Nat where
    (+) = op2nat (+)
    (*) = op2nat (*)
    abs n = n
    signum _ = S O
    fromInteger = int2nat . fromInteger
    (-) = op2nat (-)

-- combinators

s :: Exp
s = Abs (Abs (Abs (App (App (Var 2) (Var 0)) (App (Var 1) (Var 0)))))

k :: Exp
k = Abs (Abs (Var 1))

i :: Exp
i = Abs (Var 0)

b :: Exp
b = Abs (Abs (Abs (App (App (Var 2) (Var 0)) (Var 1))))

c :: Exp
c = Abs (Abs (Abs (App (Var 2) (App (Var 1) (Var 0)))))

skk :: Exp
skk = eval (App (App s k) k)

main :: IO ()
main = print skk
