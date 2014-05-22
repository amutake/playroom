module Main where

import Prelude hiding (lex)
import Data.List

data Token = Const Int
           | Add
           | Sub
           | Mul
           | Div
           deriving Show

data Expr = ConstE Int
          | AddE Expr Expr
          | SubE Expr Expr
          | MulE Expr Expr
          | DivE Expr Expr
          deriving Show

lex :: String -> [Token]
lex ('+':cs) = Add : lex cs
lex ('-':cs) = Sub : lex cs
lex ('*':cs) = Mul : lex cs
lex ('/':cs) = Div : lex cs
lex (c:cs)
    | '0' <= c && c <= '9' = Const (read [c]) : lex cs -- FIXME
    | otherwise = error $ "unexpected input: " ++ [c]

factor :: [Token] -> [[Token]]
factor [] = []
factor ((Const n):Mul = [[Const n]]
factor ((Const n):Add:ts) = [Const n] : [Add] : factor ts


parse1 :: [Token] -> [Either Token Expr]
parse1 [] = []
parse1 [Const n] = [Right (ConstE n)]
parse1

-- 1 + 2 * 3 / 4 * 5 - 4
-- = (1 + (((2 * 3) / 4) * 5)) - 4

-- 1 - 2 + 3
-- = (1 - 2) + 3
parse :: [Token] -> Expr
parse [] = error "unexpected EOF"
parse [Const n] = ConstE n
parse ((Const n):Add:ts) = AddE (ConstE n) $ parse ts
parse ((Const n):Sub:ts) = SubE (ConstE n) $ parse ts
parse ((Const n1):Mul:(Const n2):ts) = MulE (Const n1)



eval :: Expr -> Int
eval (ConstE n) = n
eval (AddE e1 e2) = eval e1 + eval e2
eval (SubE e1 e2) = eval e1 - eval e2
eval (MulE e1 e2) = eval e1 * eval e2
eval (DivE e1 e2) = eval e1 `div` eval e2

main :: IO ()
main = getLine >>= print . eval . parse . lex
