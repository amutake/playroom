module Main (main) where

import Control.Applicative ((<$>))
import Control.Distributed.Process (Process, ProcessId, send, expect, getSelfPid, spawnLocal, liftIO)
import Control.Distributed.Process.Node (newLocalNode, initRemoteTable, runProcess)
import Control.Monad (forM_, replicateM)
import Network.Transport.TCP (createTransport, defaultTCPParameters)
import System.Environment (getArgs)

main :: IO ()
main = do
    (n : t : []) <- map read <$> getArgs
    Right transport <- createTransport "localhost" "12345" defaultTCPParameters
    localnode <- newLocalNode transport initRemoteTable
    runProcess localnode (master n t)

master :: Int -> Int -> Process ()
master n t = do
    rootId <- makeRing n t
    send rootId ()
    _unit <- expect :: Process ()
    liftIO $ putStrLn "finish"

makeRing :: Int -> Int -> Process ProcessId
makeRing n t = do
    me <- getSelfPid
    rootId <- spawnLocal $ root me t
    nodeIds <- replicateM (n - 1) $ spawnLocal node
    forM_ ((rootId : nodeIds) `zip` (nodeIds ++ [rootId])) $ \(id1, id2) -> send id1 id2
    return rootId

root :: ProcessId -> Int -> Process ()
root master times = do
    next <- expect
    loop next times
  where
    loop _ 0 = send master ()
    loop next t = do
        unit <- expect :: Process ()
        send next unit
        loop next (t - 1)

node :: Process ()
node = do
    next <- expect
    loop next
  where
    loop next = do
        unit <- expect :: Process ()
        send next unit
        loop next
