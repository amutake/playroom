{-# LANGUAGE TemplateHaskell, DeriveGeneric, DeriveDataTypeable #-}

import Import hiding (newLocalNode)
import Control.Distributed.Process.Node (newLocalNode)

data Message = Ping ProcessId
             | Pong ProcessId
             deriving (Typeable)

instance Binary Message where
  put (Ping pid) = putWord8 0 >> put pid
  put (Pong pid) = putWord8 1 >> put pid
  get = do
    n <- getWord8
    case n of
      0 -> Ping <$> get
      1 -> Pong <$> get
      _ -> error "Binary Message"

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
  Right t <- createTransport "localhost" "12345" defaultTCPParameters
  node <- newLocalNode t $ __remoteTable initRemoteTable
  runProcess node master
  liftIO $ threadDelay 400000
