module Main where

import Control.Applicative
import Control.Monad
import System.Environment

import Sudoku.Core
import Sudoku.Simple
import Sudoku.Util

import Actor

main :: IO ()
main = do
  [filepath] <- getArgs
  sudoku <- getSudoku filepath
  wait go sudoku
 where
  go :: Behavior (Matrix Int) [Matrix Int]
  go matrix = do
    self <- getSelf
    create solve (matrix, self)
    answers <- concat <$> replicateM 9 receive
    forM_ answers $ \answer -> do
      liftIO $ putStrLn $ show answer

solve :: Behavior (Matrix Int, ActorId [Matrix Int]) ()
solve (matrix, top)
  | isFailed matrix = return ()
  | isCompleted matrix = send top [matrix]
  | otherwise = do
    forM_ (update matrix) $ \matrix' -> do
      send top $ simpleSolver matrix'
