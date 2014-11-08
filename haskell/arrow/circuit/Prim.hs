{-# LANGUAGE Arrows, TypeOperators #-}

module Prim where

import Prelude (Bool (..), (&&), (||), uncurry, IO, Int)
import qualified Prelude as P
import Control.Arrow
import Control.Concurrent (threadDelay)

not :: Bool :-> Bool
not = arr P.not

nand :: [Bool] :-> Bool
nand = and >>> not

and :: Arrow a => a (Bool, Bool) Bool
and = arr (uncurry (&&))

or :: Arrow a => a (Bool, Bool) Bool
or = arr (uncurry (||))

nor :: Arrow a => a (Bool, Bool) Bool
nor = or >>> not

xor :: Arrow a => a (Bool, Bool) Bool
xor = proc (a, b) -> do
    na <- not -< a
    nb <- not -< b
    a' <- and -< (na, b)
    b' <- and -< (a, nb)
    or -< (a', b')

halfAdder :: Arrow a => a (Bool, Bool) (Bool, Bool)
halfAdder = proc (a, b) -> do
    s <- xor -< (a, b)
    c <- xor -< (a, b)
    returnA -< (s, c)

fullAdder :: Arrow a => a ((Bool, Bool), Bool) (Bool, Bool)
fullAdder = proc ((a, b), x) -> do
    (s, c) <- halfAdder -< (a, b)
    (s', c') <- halfAdder -< (s, x)
    c'' <- or -< (c, c')
    returnA -< (s', c'')

clk :: Int -> ((Bool, b) -> b) -> (b -> IO ()) -> IO ()
clk n f io = clk' True P.undefined
  where
    clk' b i = do
        let o = f (b, i)
        io o
        threadDelay n
        clk' (P.not b) o

go :: IO ()
go = do
    clk
