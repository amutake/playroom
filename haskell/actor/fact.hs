import Control.Applicative ((<$>))
import Control.Concurrent (threadDelay)
import Control.Monad.IO.Class (liftIO)
import System.Environment (getArgs)

import Actor

factorial :: Behavior () (Int, ActorId Int)
factorial () = binder $ \(val, cust) ->
  if (val == 0)
    then send cust 1
    else do
      cont <- create factorialCont (val, cust)
      self <- getSelf
      send self (val - 1, cont)
      factorial ()

factorialCont :: Behavior (Int, ActorId Int) Int
factorialCont (val, cust) =
  binder $ \arg -> send cust (val * arg)

main :: IO ()
main = do
  n <- read . head <$> getArgs :: IO Int
  fact <- createIO factorial ()
  e <- createIO end ()
  createIO (go fact e n) ()
  threadDelay 100000
 where
  go fact e n () = send fact (n, e)
  end () = binder $ \result -> do
    liftIO $ print result
