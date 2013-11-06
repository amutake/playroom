module Main where

import Actor

import Data.List
import Data.List.Split
import Control.Applicative
import Control.Concurrent
import Control.Monad
import System.Environment

type Matrix a = [[a]]

-- input example:
-- 8 0 0 0 0 0 0 0 0
-- 0 0 3 6 0 0 0 0 0
-- 0 7 0 0 9 0 2 0 0
-- 0 5 0 0 0 7 0 0 0
-- 0 0 0 0 4 5 7 0 0
-- 0 0 0 1 0 0 0 3 0
-- 0 0 1 0 0 0 0 6 8
-- 0 0 8 5 0 0 0 1 0
-- 0 9 0 0 0 0 4 0 0

main :: IO ()
main = do
  [filepath] <- getArgs
  sudoku <- map (map read) . map words . lines <$> readFile filepath
  wait go sudoku
  where
    go :: Behavior (Matrix Int) [Matrix Int]
    go sudoku = do
      self <- getSelf
      create solve (sudoku, self)
      binder $ \answers -> do
        liftIO $ mapM_ (mapM_ (putStrLn . unwords . map show)) answers

solve :: Behavior (Matrix Int, ActorId [Matrix Int]) [Matrix Int]
solve (matrix, aid)
  | isFailed matrix = send aid []
  | isCompleted matrix = send aid [matrix]
  | otherwise = do
    self <- getSelf
    forM_ (update matrix) $ \matrix' -> create solve (matrix', self)
    vectBinder 9 $ \matrixes -> do
      send aid matrixes

isFailed :: Matrix Int -> Bool
isFailed matrix = anyDup [matrix, transpose matrix, box matrix]
  where
    anyDup = any (any (duplicate . filter (/= 0)))
    box = map concat . concat . map (chunksOf 3) . transpose . map (chunksOf 3)

isCompleted :: Matrix Int -> Bool
isCompleted = all (all (/= 0))

update :: Matrix Int -> [Matrix Int]
update matrix =
  [left ++ [left' ++ [val] ++ right'] ++ right | val <- [1..9]]
  where
    (left, fit:right) = break (any (== 0)) matrix
    (left', _:right') = break (== 0) fit

duplicate :: Eq a => [a] -> Bool
duplicate [] = False
duplicate (x:xs) = elem x xs || duplicate xs