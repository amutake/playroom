{-# LANGUAGE FlexibleContexts, MultiParamTypeClasses, FlexibleInstances #-}

module Main where

import Control.Monad.Error
import Control.Monad.Identity
import Control.Monad.List

class Monad m => MonadList a m where
    choose :: [a] -> m a

instance MonadList a [] where
    choose = id

instance Monad m => MonadList a (ListT m) where
    choose = ListT . return

instance (MonadList a m, Error e) => MonadList a (ErrorT e m) where
    choose = lift . choose

newtype TooBig = TooBig Int deriving (Show)

instance Error TooBig

ex2 :: (MonadError TooBig m) => m Int -> m Int
ex2 m = do
    v <- m
    if v > 5 then throwError (TooBig v) else return v

exRec :: (MonadError TooBig m) => m Int -> m Int
exRec m = catchError m handler
  where
    handler (TooBig n) | n <= 7 = return n
    handler e = throwError e

main :: IO ()
main = do
    print $ runIdentity $ runErrorT $ runListT $ exRec $ ex2 $ choose [1..9]
    print $ runIdentity $ runListT $ runErrorT $ exRec $ ex2 $ choose [1..9]

    print $ runIdentity $ runErrorT $ runListT $ exRec $ ex2 $ choose [5,7,1]
    print $ runIdentity $ runListT $ runErrorT $ exRec $ ex2 $ choose [5,7,1]
