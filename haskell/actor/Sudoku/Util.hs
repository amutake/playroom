module Sudoku.Util where

import Control.Applicative
import Data.List
import Data.List.Split

import Sudoku.Core

isFailed :: Matrix Int -> Bool
isFailed (Matrix matrix) = anyDup [matrix, transpose matrix, box matrix]
  where
    anyDup = any (any (duplicate . filter (/= 0)))
    box = map concat . concat . map (chunksOf 3) . transpose . map (chunksOf 3)

isCompleted :: Matrix Int -> Bool
isCompleted = all (all (/= 0)) . toList

duplicate :: Eq a => [a] -> Bool
duplicate [] = False
duplicate (x:xs) = elem x xs || duplicate xs

getSudoku :: FilePath -> IO (Matrix Int)
getSudoku filepath = Matrix . map (map read) . map words . lines <$> readFile filepath
