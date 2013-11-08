module Sudoku.Core where

newtype Matrix a = Matrix { toList :: [[a]] }

instance Show a => Show (Matrix a) where
  show (Matrix matrix) = unlines . map (unwords . map show) $ matrix

instance Functor Matrix where
  f `fmap` (Matrix mat) = Matrix $ map (map f) mat

type Solver = Matrix Int -> [Matrix Int]
