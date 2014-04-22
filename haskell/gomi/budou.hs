module Main where

import Control.Monad
import Data.List

import Debug.Trace

newtype Budou = Budou [[Int]]

instance Show Budou where
    show (Budou xss) = intercalate "\n" $ map showLine $ zip [0..] xss
      where
        showLine (n, xs) = replicate n ' ' ++ intercalate " " (map show xs)

noseru :: Budou -> [Int] -> Budou
noseru (Budou xss) xs = Budou $ xs : xss

down :: [Int] -> Budou
down [] = error "unexpected"
down [x] = Budou [[x]]
down xs = noseru (down (next xs)) xs
  where
    next :: [Int] -> [Int]
    next [] = undefined
    next [x] = undefined
    next (x:y:[]) = [abs $ x - y]
    next (x:y:xs) = abs (x - y) : next (y:xs)

valid :: Budou -> Bool
valid (Budou xss) = [1 .. (sum [1..(length xss)])] == xs
  where
    xs = sort $ concat xss

calc :: Int -> [Budou]
calc n = calc' [1..(sum [1..n])]
  where
    calc' xs = do
        ys <- filter (\ys -> length ys == n) $ subsequences xs
        zs <- permutations ys
        let budou = down zs
        guard $ valid budou
        return budou

main :: IO ()
main = do
    mapM_ print $ calc 5
