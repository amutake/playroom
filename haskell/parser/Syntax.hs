module Syntax where

import Data.List

{-

tree[a] = {
  root: a
  forest: forest[a]
}

forest[a] = array[tree[a]]

-}

data Decl = Decl Name Body deriving (Eq)

instance Show Decl where
    show (Decl name body) = show name ++ " = " ++ show body

data Name = Name String [Name] deriving (Eq)

instance Show Name where
    show (Name constr params) = constr ++ "[" ++ intercalate ", " (map show params) ++ "]"

data Body = Object [Field] | Choice [Name] deriving (Eq)

instance Show Body where
    show (Object fields) = "{\n" ++ intercalate "\n" (map show fields) ++ "\n}"
    show (Choice names) = intercalate " | " $ map show names

data Field = Field String Name deriving (Eq)

instance Show Field where
    show (Field key typ) = key ++ ": " ++ show typ
