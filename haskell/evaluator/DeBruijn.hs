import Data.List

data Exp = Var Int | App Exp Exp | Abs Exp deriving (Show, Eq)

eval :: Exp -> Exp
eval (Var n) = Var n
eval (App e1 e2) = apply (eval e1) (eval e2)
eval (Abs e) = Abs (eval e)

apply :: Exp -> Exp -> Exp
apply (Var n) e = App (Var n) e
apply (App e1 e2) e = App (App e1 e2) e
apply (Abs e) e' = eval $ set 0 e e'

set :: Int -> Exp -> Exp -> Exp
set n (Var n') e
  | n == n' = e
  | n <= n' = Var (n' - 1)
  | otherwise = Var n'
set n (App e1 e2) e = App (set n e1 e) (set n e2 e)
set n (Abs e) e' = Abs (set (n + 1) e (up 0 e'))

up :: Int -> Exp -> Exp
up n (Var n')
  | n <= n' = Var (n' + 1)
  | otherwise = Var n'
up n (App e1 e2) = App (up n e1) (up n e2)
up n (Abs e) = Abs (up (n + 1) e)

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

zeroE :: Exp
zeroE = Abs (Abs (Var 0))

oneE :: Exp
oneE = Abs (Abs (App (Var 1) (Var 0)))

succE :: Exp
succE = Abs (Abs (Abs (App (Var 1) (App (App (Var 2) (Var 1)) (Var 0)))))

plusE :: Exp
plusE = Abs (Abs (App (App (Var 1) succE) (Var 0)))

multE :: Exp
multE = Abs (Abs (Abs (App (Var 2) (App (Var 1) (Var 0)))))

app :: [Exp] -> Exp
app [] = error "app"
app [e] = eval e
app es = eval $ foldl1' App es

main :: IO ()
main = do
  putStr "i == s k k : "
  print $ app [i, zeroE] == app [s, k, k, zeroE]
  putStr "succ 0 == 1 : "
  print $ app [succE, zeroE] == oneE
  putStr "0 + 1 == 1 : "
  print $ app [plusE, zeroE, oneE] == oneE
  putStr "1 * 1 == 1 : "
  print $ app [multE, oneE, oneE] == oneE
