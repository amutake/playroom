{-# LANGUAGE Arrows, ScopedTypeVariables #-}

import qualified Prelude as P
import Control.Arrow

-- curry :: Arrow a => a (a (b, c) d) (a b (a c d)) -- ((b, c) -> d) -> b -> c -> d
-- curry = proc f -> do
--   let
--     fb = proc b -> do

--     proc b -> do
--         proc c -> do
--             f -< (b, c)

curry :: Arrow a => a (b, c) d -> a b (a c d)
curry f = abacd
  where
    abacd = proc b -> proc c -> f -< (b, c)
    acd b = proc c -> f -< (b, c)
