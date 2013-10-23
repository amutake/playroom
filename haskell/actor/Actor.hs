{-# LANGUAGE GeneralizedNewtypeDeriving, RankNTypes #-}

import Control.Concurrent
import Control.Applicative
import Control.Monad.IO.Class
import Control.Monad.State
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

type ActorId a = ThreadId

type Behavior a b = a -> ActorWorld b ()

type MailBox a = MVar [a]

execWorld :: MailBox r -> ActorWorld r a -> IO a
execWorld mbox world =
  runReaderT (unWorld world) mbox

emptyMailBox :: IO (MailBox a)
emptyMailBox = newEmptyMVar

create :: Behavior a r -> a -> IO (Actor r)
create bdef a = do
  mbox <- emptyMailBox
  forkIO $ execWorld mbox $ bdef a
  return $ Actor mbox

send :: Actor a -> a -> forall b. ActorWorld b ()
send actor msg = do
  mbox <- ask
  liftIO $ modifyMVar_ mbox $ \msgs ->
    return $ msg : msgs

bindMessage :: (r -> ActorWorld r ()) -> ActorWorld r ()
bindMessage f = do
  mbox <- ask
  msgs <- liftIO $ takeMVar mbox
  case msgs of
    [] -> error "bind error: empty"
    (msg : msgs) -> f msg

getSelf :: ActorWorld r (Actor r)
getSelf = do
  mbox <- ask
  return $ Actor mbox

factorial :: Behavior () (Int, Actor Int)
factorial () = bindMessage $ \(val, cust) ->
  if (val == 0)
    then send cust 1
    else do
      cont <- liftIO $ create factorialCont (val, cust)
      self <- getSelf
      send self (val - 1, cont)
      factorial ()

factorialCont :: Behavior (Int, Actor Int) Int
factorialCont (val, cust) =
  bindMessage $ \arg -> send cust (val * arg)

main :: IO ()
main = do
  fact <- create factorial ()
  e <- create end ()
  create (go fact e) ()
  return ()
 where
  go fact e () = do
    send fact (3, e)
  end () = bindMessage $ \result -> do
    liftIO $ print result
