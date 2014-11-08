{-# LANGUAGE DeriveDataTypeable, OverloadedStrings #-}

import Control.Applicative
import Data.Aeson
import Data.Typeable

data Or a b = L a | R b deriving (Show, Eq, Typeable)

instance (FromJSON a, FromJSON b) => FromJSON (Or a b) where
    parseJSON v = L <$> parseJSON v <|> R <$> parseJSON v

data Payload = Push PushEvent | Status StatusEvent deriving (Show, Eq, Typeable)

instance FromJSON Payload where
    parseJSON v = Push <$> parseJSON v <|> Status <$> parseJSON v

data PushEvent = PushEvent
    { pushId :: Maybe Int
    , pushUser :: Or UserA UserB
    , pushCreatedAt :: Or Int String
    } deriving (Show, Eq, Typeable)

instance FromJSON PushEvent where
    parseJSON (Object o) = PushEvent
        <$> o .:? "id"
        <*> o .: "user"
        <*> o .: "created_at"
    parseJSON _ = fail "push"

data UserA = UserA
    { userAName :: String
    , userAId :: Int
    } deriving (Show, Eq, Typeable)

instance FromJSON UserA where
    parseJSON (Object o) = UserA
        <$> o .: "name"
        <*> o .: "id"

data UserB = UserB
    { userBUsername :: String
    , userBId :: Int
    } deriving (Show, Eq, Typeable)

instance FromJSON UserB where
    parseJSON (Object o) = UserB
        <$> o .: "username"
        <*> o .: "id"

data StatusEvent = StatusEvent
    { stName :: [String]
    , stId :: Int
    } deriving (Show, Eq, Typeable)

instance FromJSON StatusEvent where
    parseJSON (Object o) = StatusEvent
        <$> o .: "name"
        <*> o .: "id"
    parseJSON _ = fail "st"

main :: IO ()
main = do
    test "{}"
    test "{\"id\":1,\"user\":{\"name\":\"hoge\",\"id\":8},\"created_at\":\"2014/10/15\"}"
    test "{\"id\":1,\"user\":{\"name\":\"hoge\",\"id\":8},\"created_at\":236789}"
    test "{\"id\":null,\"user\":{\"username\":\"hoge\",\"id\":8},\"created_at\":\"2014/10/15\"}"
    test "{\"id\":1,\"name\":[\"hogeevent\"]}"
    test "{\"id\":1}"
  where
    test str = case eitherDecode str of
        Left reason -> putStrLn reason
        Right p -> printPayload p

printPayload :: Payload -> IO ()
printPayload (Push p) = putStrLn $ "push: " ++ show p
printPayload (Status p) = putStrLn $ "status: " ++ show p
