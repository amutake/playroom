{-# LANGUAGE TypeOperators #-}

data (:==) i o v = Pipe i o v

(<><>) :: Int -> Int -> Int -> Int
(<><>) a b c = a * b * c

main :: IO ()
main = print $ 1 <><> 2 $ 3
