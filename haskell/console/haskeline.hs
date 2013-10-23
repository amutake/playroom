import System.Console.Haskeline
import Options.Applicative

import Control.Monad.IO.Class

data Command = Get String
             | Put String String
             deriving (Show)

cmdParser :: Parser Command
cmdParser = subparser (command "get" getInfo <> command "put" putInfo)
  where
    getInfo = info (helper <*> (
        Get <$>
        argument str (metavar "PATH" <> help "get help")
        )) $ progDesc "get"
    putInfo = info (helper <*> (
        Put <$>
        argument str (metavar "REMOTE") <*>
        argument str (metavar "LOCAL" <> help "local help")
        )) fullDesc

getParser :: Parser Command
getParser = Get <$> argument str (metavar "PATH" <> help "file path")

putParser :: Parser Command
putParser = Put <$>
    argument str (metavar "REMOTE" <> help "remote file path") <*>
    argument str (metavar "LOCAL" <> help "local file path")

main :: IO ()
main = do
  runInputT defaultSettings loop

loop :: InputT IO ()
loop = do
    minput <- fmap words <$> getInputLine "% "
    case minput of
        Nothing -> return ()
        Just args -> case execParserPure (prefs idm) pinfo args of
            Right cmd -> liftIO (print cmd) >> loop
            Left failure -> do
                liftIO $ errMessage failure "" >>= putStr
                loop
  where
    pinfo = info (helper <*> cmdParser) fullDesc
