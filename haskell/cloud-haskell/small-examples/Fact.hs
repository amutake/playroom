{-# LANGUAGE TemplateHaskell, ScopedTypeVariables #-}

module Fact where

import Import

-- カリー化していると、
--   $(mkClosure 'factCont) :: Int -> Closure (ProcessId -> Process ())
-- となって、
--   Closure (a -> b) -> a -> Closure b
-- みたいな関数はないのでできない。
--
--   closureApply :: Closure (a -> b) -> Closure a -> Closure b
--   staticClosure :: Static a -> Closure a
--   staticLable :: String -> Static a
-- はある。
factCont :: (Int, ProcessId) -> Process ()
factCont (n, pid) = do
  acc <- expect
  say $ "got: " ++ show acc
  send pid (acc * n)

-- remotable ['factCont]

fact :: Process ()
fact = do
  (n :: Int, pid) <- expect
  say $ "got: " ++ show (n, pid)
  if (n == 0)
    then send pid (1 :: Int)
    else do
      -- node <- getSelfNode
      -- cont <- spawn node $ $(mkClosure 'factCont) (n, pid)
      cont <- spawnLocal (factCont (n, pid))
      self <- getSelfPid
      send self (n - 1, cont)
      fact

main' :: Int -> IO ()
main' port = do
  backend <- initializeBackend "127.0.0.1" (show port) initRemoteTable
  node <- newLocalNode backend
  pid <- forkProcess node fact
  runProcess node $ do
    self <- getSelfPid
    send pid (5 :: Int, self)
    n :: Int <- expect
    say $ "fact 5 is " ++ show n

main :: IO ()
main = main' 12345
