import Control.Applicative hiding (Const)
import Data.List
import Data.Ratio

type N = Rational

data Expr = Add Expr Expr
          | Sub Expr Expr
          | Mul Expr Expr
          | Div Expr Expr
          | Const N
          deriving (Eq)

instance Show Expr where
  show (Add e1 e2) = "(" ++ show e1 ++ " + " ++ show e2 ++ ")"
  show (Sub e1 e2) = "(" ++ show e1 ++ " - " ++ show e2 ++ ")"
  show (Mul e1 e2) = "(" ++ show e1 ++ " * " ++ show e2 ++ ")"
  show (Div e1 e2) = "(" ++ show e1 ++ " / " ++ show e2 ++ ")"
  show (Const n) = show $ numerator n

ops :: [Expr -> Expr -> Expr]
ops = [Add, Sub, Mul, Div]

eval :: Expr -> Maybe N
eval (Add e1 e2) = (+) <$> eval e1 <*> eval e2
eval (Sub e1 e2) = (-) <$> eval e1 <*> eval e2
eval (Mul e1 e2) = (*) <$> eval e1 <*> eval e2
eval (Div e1 e2)
    | (numerator <$> eval e2) == Just 0 = Nothing
    | otherwise = (/) <$> eval e1 <*> eval e2
eval (Const n) = Just n

generate :: [Expr] -> [Expr]
generate [e] = [e]
generate es = do
    e1 <- es
    let es' = delete e1 es
    e2 <- es'
    let es'' = delete e2 es
    op <- ops
    generate $ op e1 e2 : es''

calc :: [Integer] -> Integer -> [Expr]
calc nums result = nub
                 . filter ((== Just (result % 1)) . eval)
                 . generate
                 . map (Const . (% 1))
                 $ nums

main :: IO ()
main = do
    nums <- map read . words <$> getLine
    result <- read <$> getLine
    mapM_ (putStrLn . show) $ calc nums result
