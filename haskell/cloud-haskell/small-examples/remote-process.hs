{-# LANGUAGE TemplateHaskell, ScopedTypeVariables #-}

-- exec: ./remote-process.sh

import Import

import Control.Concurrent (threadDelay)
import Control.Monad
import System.Environment

echo :: Process ()
echo = do
  (str :: String, pid) <- expect
  say $ "got: " ++ str
  send pid str
  terminate

remotable ['echo] -- 必要

master :: Backend -> [NodeId] -> Process ()
master backend slaves = do
  say $ "slaves: " ++ show slaves
  pids <- forM slaves $ \node -> spawn node $(mkStaticClosure 'echo)
  say $ "pids: " ++ show pids
  self <- getSelfPid
  forM_ pids $ \pid -> send pid ("hello", self)
  recv (length pids)
  terminateAllSlaves backend
  where
    recv 0 = say "all received"
    recv n = do
      str :: String <- expect
      say $ "recv: " ++ str
      recv (n - 1)

main :: IO ()
main = do
  args <- getArgs
  let rtable = __remoteTable initRemoteTable -- 必要
  case args of
    ["master", host, port] -> do
      liftIO $ threadDelay 100000
      backend <- initializeBackend host port rtable
      startMaster backend (master backend)
    ["slave", host, port] -> do
      backend <- initializeBackend host port rtable
      startSlave backend
