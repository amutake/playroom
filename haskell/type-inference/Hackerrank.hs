module Main where

import Control.Applicative
import Data.Map (Map)
import qualified Data.Map as M
import Text.Parsec
import Text.Parsec.String

-- Type

newtype Id = MkId { rawId :: String } deriving (Show, Eq, Ord)

data Ty = TyForall [Id] Ty
        | TyArrow Ty Ty
        | TyUnitArrow Ty
        | TyUncurry [Ty] Ty
        | TyPair Ty Ty
        | TyList Ty
        | TyInt
        | TyBool
        | TyVar Id
        deriving (Eq)

instance Show Ty where
    show (TyForall ids ty) = "forall[" ++

type Env = Map (Id, Ty)

-- AST

data Expr = Let Id (Maybe Ty) Expr Expr
          | Fun [Id] Expr
          | App Expr [Expr]
          | Id Id
          deriving (Show, Eq)

-- Parser

idParser :: Parser Id
idParser = MkId <$> (:) <$> hd <*> tl
  where
    hd = letter <|> char '_'
    tl = many (alphaNum <|> char '_')

parens :: Parser a -> Parser a
parens = between (char '(') (char ')')

exprParser :: Parser Expr
exprParser = letParser <|> funParser <|> try appParser <|> idParser'
  where
    letParser = Let <$>
                string "let " *> idParser <*>
                pure Nothing <*>
                string " = " *> exprParser <*>
                string " in " *> exprParser
    funParser = Fun <$>
                string "fun " *> sepBy idParser (char ' ') <*>
                string " -> " *> exprParser
    appParser = App <$>
                (parens exprParser <|> idParser') <*>
                parens (sepBy exprParser (string ", ")) <|>
    idParser' = Id <$> idParser

tyParser :: Parser Ty
tyParser = forallParser <|>
           arrowParser <|>
           unitArrowParser <|>
           uncurryParser <|>
           pairParser <|>
           listParser <|>
           intParser <|>
           boolParser <|>
           varParser
  where
    brackets = between (char '[') (char ']')
    forallParser = TyForall <$>
                   string "forall" *> brackets (sepBy idParser (char ' ')) <*>
                   tyParser
    arrowParser = TyArrow <$>
                  (parens tyParser <|> varParser) <*>
                  string " -> " *> tyParser
    unitArrowParser = TyUnitArrow <$>
                      string "() -> " *> tyParser
    uncurryParser = TyUncurry <$>
                    parens (sepBy1 tyParser (string ", ")) <*>
                    string " -> " *> tyParser
    pairParser = uncurry TyPair <$>
                 string "pair" *> brackets ((,) <$> tyParser <*> string ", " *> tyParser)
    listParser = TyList <$>
                 string "list" *> brackets tyParser
    intParser = TyInt <$ string "int"
    boolParser = TyBool <$ string "bool"
    varParser = TyVar <$> idParser

declParser :: Parser (Id, Ty)
declParser = (,) <$> idParser <*> string ": " *> tyParser

envParser :: Parser Env
envParser = M.fromList <$> sepBy declParser (char '\n')

-- Typing

unify :: State
