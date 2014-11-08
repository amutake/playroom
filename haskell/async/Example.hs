module Main where

import Control.Concurrent.Async
import Control.Monad.IO.Class

data Future a = Future (IO (Async a))

instance Monad Future where
    return a = Future (async (return a))
    (>>=) :: Future a -> (a -> Future b) -> Future b
    (Future io) >>= f = do

instance MonadIO Future where

future :: IO a -> Future a
future io = Future

await :: Future a -> IO a
await fu = undefined

example :: IO ()
example = await $ do
    -- api1 and api2 run concurrently
    a <- future $ api1 "hoge"
    b <- future $ api2 "fuga"
    -- api3 waits api1 and api2 are finished
    c <- future $ api3 (a, b)
    liftIO $ print c
  where
    api1 :: String -> IO String
    api1 = undefined
    api2 :: String -> IO String
    api2 = undefined
    api3 :: (String, String) -> IO Int
    api3 = undefined
