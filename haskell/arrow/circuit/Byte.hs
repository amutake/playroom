{-# LANGUAGE DataKinds, GADTs #-}

module Byte where

import Prelude hiding (zip)
import Data.Bits

import TypeLevel

newtype Bit = Bit Bool deriving (Eq)

instance Show Bit where
    show (Bit True) = "1"
    show (Bit False) = "0"

instance Bits Bit where
    (Bit a) .&. (Bit b) = Bit (a .&. b)
    (Bit a) .|. (Bit b) = Bit (a .|. b)
    (Bit a) `xor` (Bit b) = Bit (a `xor` b)
    complement (Bit a) = Bit (complement a)
    shift (Bit a) n = Bit (shift a n)
    rotate (Bit a) n = Bit (rotate a n)
    bitSize (Bit a) = bitSize a
    bitSizeMaybe (Bit a) = bitSizeMaybe a
    isSigned (Bit a) = isSigned a
    testBit (Bit a) n = testBit a n
    bit n = Bit (bit n)
    popCount (Bit a) = popCount a

type N8 = (S (S (S (S (S (S (S (S Z))))))))

newtype Byte = Byte (Vect N8 Bit) deriving (Eq)

instance Show Byte where
    show (Byte (b0 :- b1 :- b2 :- b3 :- b4 :- b5 :- b6 :- b7 :- Nil)) = [b7, b6, b5, b4, b3, b2, b1, b0] >>= show
    show _ = undefined

instance Bits Byte where
    (Byte as) .&. (Byte bs) = Byte $ fmap (uncurry (.&.)) $ zip as bs
    (Byte as) .|. (Byte bs) = Byte $ fmap (uncurry (.|.)) $ zip as bs
    (Byte as) `xor` (Byte bs) = Byte $ fmap (uncurry xor) $ zip as bs
    complement (Byte as) = Byte $ fmap complement as
    shift (Byte as) n = Byte $ replicate n zeroBit :- init as
