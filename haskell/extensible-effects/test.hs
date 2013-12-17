{-# LANGUAGE FlexibleContexts
  , TypeOperators
  , DeriveDataTypeable
  , ConstraintKinds
  , FlexibleInstances
  , MultiParamTypeClasses
  , UndecidableInstances #-}
import Control.Eff
import Control.Eff.Exception
import Control.Eff.Lift
import Control.Eff.Reader.Lazy
import Control.Failure
import Data.ByteString (ByteString) -- Lazy (ByteString)
import Data.Conduit
import Data.Typeable
import Control.Monad.IO.Class (MonadIO (..))

import Network.HTTP.Conduit
import System.Environment (getArgs)

instance (Typeable e, Member (Exc e) r) => Failure e (Eff r) where
  failure = throwExc

data Env = Env
  { envUrl :: String
  } deriving (Show, Typeable)

type AppClass m r = ( Typeable1 m
                    , MonadResource m
                    , MonadBaseControl IO m
                    , Member (Reader Env) r
                    , Member (Exc HttpException) r
                    , Member (Lift m) r
                    , SetMember Lift (Lift m) r
                    )

type App m = Eff ((Exc HttpException) :> (Reader Env) :> (Lift m) :> ())

sendRequest :: AppClass m r
            => Eff r Int
sendRequest = do
  req <- ask >>= parseUrl . envUrl
  lift $ withManager $ \man -> do
    res <- http req man
    responseBody res $$+- sinkChunkLength 0

sinkChunkLength :: MonadResource m => Int -> Sink ByteString m Int
sinkChunkLength n = do
  bs <- await
  case bs of
    Just _ -> sinkChunkLength (n + 1)
    Nothing -> return n

runApp :: (Typeable1 m, MonadIO m)
       => Env
       -> App m a
       -> m (Either HttpException a)
runApp env = runLift . flip runReader env . runExc

main :: IO ()
main = do
  (url : _) <- getArgs
  bs <- runResourceT $ runApp (Env url) sendRequest
  print bs
