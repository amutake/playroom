module Util where

import Control.Applicative
import System.Directory

getFiles :: IO [FilePath]
getFiles = filter test <$> getDirectoryContents "jypes/"
  where
    test "." = False
    test ".." = False
    test _ = True
