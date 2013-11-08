module APi

Name : Type
Name = String
-- data Name : Type where
--   NameCons : String -> Name

-- instance Eq Name where
--   (NameCons n1) == (NameCons n2) = n1 == n2

-- instance Ord Name where
--   compare (NameCons n1) (NameCons n2) = compare n1 n2

data Config : Type where
  Nil : Config
  Receive : Name -> Name -> Config -> Config
  Send : Name -> Name -> Config
  Restrict : Name -> Config -> Config
  Compose : Config -> Config -> Config
  -- Case :
  -- Behavior :

data Action : Type where
  Silent : Action
  FreeOut : Name -> Name -> Action
  BoundOut : Name -> Name -> Action
  FreeInp : Name -> Name -> Action
  BoundInp : Name -> Name -> Action

data NotSilent : Action -> Type where
  NotSilentFreeOut : NotSilent (FreeOut x y)
  NotSilentBountOut : NotSilent (BoundOut x y)
  NotSilentFreeInp : NotSilent (FreeInp x y)
  NotSilentBoundInp : NotSilent (BoundInp x y)

replace : Name -> Name -> Config -> Config
replace var val conf = conf -- TODO

configNames : Config -> List Name
configNames Nil = []
configNames (Receive n1 n2 conf) = n1 :: n2 :: configNames conf
configNames (Send n1 n2) = n1 :: n2 :: []
configNames (Restrict n conf) = n :: configNames conf
configNames (Compose conf1 conf2) = configNames conf1 ++ configNames conf2

freeConfigNames : Config -> List Name
freeConfigNames = const [] -- TODO

boundConfigNames : Config -> List Name
boundConfigNames = const [] -- TODO

actionNames : Action -> List Name
actionNames Silent = []
actionNames (FreeOut n1 n2) = [n1, n2]
actionNames (BoundOut n1 n2) = [n1, n2]
actionNames (FreeInp n1 n2) = [n1, n2]
actionNames (BoundInp n1 n2) = [n1, n2]

freeActionNames : Action -> List Name
freeActionNames = const [] -- TODO

boundActionNames : Action -> List Name
boundActionNames = const [] -- TODO

intersect : Eq a => List a -> List a -> List a
intersect [] _ = []
intersect _ [] = []
intersect xs ys = [ x | x <- xs, any (== x) ys ]

data Trans : Action -> Config -> Config -> Type where
  Inp   : Trans (FreeInp x z) (Receive x y p) (replace y z p)
  BInp  : Trans (FreeInp x y) p p'
       -> so (not (elem y (freeConfigNames p)))
       -> Trans (BoundInp x y) p p'
  Out   : Trans (FreeOut x y) (Send x y) Nil
  Res   : NotSilent a
       -> Trans a p p'
       -> so (not (elem y (actionNames a)))
       -> Trans a (Restrict y p) (Restrict y p')
  Open  : Trans (FreeOut x y) p p'
       -> Not (x = y)
       -> Trans (BoundOut x y) (Restrict y p) p'
  Par   : NotSilent a
       -> Trans a p1 p1'
       -> so (isNil (boundActionNames a `intersect` freeConfigNames p2))
       -> Trans a (Compose p1 p2) (Compose p1' p2)
  Com   : Trans (FreeOut x y) p1 p1'
       -> Trans (FreeInp x y) p2 p2'
       -> Trans Silent (Compose p1 p2) (Compose p1' p2')
  Close : Trans (BoundOut x y) p1 p1'
       -> Trans (FreeInp x y) p2 p2'
       -> so (not (elem y (freeConfigNames p2)))
       -> Trans Silent (Compose p1 p2) (Restrict y (Compose p1' p2')
