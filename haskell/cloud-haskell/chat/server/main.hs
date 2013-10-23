{-# LANGUAGE ScopedTypeVariables #-}

import Data.Set
import Options.Applicative hiding (empty)

import Control.Distributed.Process
import Control.Distributed.Process.Backend.SimpleLocalnet
import Control.Distributed.Process.Node hiding (newLocalNode)

data Option = Option
  { host :: String
  , port :: Int
  } deriving (Show)

optionParser :: Parser Option
optionParser = Option <$>
  strOption (long "host" <> short 'h' <> metavar "HOST" <> help "Host") <*>
  option (long "port" <> short 'p' <> metavar "PORT" <> help "Port")

server :: Set ProcessId -> Process ()
server members = do
  (message :: String, pid) <- expect
  let members' = if member pid members then members else insert pid members
  mapM_ (\pid' -> send pid' (message, pid)) members'
  server members

main :: IO ()
main = execParser pinfo >>= \option -> do
  backend <- initializeBackend (host option) (show $ port option)
  node <- newLocalNode backend
  runProcess node $ do
    getSelfPid >>= register "slaveController"
    server empty
  where
    pinfo = info (helper <*> optionParser) fullDesc

-- 別のノードのプロセスとの通信
