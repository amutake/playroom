{-# LANGUAGE TypeOperators, DataKinds, ConstraintKinds, FlexibleContexts, GADTs, AllowAmbiguousTypes #-}

module Main where

import Control.Effect

hoge :: (EffectReader String es, EffectState Int es) => Effect es String
hoge = do
    str <- ask
    n <- state $ \n -> (n, n + 1)
    return $ str ++ "hoge" ++ show (n + 1)

fuga :: (EffectState Int es) => Effect es ()
fuga = modify succ

-- こういうのは書けないみたい
-- intstr :: (EffectReader String es, EffectReader Int es) => Effect es String
-- intstr = do
--     n <- ask
--     str <- ask
--     return $ show (n :: Int) ++ (str :: String)

main :: IO ()
main = putStrLn $ runEffect $ evalState 0 $ runReader "hoge" $ hoge >> fuga >> hoge
