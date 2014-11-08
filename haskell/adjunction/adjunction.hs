{-# LANGUAGE FunctionalDependencies #-}

-- http://kagamilove0707.hatenablog.com/entry/2014/11/02/210400

module Adjunction where

data Writer s a = Writer s a

instance Functor (Writer s) where
    fmap f (Writer s a) = Writer s (f a)

data Reader s a = Reader (s -> a)

instance Functor (Reader s) where
    fmap f (Reader g) = Reader (f . g)

class (Functor f, Functor g) => Adjunction f g where
    phiLeft :: (f a -> b) -> (a -> g b)
    phiRight :: (a -> g b) -> (f a -> b)

instance Adjunction (Writer s) (Reader s) where
    phiLeft f a = Reader $ \s -> f (Writer s a)
    phiRight f (Writer s a) = let Reader g = f a in g s

newtype Compose f g a = Compose { getCompose :: g (f a) }

instance (Functor f, Functor g) => Functor (Compose f g) where
    fmap f (Compose m) = Compose $ fmap (fmap f) m

composeJoin :: (Functor f, Functor g, Adjunction f g)
            => Compose f g (Compose f g a)
            -> Compose f g a
composeJoin (Compose m) = Compose $
