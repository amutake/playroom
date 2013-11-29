class Monoi a where
  mempty : a
  mappend : a -> a -> a
  monoidProperty1 : (x : a) -> mappend mempty x = x
  monoidProperty2 : (x : a) -> mappend x mempty = x
  monoidProperty3 : (x, y, z : a) -> mappend x (mappend y z) = mappend (mappend x y) z

instance Monoi (List a) where
  mempty = []
  mappend = (++)
  monoidProperty1 = ?listMonoidProp1
  monoidProperty2 = ?listMonoidProp2
  monoidProperty3 = ?listMonoidProp3

---------- Proofs ----------

listMonoidProp3 = proof
  intro
  exact appendAssociative


listMonoidProp2 = proof
  intro
  exact appendNilRightNeutral


listMonoidProp1 = proof
  intros
  refine refl
