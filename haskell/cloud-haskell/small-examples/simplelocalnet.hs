import Import hiding (newLocalNode)
import Control.Distributed.Process.Backend.SimpleLocalnet (newLocalNode)

main :: IO ()
main = do
  backend <- initializeBackend "localhost" "12345" initRemoteTable
  node <- newLocalNode backend
  findPeers backend 1000000 >>= print
  threadDelay 100000
