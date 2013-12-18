{-# LANGUAGE BangPatterns #-}

module PubKey where

import Crypto.PubKey.RSA (generate)
import Crypto.Random.API (cprgCreate)
import Crypto.Random (SystemRNG, createEntropyPool)
import Data.Certificate.KeyRSA (encodePublic)
import qualified Data.ByteString as S
import qualified Data.ByteString.Lazy as L
import Data.ByteString.Base64.Lazy (encode)


test :: IO ()
test = do
    !pool <- createEntropyPool
    putStrLn "pool created"
    let !gen = cprgCreate pool :: SystemRNG
    putStrLn "gen created"
    let ((!pubkey, _), _) = generate gen 256 65537
    putStrLn "pubkey created"
    print pubkey
    let der = S.concat $ L.toChunks $ encode $ encodePublic pubkey
    print der
