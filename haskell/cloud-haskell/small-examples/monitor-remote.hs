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
    ["a", host, port, addr] -> do
      Right transport <- createTransport host port defaultTCPParameters
      localnode <- newLocalNode transport initRemoteTable
      runProcess localnode (procA $ readNodeId addr)
    ["b", host, port] -> do
      Right transport <- createTransport host port defaultTCPParameters
      localnode <- newLocalNode transport initRemoteTable
      putStrLn $ "addr: " ++ show (nodeAddress $ localNodeId localnode)
      runProcess localnode procB

procA :: NodeId -> Process ()
procA nid = do
  whereisRemoteAsync nid "b"
  WhereIsReply _ (Just pid) <- expect
  monitor pid
--  send pid (0 :: Int)
  ProcessMonitorNotification _ _ reason <- expect
  say $ show reason
  liftIO $ threadDelay 1000

procB :: Process ()
procB = do
  self <- getSelfPid
  register "b" self
  n <- expect :: Process Int
  say $ "let's 1 div " ++ show n
  say $ show $ 1 `div` n
