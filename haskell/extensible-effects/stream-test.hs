{-# LANGUAGE TypeOperators
  , IncoherentInstances
  , ScopedTypeVariables
  #-}

import Control.Monad
import Data.Char

import Control.Eff
import Control.Eff.Lift
import Control.Eff.Writer.Lazy

import Stream

main :: IO ()
main = putStrLn $ run $ src |==| next |==| sink
  where
    src :: Eff (Yield Char :> ()) ()
    src = produce "HelloWorld"
    next :: Eff (Await Char :> Yield Char :> ()) ()
    next = mapS (chr . (+ 1) . ord)
    sink :: Eff (Await Char :> ()) String
    sink = consume

main' :: IO ()
main' = runLift $ src |==| mapper |==| sink
  where
    src :: Eff (Yield Char :> ()) ()
    src = produce "hello"
    mapper :: Eff (Await Char :> Yield Int :> ()) ()
    mapper = mapS ord
    sink :: Eff (Await Int :> Lift IO :> ()) ()
    sink = awaitForever $ \i -> lift $ print (i :: Int)

main'' :: IO ()
main'' = putStrLn $ snd $ run $ runMonoidWriter $ src |==| log |==| sink
  where
    src :: Eff (Yield Char :> ()) ()
    src = produce "Hello, World!"
    log :: Eff (Await Char :> Yield Char :> Writer String :> ()) ()
    log = awaitForever $ \i -> tell (show (i :: Char)) >> yield i
    sink :: Eff (Await Char :> ()) [Char]
    sink = consume
