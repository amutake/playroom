{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Concurrent
import System.Process
import System.IO

main :: IO ()
main = do
    (inp, out, err, pid) <- runInteractiveProcess "/usr/local/bin/coqtop" ["-emacs"] Nothing Nothing
    -- hGetBuffering inp >>= print
    -- hGetBuffering out >>= print
    hSetBuffering inp NoBuffering
    hSetBuffering out NoBuffering
    hSetBuffering stdin NoBuffering
    hSetBuffering stdout NoBuffering
    hPutStrLn inp "Goal forall n m : nat, n + m = m + n."
    hIsReadable out >>= print
    hGetLine out >>= putStrLn
    hIsReadable out >>= print
    putStrLn "hoge"
    hPutStrLn inp "Proof. intros."
    hFlush inp
    hIsOpen out >>= print
    hGetContents out >>= putStrLn
    hIsOpen out >>= print
    -- hFlush inp
    -- hFlush out
    -- _ <- forkIO (fixIO $ \_ -> do
    --                   hGetContents out >>= putStrLn
    --                   hGetContents err >>= putStrLn
    --             )
    -- loop inp out err
    -- terminateProcess pid
  where
    loop inp out err = do
        putStr "coqtop> "
        command <- getLine
        if command == "Quit." then return () else do
            hPutStrLn inp command
            loop inp out err
