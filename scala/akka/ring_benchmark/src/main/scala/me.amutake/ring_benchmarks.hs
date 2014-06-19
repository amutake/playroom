module Main where

import Control.Concurrent(threadDelay)
import Control.Applicative
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Control.Monad
import Network.Transport.TCP
import System.Environment

main :: IO ()
main = do
    (n : t : []) <- map read <$> getArgs
    Right transport <- createTransport "localhost" "12345" defaultTCPParameters
    localnode <- newLocalNode transport initRemoteTable
    runProcess localnode (master n t)

master :: Int -> Int -> Process ()
master n t = do
    self <- getSelfPid
    rootId <- makeRing n t self
    send rootId ()
    unit <- expect :: Process ()
    liftIO $ print unit

makeRing :: Int -> Int -> ProcessId -> Process ProcessId
makeRing n t mid = do
    pids <- replicateM n $ spawnLocal node
    rootId <- spawnLocal $ root mid t
    send rootId (pids ++ [rootId])
    return rootId

root :: ProcessId -> Int -> Process ()
root mid times = do
    (pid : pids) <- expect
    send pid pids
    [] <- expect :: Process [ProcessId]
    loop pid times
  where
    loop _ 0 = send mid ()
    loop pid t = do
        unit <- expect :: Process ()
        send pid unit
        loop pid (t - 1)

node :: Process ()
node = do
    (pid:pids) <- expect
    send pid pids
    loop pid
  where
    loop pid = do
        unit <- expect :: Process ()
        send pid unit
        loop pid
