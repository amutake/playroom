module Sudoku.Simple where

import Sudoku.Core
import Sudoku.Util

simpleSolver :: Solver
simpleSolver matrix
  | isFailed matrix = []
  | isCompleted matrix = [matrix]
  | otherwise = update matrix >>= simpleSolver

update :: Matrix Int -> [Matrix Int]
update (Matrix matrix) =
  [ Matrix $ left ++ [left' ++ [val] ++ right'] ++ right | val <- [1..9] ]
  where
    (left, fit:right) = break (any (== 0)) matrix
    (left', _:right') = break (== 0) fit
