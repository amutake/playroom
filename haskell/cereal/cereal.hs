{-# LANGUAGE DeriveGeneric #-}

import Control.Applicative
import Data.Serialize
import Data.Word

import GHC.Generics

data Block = Block
    { blockSize :: Word32
    , nblock :: Word32
    } deriving (Generic, Show)

instance Serialize Block where
    put (Block s n) = put s >> put n
    get = Block <$> get <*> get

main :: IO ()
main = do
    print $ encode (Block 65535 5)
    print $ encode "hogehogeh"
