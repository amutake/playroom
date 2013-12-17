import Control.Eff

import Control.Monad.Cont
import Control.Monad.Reader
import Control.Monad.Writer
import Control.Monad.State

type MonadStack4 t m = ReaderT t (WriterT t (StateT t m))

type MonadStack40 m =
  MonadStack4 Ordering
  (MonadStack4 ()
   (MonadStack4 Any
    (MonadStack4 All
     (MonadStack4 String
      (MonadStack4 (Maybe ())
       (MonadStack4 (Last ())
        (MonadStack4 (First ())
         (MonadStack4 (Product Int)
          (MonadStack4 (Sum Int) m)))))))))

action :: MonadStack40 IO String
action = do
  str <- lift . lift . lift .
         lift . lift . lift .
         lift . lift . lift .
         lift $ ask
  liftIO $ putStrLn str
  return str

runMonadStack4 :: Functor m => t -> MonadStack4 t m a -> m a
runMonadStack4 t = fmap fst . apply t . runStateT
                 . fmap fst . runWriterT
                 . apply t . runReaderT
  where
    apply x f = f x

runMonadStack40 :: Functor m => MonadStack40 m a -> m a
runMonadStack40 = runMonadStack4 mempty
                . runMonadStack4 mempty
                . runMonadStack4 mempty
                . runMonadStack4 mempty
                . runMonadStack4 mempty
                . runMonadStack4 mempty
                . runMonadStack4 mempty
                . runMonadStack4 mempty
                . runMonadStack4 mempty
                . runMonadStack4 mempty

main :: IO ()
main = do
  str <- runMonadStack40 action
  putStrLn str
