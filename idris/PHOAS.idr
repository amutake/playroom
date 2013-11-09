-- PHOAS - Parametric Higher-Order Abstract Syntax
data term : Type -> Type where
  Var : v -> term v
  App : term v -> term v -> term v
  Abs : (v -> term v) -> term v

Term : Type
Term = (t : Type) -> term t

numVars : term () -> Nat
numVars (Var _) = 1
numVars (App e1 e2) = numVars e1 + numVars e2
numVars (Abs e) = numVars (e ())

NumVars : Term -> Nat
NumVars e = numVars (e ())

canEta' : term Bool -> Bool
canEta' (Var b) = b
canEta' (App e1 e2) = canEta' e1 && canEta' e2
canEta' (Abs e) = canEta' (e True)

canEta : term Bool -> Bool
canEta (Abs e) = case e False of
  App e1 (Var False) => canEta' e1
  _ => False
canEta _ = False

CanEta : Term -> Bool
CanEta e = canEta (e Bool)

E : Term
E () = App (Abs (\u => Var u)) (Var ())
E Bool = App (Abs (\b => Var b)) (Var False)
