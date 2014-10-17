{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# OPTIONS_GHC -fno-warn-unused-do-bind #-}

module TypedActor where

import Control.Applicative
import Control.Concurrent
import Control.Concurrent.STM.TQueue
import Control.Monad.IO.Class
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.STM

newtype Behavior t = Behavior (t -> Actor t ())

newtype Actor t a = Actor (StateT (Behavior t) (ReaderT (ActorId t) IO) a)
  deriving (Functor, Applicative, Monad, MonadReader (ActorId t), MonadState (Behavior t), MonadIO)

type ActorId t = TQueue t

stm :: STM a -> Actor t a
stm = liftIO . atomically

(!) :: ActorId t -> t -> Actor s ()
actorId ! msg = stm $ writeTQueue actorId msg

self :: Actor t (ActorId t)
self = ask

become :: Behavior t -> Actor t ()
become = put

newIO :: Behavior t -> IO (ActorId t)
newIO behavior = do
    queue <- newTQueueIO
    forkIO $ flip runReaderT queue $ flip evalStateT behavior $ extractActor loop
    return queue
  where
    loop = do
      (Behavior f) <- get
      queue <- ask
      msg <- stm $ readTQueue queue
      f msg
      loop
    extractActor (Actor c) = c

new :: Behavior t -> Actor s (ActorId t)
new = liftIO . newIO

start :: Behavior t -> t -> IO ()
start behavior initialValue = do
    actorId <- newIO behavior
    atomically $ writeTQueue actorId initialValue

pingpong :: IO ()
pingpong = start pingpongBeh ()
  where
    pingpongBeh = Behavior $ \() -> do
        pongId <- new pong
        pingId <- new (ping pongId)
        pingId ! ""

ping :: ActorId (String, ActorId String) -> Behavior String
ping pongId = Behavior $ \str -> do
    liftIO $ putStrLn str
    liftIO $ threadDelay 3000000
    me <- self
    pongId ! (str ++ "ping", me)

pong :: Behavior (String, ActorId String)
pong = Behavior $ \(str, pingId) -> do
    liftIO $ putStrLn str
    pingId ! (str ++ "pong")

main :: IO ()
main = do
    pingpong
    threadDelay 20000000
