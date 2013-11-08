import Control.Applicative ((<$>))
import System.Environment (getArgs)

import Actor

factorial :: Behavior () (Int, ActorId Int)
factorial () = do
  (val, cust) <- receive
  if (val == 0)
    then send cust 1
    else do
      cont <- create factorialCont (val, cust)
      self <- getSelf
      send self (val - 1, cont)
      factorial ()

factorialCont :: Behavior (Int, ActorId Int) Int
factorialCont (val, cust) = do
  arg <- receive
  send cust (val * arg)

main :: IO ()
main = do
  n <- read . head <$> getArgs :: IO Int
  fact <- createIO factorial ()
  wait go (fact, n)
 where
  go (fact, n) = do
    self <- getSelf
    send fact (n, self)
    result <- receive
    liftIO $ print result
