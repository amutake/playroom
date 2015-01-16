{-# LANGUAGE TypeOperators #-}

module Main where

import Control.Applicative ((<$>), (<|>), (<*>), (<*), (<$))
import Control.Monad
import Control.Monad.Identity
import qualified Text.Parsec as P
import Text.Parsec.Char
import Text.Parsec.String
import Text.Parsec.Expr
import Text.Parsec.Token
import Text.Parsec.Language

import Debug.Trace (trace)

languageDef :: LanguageDef ()
languageDef = LanguageDef
    { commentStart = "/*"
    , commentEnd = "*/"
    , commentLine = "//"
    , nestedComments = True
    , identStart = letter <|> char '_'
    , identLetter = alphaNum <|> char '_'
    , opStart = oneOf ":!#$%&*+./<=>?@\\^|-~"
    , opLetter = oneOf ":!#$%&*+./<=>?@\\^|-~"
    , reservedNames = ["var", "if", "else", "fun", "while", "print", "return"]
    , reservedOpNames = ["+", "-", "*", "/"]
    , caseSensitive = True
    }

tp :: TokenParser ()
tp = makeTokenParser (emptyDef { reservedOpNames = ["+", "-", "*", "/"] })

data Expr = Expr :+ Expr
          | Expr :- Expr
          | Expr :* Expr
          | Expr :/ Expr
          | Const Integer
          deriving (Show)

table :: OperatorTable String () Identity Expr
table = [ [ Infix ((:*) <$ reservedOp tp "*") AssocLeft
          , Infix ((:/) <$ reservedOp tp "/") AssocLeft
          ]
        , [ Infix ((:+) <$ reservedOp tp "+") AssocLeft
          , Infix ((:-) <$ reservedOp tp "-") AssocLeft
          ]
        ]

infixParser :: Parser Expr
infixParser = buildExpressionParser table $ parens tp infixParser <|> constParser

constParser :: Parser Expr
constParser = Const <$> natural tp

exprParser :: Parser Expr
exprParser = infixParser <|> constParser

parse :: String -> Either P.ParseError Expr
parse = P.parse exprParser "expr"

eval :: Expr -> Integer
eval (e1 :+ e2) = eval e1 + eval e2
eval (e1 :- e2) = eval e1 - eval e2
eval (e1 :* e2) = eval e1 * eval e2
eval (e1 :/ e2) = eval e1 `div` eval e2
eval (Const n) = n

main :: IO ()
main = do
    code <- getLine
    case parse code of
        Left err -> print err
        Right expr -> print $ eval expr
