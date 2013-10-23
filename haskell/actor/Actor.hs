{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import Control.Concurrent
import Control.Applicative
import Control.Monad.IO.Class
import Control.Monad.State

data Actor = Actor
  { threadId :: ThreadId
  , mailBox :: MVar [Message]
  , actorName :: Name
  }

newtype ActorWorld a = ActorWorld
  { unWorld :: StateT Name IO a
  } deriving
  ( Functor
  , Applicative
  , Monad
  , MonadIO
  )

newtype Message = Message Name

newtype Name = Name Int

instance Show Name where
  show (Name n) = "name" ++ show n

create :: ActorWorld () -> ActorWorld Actor
create world = do
  tid <- liftIO $ forkIO $ unWorld world
  mvar <- liftIO newEmptyMVar
  name <- getNewName
  return (Actor tid mvar name)
 where
  getNewName = do
    Name n <- get
    put $ Name $ n + 1
    return (Name n)

become :: ActorWorld a
become = id

send :: Name -> Message -> ActorWorld ()
send name msg = do

-- receive :: ActorWorld Message
-- receive = do
--   actor <- ask
--   takeMVar $ mailBox actor
