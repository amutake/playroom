{-# LANGUAGE TemplateHaskell, DeriveGeneric, DeriveDataTypeable #-}

module Main where

import Data.Binary
import Data.Typeable
import GHC.Generics

import Network.Transport.TCP (createTransport, defaultTCPParameters)
import Control.Distributed.Process
import Control.Distributed.Process.Node

data Ping = Ping ProcessId deriving (Typeable, Generic)
data Pong = Pong ProcessId deriving (Typeable, Generic)

instance Binary Ping
instance Binary Pong

ping :: Process ()
ping = do
  Pong partner <- expect
  say "got pong"
  self <- getSelfPid
  send partner (Ping self)

pong :: Process ()
pong = do
  Ping partner <- expect
  say "got ping"
  self <- getSelfPid
  send partner (Pong self)
  pong

main :: IO ()
main = do
  Right t <- createTransport "127.0.0.1" "10401" defaultTCPParameters
  node <- newLocalNode t initRemoteTable

  pingId <- forkProcess node ping
  pongId <- forkProcess node pong

  runProcess node $ do
    send pongId (Ping pingId)
