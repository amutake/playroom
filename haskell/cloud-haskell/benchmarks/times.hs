{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Applicative
import Control.Concurrent
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Network.Transport.TCP
import System.Environment

main :: IO ()
main = do
  (n : []) <- map read <$> getArgs
  Right transport <- createTransport "localhost" "12345" defaultTCPParameters
  localnode <- newLocalNode transport initRemoteTable
  runProcess localnode $ master n

master :: Int -> Process ()
master n = do
  aid <- spawnLocal actorA
  bid <- spawnLocal actorB
  send aid ((0, bid) :: (Int, ProcessId))
  liftIO $ threadDelay $ n * 1000 * 1000
  self <- getSelfPid
  send aid self
  n' <- expect :: Process Int
  liftIO $ print n'

actorA :: Process ()
actorA = do
  receiveWait
    [ match $ \(n :: Int, bid) -> do
         self <- getSelfPid
         send bid (n + 1, self)
         actorA
    , match $ \mid -> do
         (n, _) <- expect :: Process (Int, ProcessId)
         send mid n
    ]

actorB :: Process ()
actorB = do
  (n, aid) <- expect :: Process (Int, ProcessId)
  self <- getSelfPid
  send aid (n + 1, self)
  actorB
