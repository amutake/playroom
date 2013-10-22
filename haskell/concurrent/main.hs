import Control.Concurrent

main :: IO ()
main = forkIO (write 'a') >> write 'b'
 where
  write c = putChar c >> write c
