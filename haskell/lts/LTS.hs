-- Labelled Transition System
module LTS where

data Process = Process [(Action, Process)]

data Action = Action String

-- vending machine
p1 :: Process
p1 = Process [(Action "1c", p2)]

p2 :: Process
p2 = Process [(Action "request-tea", p3), (Action "request-coffee", p4)]

p3 :: Process
p3 = Process [(Action "tea")]

p4 :: Process
p4 = Process [(Action "coffee")]
