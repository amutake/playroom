{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Actor
  ( Actor
  , ActorWorld
  , Behavior
  , create
  , send
  , binder
  , getSelf
  ) where

import Control.Concurrent
import Control.Concurrent.STM
import Control.Applicative
import Control.Monad.IO.Class
import Control.Monad.Reader

data Actor r = Actor
  { mailBox :: MailBox r
  }

newtype ActorWorld r a = ActorWorld
  { unWorld :: ReaderT (MailBox r) IO a
  } deriving
  ( Functor
  , Applicative
  , Monad
  , MonadIO
  , MonadReader (MailBox r)
  )

-- type ActorId a = ThreadId

type Behavior a b = a -> ActorWorld b ()

type MailBox a = TQueue a

execWorld :: MailBox r -> ActorWorld r a -> IO a
execWorld mbox world =
  runReaderT (unWorld world) mbox

emptyMailBox :: IO (MailBox a)
emptyMailBox = newTQueueIO

create :: Behavior a r -> a -> IO (Actor r)
create bdef a = do
  mbox <- emptyMailBox
  forkIO $ execWorld mbox $ bdef a
  return $ Actor mbox

send :: Actor a -> a -> ActorWorld b ()
send actor msg = do
  let mbox = mailBox actor
  liftIO $ atomically $ writeTQueue mbox msg

binder :: (r -> ActorWorld r ()) -> ActorWorld r ()
binder f = do
  mbox <- ask
  msg <- liftIO $ atomically $ readTQueue mbox
  f msg

getSelf :: ActorWorld r (Actor r)
getSelf = do
  mbox <- ask
  return $ Actor mbox
