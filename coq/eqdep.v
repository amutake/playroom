Variable U : Type.
Variable P : U -> Set.

Inductive eqdep (u : U) (p : P u) (t : U) : P t -> Prop :=
| eqdep_intro : eqdep u p u p.
