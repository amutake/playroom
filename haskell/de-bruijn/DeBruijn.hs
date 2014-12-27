module DeBruijn where

import Data.List

data Expr = Var Int | App Expr Expr | Abs Expr deriving (Eq, Show)

subst :: Expr -> Int -> Expr -> Expr
subst (Var n) m e
    | n == m = e
    | otherwise = Var n
subst (App e1 e2) n e = App (subst e1 n e) (subst e2 n e)
subst (Abs e) n e' = Abs (subst e (n + 1) e')

eval :: Expr -> Expr
eval (Var n) = Var n
eval (App (Abs e) (Var n)) = eval (subst e 0 (Var n))
eval (App (Abs e) (App e1 e2)) = eval (App (Abs e) (eval (App e1 e2)))
eval (App (Abs e) (Abs e')) = eval (subst e 0 (Abs e'))
eval (App (Var n) e) = eval (App (Var n) (eval e))
eval (App (App e1 e2) e) = eval (App (eval (App e1 e2)) e)
eval (Abs e) = Abs e



s :: Expr
s = Abs (Abs (Abs (App (App (Var 2) (Var 0)) (App (Var 1) (Var 0)))))

k :: Expr
k = Abs (Abs (Var 1))

i :: Expr
i = Abs (Var 0)

b :: Expr
b = Abs (Abs (Abs (App (App (Var 2) (Var 0)) (Var 1))))

c :: Expr
c = Abs (Abs (Abs (App (Var 2) (App (Var 1) (Var 0)))))

skk :: Expr
skk = eval (App (App s k) k)

zeroE :: Expr
zeroE = Abs (Abs (Var 0))

oneE :: Expr
oneE = Abs (Abs (App (Var 1) (Var 0)))

succE :: Expr
succE = Abs (Abs (Abs (App (Var 1) (App (App (Var 2) (Var 1)) (Var 0)))))

plusE :: Expr
plusE = Abs (Abs (App (App (Var 1) succE) (Var 0)))

multE :: Expr
multE = Abs (Abs (Abs (App (Var 2) (App (Var 1) (Var 0)))))

app :: [Expr] -> Expr
app [] = error "app"
app [e] = eval e
app es = eval $ foldl1' App es

main :: IO ()
main = do
    putStr "i == s k k : "
    print $ app [i, zeroE] == app [s, k, k, zeroE]
    putStr "succ 0 == 1 : "
    print $ app [succE, zeroE, i, i] == app [oneE, i, i]
    putStr "0 + 1 == 1 : "
    print $ app [plusE, zeroE, oneE] == oneE
    putStr "1 * 1 == 1 : "
    print $ app [multE, oneE, oneE, i, i] == app [oneE, i, i]
