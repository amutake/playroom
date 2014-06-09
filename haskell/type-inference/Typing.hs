{-# LANGUAGE RankNTypes, ConstraintKinds, FlexibleContexts, TypeFamilies #-}

module Typing where

import Data.STRef
import Data.Map

import Control.Effect
import Control.Monad.ST

data Term = Var String
          | Abs String Term
          | App Term Term
          | Let String Term Term
          | Val Int -- Int as constant value

data Type = TyVar (forall s. (STRef s (Maybe Type))) -- TyVar Type? TyVar (Ref Type)? TyVar (Ref String)?
          | TyFun Type Type -- function type
          | TyCon String [Type] -- type constructor
          | TyInt -- integer type

{-
(type (Either a b) (Left a) (Right b))

Left :: TyFun (TyVar (ref $1)) (TyCon "Either" [TyVar (ref $1), TyVar (ref $2)])
$1 = None, $2 = None

Right :: TyFun (TyVar (ref $2)) (TyCon "Either" [TyVar (ref $1), TyVar (ref $2)])
$1 = None, $2 = None

ref の先が None のときはそのまま型変数、Some t の場合はその型
-}

type TypeEnv = forall s. STRef s (Map Term Type)

data Error = UnificationError Type Type
           | OccursCheckError
           | UndefinedVariableError String

infer :: TypeEnv -> Term -> Either Error Type
infer envRef term = runST $ runLift $ runException $ do
    env <- lift $ readSTRef envRef
    undefined



unify :: (EffectLift (ST s) es, EffectException Error es)
      => Type -> Type -> Effect es ()
unify TyInt TyInt = return ()
unify t1@(TyCon name1 args1) t2@(TyCon name2 args2)
    | name1 == name2 && length args1 == length args2 =
        mapM_ (uncurry unify) $ zip args1 args2
    | otherwise = raise $ UnificationError t1 t2
unify (TyFun d1 r1) (TyFun d2 r2) = unify d1 d2 >> unify r1 r2
unify (TyVar ref1) (TyVar ref2) | ref1 == ref2 = return ()
unify (TyVar ref1) ty2 = do
    ty1 <- lift $ readSTRef ref1
    case ty1 of
        Nothing -> undefined
        Just ty1' -> unify ty1' ty2

unify (TyVar ref1) (TyVar ref2) = do
    ty1 <- lift $ readSTRef ref1
    ty2 <- lift $ readSTRef ref2
    case ty1 of
        Nothing -> lift $ writeSTRef ref1 (TyVar ref2)
        Just ty1' -> do
