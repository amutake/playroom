{-# LANGUAGE FlexibleContexts, TypeOperators #-}

import Control.Eff
import Control.Eff.Fresh
import Control.Eff.Lift
import Control.Eff.Trace
import Control.Eff.Reader.Lazy
import Control.Eff.Writer.Lazy
import Control.Monad

type TyA = Fresh Int :> Trace :> ()

action :: (Member Trace r, Member (Fresh Int) r) => Eff r ()
action = do
  n <- fresh
  trace $ show (n :: Int)

action2 :: (Member (Reader Char) r, Member (Writer String) r) => Eff r ()
action2 = do
  c <- ask
  tell ([c, c, c] :: String)

action3 :: (Member (Fresh Char) r, Member (Writer String) r) => Eff r ()
action3 = do
  c <- fresh
  tell ([c, c, c] :: String)

main :: IO ()
main = do
  runTrace $ flip runFresh (0 :: Int) $ do
    replicateM_ 3 action
  let (w, ()) = run $ flip runReader '2' $ runMonoidWriter $ replicateM_ 3 action2
  putStrLn w
  let (w', ()) = run $ runMonoidWriter $ runReader (replicateM_ 3 action2) '2'
  putStrLn w'
  let (w'', ()) = run $ flip runFresh '3' $ runMonoidWriter $ replicateM_ 3 action3
  putStrLn w''
  let (w''', ()) = run $ runMonoidWriter $ flip runFresh '3' $ replicateM_ 3 action3
  putStrLn w'''

-- 一つのモナドの中でできるようになったことで
-- MonadReader みたいにつかうのと同じでは
