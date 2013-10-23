import Import

slave :: Process ()
slave = do
  liftIO $ threadDelay 1000000
  say "疲れた。。。"
  terminate

master :: Int -> Process ()
master 0 = return ()
master n = do
  pid <- spawnLocal slave
  monitor pid
  _ <- expect :: Process ProcessMonitorNotification
  say $ "あと" ++ show (n - 1) ++ "回がんばれ"
  master (n - 1)

main :: IO ()
main = do
  Right t <- createTransport "localhost" "12345" defaultTCPParameters
  node <- newLocalNode t initRemoteTable
  runProcess node (master 5)
  liftIO $ threadDelay 1000000
