{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Actor
  ( ActorId
  , ActorWorld
  , Behavior
  , create
  , createIO
  , send
  , binder
  , vectBinder
  , getSelf
  , liftIO
  , wait
  , expect
  ) where

import Control.Concurrent
import Control.Concurrent.STM
import Control.Applicative
import Control.Monad.IO.Class
import Control.Monad.Reader

data ActorId r = ActorId
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

type Behavior a b = a -> ActorWorld b ()

type MailBox a = TQueue a

createIO :: Behavior a r -> a -> IO (ActorId r)
createIO bdef a = do
  mbox <- newTQueueIO
  forkIO $ execWorld mbox $ bdef a
  return $ ActorId mbox
 where
  execWorld mbox world =
    runReaderT (unWorld world) mbox

create :: Behavior a r -> a -> ActorWorld b (ActorId r)
create bdef = liftIO . createIO bdef

send :: ActorId a -> a -> ActorWorld b ()
send actor msg = do
  let mbox = mailBox actor
  liftIO $ atomically $ writeTQueue mbox msg

binder :: (r -> ActorWorld r ()) -> ActorWorld r ()
binder f = expect >>= f

vectBinder :: Int -> ([r] -> ActorWorld [r] ()) -> ActorWorld [r] ()
vectBinder n f = replicateM n expect >>= f . concat

expect :: ActorWorld r r
expect = ask >>= liftIO . atomically . readTQueue

getSelf :: ActorWorld r (ActorId r)
getSelf = do
  mbox <- ask
  return $ ActorId mbox

wait :: Behavior a r -> a -> IO ()
wait bdef a = do
  tvar <- newTVarIO False
  createIO (putKillSign tvar) ()
  wait' tvar
 where
  putKillSign tvar _ = do
    bdef a
    liftIO $ atomically $ writeTVar tvar True
  wait' tvar = atomically $ do
    r <- readTVar tvar
    case r of
      True -> return ()
      False -> retry
