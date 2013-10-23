import Import

sum10 :: Process ()
sum10 = do
  result <- sum <$> mapM (const expect) [1..10] :: Process Int
  say $ "result: " ++ show result
  sum10

master :: Process ()
master = do
  pid <- spawnLocal sum10
  register "sum10" pid

sendN :: Int -> Process ()
sendN = nsend "sum10"

main :: IO ()
main = do
  Right t <- createTransport "localhost" "12345" defaultTCPParameters
  node <- newLocalNode t initRemoteTable
  runProcess node master
  forM_ [1..30] $ runProcess node . sendN -- 違うプロセスモナドでもちゃんと登録されている
  liftIO $ threadDelay 400000
