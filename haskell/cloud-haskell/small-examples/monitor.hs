import Import

slave :: Process ()
slave = do
  liftIO $ threadDelay 500000
  liftIO $ print (1 `div` 0)
  say "no exeption happened"
  slave

master :: Int -> Process ()
master 0 = return ()
master n = do
  pid <- spawnLocal slave
  monitor pid
  ProcessMonitorNotification _ _ reason <- expect
  say $ show reason
  master (n - 1)

main :: IO ()
main = do
  Right t <- createTransport "localhost" "12345" defaultTCPParameters
  node <- newLocalNode t initRemoteTable
  runProcess node (master 5)
  liftIO $ threadDelay 1000
