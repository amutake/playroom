import Data.Machine

main :: IO ()
main = runT test >>= print
  where
    test = source [1..10] ~> echo
