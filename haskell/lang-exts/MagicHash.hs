{-# LANGUAGE MagicHash #-}

import GHC.Prim

data ThreadId = ThreadId ThreadId#

hoge :: ThreadId# -> ThreadId# -> Bool
hoge = let x = x in x

fuga :: Int -> Int
fuga = let x = x in x
