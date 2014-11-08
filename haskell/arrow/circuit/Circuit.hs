{-# LANGUAGE Arrows, TypeOperators #-}

module Circuit where

import Prelude hiding (id, (.), const)

import Control.Arrow
import Control.Category

newtype a :-> b = Circuit { unCircuit :: a -> (b, a :-> b) }

instance Category (:->) where
    id = Circuit $ \a -> (a, id)
    (Circuit f) . (Circuit g) = Circuit $ \a ->
        let (b, cirg) = g a in
        let (c, cirf) = f b in
        (c, cirf . cirg)

instance Arrow (:->) where
    arr f = Circuit $ \a -> (f a, arr f)
    first (Circuit f) = Circuit $ \(a, c) ->
        let (b, cir) = f a in
        ((b, c), first cir)

instance ArrowLoop (:->) where
    loop (Circuit f) = Circuit $ \a ->
        let ((b, c), cir) = f (a, c) in
        (b, loop cir)

delay :: a -> a :-> a
delay a = Circuit $ \a' -> (a, delay a')

const :: a -> b :-> a
const a = Circuit $ \_ -> (a, const a)

runCircuit :: a :-> b -> [a] -> [b]
runCircuit _ [] = []
runCircuit (Circuit f) (x:xs) = let (y, cir) = f x in
    y : runCircuit cir xs
