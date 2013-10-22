{-# LANGUAGE TemplateHaskell, DeriveGeneric, DeriveDataTypeable #-}

module PingPong where

import Data.Binary
import Data.Typeable
import GHC.Generics

import Control.Distributed.Process
import Control.Distributed.Process.Closure
import Control.Distributed.Process.Node
import Control.Distributed.Process.Serializable

import Node

data Message = Ping ProcessId
             | Pong ProcessId
             deriving (Typeable, Generic)

instance Binary Message

pingServer :: Process ()
pingServer = do
  Ping from <- expect
  say $ "ping received from " ++ show from
  self <- getSelfPid
  send from (Pong self)

remotable ['pingServer]

master :: Process ()
master = do
  node <- getSelfNode

  say $ "spawning on " ++ show node
  pid <- spawn node $(mkStaticClosure 'pingServer)

  self <- getSelfPid
  say $ "sending ping to " ++ show pid
  send pid (Ping self)

  Pong _ <- expect
  say "pong."

  terminate

main :: IO ()
main = do
  withLocalNode $ \node -> do
    forkProcess node master
    return ()
