import Import hiding (newLocalNode)

import Control.Distributed.Process.Backend.SimpleLocalnet (newLocalNode)

import System.Environment

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["master", host, port] -> do
      backend <- initializeBackend host port initRemoteTable
      startMaster backend (const (loop backend))
    ["slave", host, port] -> do
      backend <- initializeBackend host port initRemoteTable
      startSlave backend

loop :: Backend -> Process ()
loop backend = do
  liftIO $ threadDelay $ 1000 * 1000
  pids <- findSlaves backend
  say $ unlines $ map show pids
  loop backend
