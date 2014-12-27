module Main where

import Control.Concurrent
import Control.Concurrent.Chan.Unagi

main :: IO ()
main = do
    (i, o) <- newChan


cmap :: (a -> b) -> OutChan a -> IO (OutChan b)
cmap f o = do
    (i', o') <- newChan
    forkIO $ loop i'
    return o'
  where
    loop i = do
        a <- readChan o
        writeChan (f a)
