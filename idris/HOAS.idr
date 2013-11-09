-- 2013-11-08 memo

-- HAOS - Higher-Order Abstract Syntax
data Term : Type where
  App : Term -> Term -> Term
  Abs : (Term -> Term) -> Term
  -- 関数を表すのに、実装している方の言語(ホスト言語)の関数を使ってしまおう という考え
  -- こういうように書くと、評価するときに環境をゴニョゴニョしなくてよくなる
  -- Con : Const -> Term

-- \x. x x
term : Term
term = Abs (\x => App x x)

-- {- FOAS - First-Order Absract Syntax
data Term2 : Type where
  Var2 : String -> Term2
  Abs2 : String -> Term2 -> Term2
  App2 : Term2 -> Term2 -> Term2
  -- Con : Const -> Term2

-- \x. x x
term2 : Term2
term2 = Abs2 "x" (App2 (Var2 "x") (Var2 "x"))
-- -}

selfApply : Term -> Term
selfApply (App x y) = App x y
selfApply (Abs f) = f (Abs f)

bad : Term
bad = selfApply (Abs selfApply)
