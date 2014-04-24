module Parsers where

import Control.Applicative
import Data.Foldable
import Text.Parser.Char
import Text.Parser.Combinators
import Text.Parser.Token

import Syntax

parseDecls :: TokenParsing m => m [Decl]
parseDecls = many parseDecl

parseDecl :: TokenParsing m => m Decl
parseDecl = Decl <$> (parseName <* symbol "=") <*> parseBody

parseName :: TokenParsing m => m Name
parseName = Name <$> parseIdent <*> (asum <$> optional parseParams)
  where
    parseParams = brackets $ parseName `sepBy` symbol ","

parseIdent :: TokenParsing m => m String
parseIdent = (:) <$> letter <*> many alphaNum

parseBody :: TokenParsing m => m Body
parseBody = parseObject <|> parseChoice

parseObject :: TokenParsing m => m Body
parseObject = braces $ Object <$> many parseField

parseField :: TokenParsing m => m Field
parseField = Field <$> (parseIdent <* symbol ":") <*> parseName

parseChoice :: TokenParsing m => m Body
parseChoice = Choice <$> parseName `sepBy1` symbol "|"
