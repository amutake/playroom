import Control.Concurrent
import Control.Monad
import Text.Printf

main :: IO ()
main = forkIO (write 'a') >> write 'b'
 where
  write c = replicateM_ 100 $ putChar c

bang :: IO ()
bang = loop
 where
  loop = do
    s <- getLine
    if s == "exit"
      then return ()
      else do
        forkIO $ setReminder s
        loop

setReminder :: String -> IO ()
setReminder s = do
  let t = read s :: Int
  printf "Ok, I'll remind you in %d seconds\n" t
  threadDelay (10^6 * t)
  printf "%d seconds is up! BING!\BEL\n" t
