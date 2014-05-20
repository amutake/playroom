{-# LANGUAGE RankNTypes #-}

module Typing where

import Data.STRef
import Data.Map

data Term = Var String
          | Abs String Term
          | App Term Term
          | Let String Term Term
          | Val Int -- Int as constant value

data Type = TyVar (forall s. (STRef s (Maybe Type))) -- TyVar Type? TyVar (Ref Type)? TyVar (Ref String)?
          | TyFun Type Type -- function
          | TyCon String [Type] -- type constructor

{-
(type (Either a b) (Left a) (Right b))

Left :: TyFun (TyVar (ref $1)) (TyCon "Either" [TyVar (ref $1), TyVar (ref $2)])
$1 = None, $2 = None

Right :: TyFun (TyVar (ref $2)) (TyCon "Either" [TyVar (ref $1), TyVar (ref $2)])
$1 = None, $2 = None

ref の先が None のときはそのまま型変数、それ以外はその型
-}

data TypeEnv = TypeEnv (IORef (Map Var Type))

g :: TypeEnv Term -> Type

unify :: Type -> Type -> Either Error ()
