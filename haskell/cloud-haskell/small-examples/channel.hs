import Import

slave :: SendPort String -> Process ()
slave sp = do
  sendChan sp "hello!"

master :: Process ()
master = do
  (sp, rp) <- newChan
  replicateM_ 10 $ spawnLocal (slave sp)
  replicateM_ 10 $ do
    str <- receiveChan rp
    say str


main :: IO ()
main = do
  Right t <- createTransport "localhost" "12345" defaultTCPParameters
  node <- newLocalNode t initRemoteTable
  runProcess node master
  liftIO $ threadDelay 100000
