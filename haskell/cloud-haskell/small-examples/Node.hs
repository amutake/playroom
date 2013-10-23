module Node where

import Network.Transport.TCP (createTransport, defaultTCPParameters)
import Control.Distributed.Process.Node

withLocalNode :: (LocalNode -> IO ()) -> IO ()
withLocalNode f = do
  t' <- createTransport "127.0.0.1" "10401" defaultTCPParameters
  case t' of
    Right t -> do
      node <- newLocalNode t initRemoteTable
      f node
      closeLocalNode node
    Left s -> error $ show s
