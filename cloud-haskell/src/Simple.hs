{-# LANGUAGE ScopedTypeVariables #-}

module Simple where

import Import

reply :: Process ()
reply = do
  (str :: String, pid) <- expect
  send pid str
--  reply


main :: Int -> IO ()
main port = do
  backend <- initializeBackend "127.0.0.1" (show port) initRemoteTable
  node <- newLocalNode backend
  pid <- forkProcess node reply
  runProcess node $ do
    self <- getSelfPid
    send pid ("hello", self)
    str <- expect
    liftIO $ putStrLn str
