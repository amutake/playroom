{-# LANGUAGE ScopedTypeVariables #-}

import Options.Applicative

import Network.Transport
import Network.Transport.TCP (createTransport)
import Control.Distributed.Process.Node

data Option = Option
  { host :: String
  , port :: Int
  , server :: String
  } deriving (Show)

optionParser :: Parser Option
optionParser = Option <$>
  strOption (long "host" <> short 'h' <> metavar "HOST" <> help "Host") <*>
  option (long "port" <> short 'p' <> metavar "PORT" <> help "Port") <*>
  strOption (long "server" <> short 's' <> metaver "SERVER" <> help "Server")

putter :: ProcessId -> Process ()
putter serverId = do
  putStr "> "
  message <- getLine
  self <- getSelfPid
  send serverId (message, self)
  putter

setter :: Process ()
setter = do
  (message :: String, pid) <- expect
  putStrLn $ pid ++ "> " ++ message
  setter

main :: IO ()
main = execParser pinfo >>= \option -> do
  initializeBackend (host option) (show $ port option) defaultTCPParameters
  Right lt <- createTransport (host option) (show $ port option) defaultTCPParameters
  lnode <- newLocalNode lt initRemoteTable
  Right rt <- createTransport (server option) (show $ serverPort option) defaultTCPParameters
  rnode <- newLocalNode rt initRemoteTable
