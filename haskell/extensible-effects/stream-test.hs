{-# LANGUAGE TypeOperators
  #-}

import Control.Monad
import Data.Char

import Control.Eff
import Control.Eff.Lift

import Stream

main :: IO ()
main = do
  let src = produce ([1..10] :: [Int]) :: Eff (Yield Int :> ()) ()
      con = mapS ((* 2) :: Int -> Int) :: Eff (Await Int :> Yield Int :> ()) ()
      snk = consume :: Eff (Await Int :> ()) [Int]
      eff = run $ src |==| con |==| snk
  print eff

main' :: IO ()
main' = runLift $ src |==| con |==| snk
  where
    src :: Eff (Yield Char :> Lift IO :> ()) ()
    src = do
      str <- lift getLine
      produce str
    con :: Eff (Await Char :> Yield Int :> ()) ()
    con = mapS ord
    snk :: Eff (Await Int :> Lift IO :> ()) ()
    snk = do
      n <- await :: Eff (Await Int :> Lift IO :> ()) (Maybe Int)
      case n of
        Just n' -> lift (print n') >> snk
        Nothing -> return ()
