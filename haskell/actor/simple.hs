module Main where

import System.Environment

import Sudoku.Simple
import Sudoku.Util

main :: IO ()
main = do
  [filepath] <- getArgs
  sudoku <- getSudoku filepath
  let answers = simpleSolver sudoku
  mapM_ print answers
