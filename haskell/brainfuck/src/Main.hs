{-# LANGUAGE ConstraintKinds
  , FlexibleContexts
  , TypeFamilies
  #-}

module Main where

import Prelude hiding (lookup)
import Control.Effect hiding (State)
import Data.Char (chr, ord)
import Data.IntMap hiding (map)
import Safe (atMay)
import System.IO

type Stack = [Int]
type Offset = Int
type Pointer = Int
type Memory = IntMap Int
type State = (Offset, Pointer, Memory, Stack)

brainfuck :: (EffectLift IO es, EffectState State es, EffectReader String es)
          => Effect es ()
brainfuck = do
    code <- ask
    (offset, pointer, memory, stack) <- get
    case code `atMay` offset of
        Nothing -> return ()
        Just '>' -> nextWith (succ offset, succ pointer, memory, stack)
        Just '<' -> nextWith (succ offset, pred pointer, memory, stack)
        Just '+' -> nextWith (succ offset, pointer, insertWith (+) pointer 1 memory, stack)
        Just '-' -> nextWith (succ offset, pointer, insertWith (+) pointer (-1) memory, stack)
        Just '.' -> do
            lift $ putStr [chr $ findWithDefault 0 pointer memory]
            nextWith (succ offset, pointer, memory, stack)
        Just ',' -> do
            c <- lift getChar
            nextWith (succ offset, pointer, insert pointer (ord c) memory, stack)
        Just '[' -> case lookup pointer memory of
            Just v | v /= 0 -> nextWith (succ offset, pointer, memory, offset : stack)
            _ -> nextWith (jumpPoint (offset + 1) code, pointer, memory, stack)
        Just ']' -> case stack of
            [] -> error "null stack"
            (o:stack') -> nextWith (o, pointer, memory, stack')
        Just _ -> nextWith (succ offset, pointer, memory, stack)
  where
    nextWith st = put st >> brainfuck
    jumpPoint offset code = jumpPoint' offset code (0 :: Int)
    jumpPoint' offset code n = case code `atMay` offset of
        Nothing -> error "invalid"
        Just ']' -> if n == 0 then succ offset else jumpPoint' (succ offset) code (n - 1)
        Just '[' -> jumpPoint' (succ offset) code (n + 1)
        Just _ -> jumpPoint' (succ offset) code n


runBrainfuck :: String -> IO ((), State)
runBrainfuck = runLift . runState (0, 0, empty, []) . flip runReader brainfuck

printState :: State -> IO ()
printState (offset, pointer, memory, stack) = putStrLn $ concat
    [ "offset: ", show offset, "\n"
    , "pointer: ", show pointer, "\n"
    , "memory: ", "\n" ++ showMemory memory
    , "stack: ", show stack
    ]
  where
    showKV (k, v) = "  " ++ show k ++ ": " ++ show v
    showMemory = unlines . map showKV . toList

main :: IO ()
main = do
    hSetBuffering stdout NoBuffering
    putStr "code> "
    hFlush stdout
    code <- getLine
    ((), st) <- runBrainfuck code
    putStrLn ""
    printState st
