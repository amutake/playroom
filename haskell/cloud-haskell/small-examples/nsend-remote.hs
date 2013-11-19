import Import
import Control.Distributed.Process.Internal.Types
import Data.ByteString.Char8 (pack)
import Network.Transport hiding (send)
import System.Environment


readNodeId :: String -> NodeId
readNodeId = NodeId . EndPointAddress . pack

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["ping", host, port, addr] -> do
      Right transport <- createTransport host port defaultTCPParameters
      localnode <- newLocalNode transport initRemoteTable
      runProcess localnode (ping $ readNodeId addr)
    ["pong", host, port] -> do
      Right transport <- createTransport host port defaultTCPParameters
      localnode <- newLocalNode transport initRemoteTable
      putStrLn $ "addr: " ++ show (nodeAddress $ localNodeId localnode)
      runProcess localnode pong

ping :: NodeId -> Process ()
ping nid = do
  self <- getSelfPid
  registerRemoteAsync nid "ping" self
  reply <- expect :: Process RegisterReply
  say $ show reply
  -- whereisRemoteAsync nid "pong"
  -- reply' <- expect :: Process WhereIsReply
  -- say $ show reply'
  nsendRemote nid "pong" ("ping", self)
  ("pong", pid) <- expect :: Process (String, ProcessId)
  say $ show pid
  liftIO $ threadDelay 10000

pong :: Process ()
pong = do
  self <- getSelfPid
  register "pong" self
  ("ping", pid) <- expect :: Process (String, ProcessId)
  -- send pid ("pong", self)
  nsend "ping" ("pong", self)
