Inductive Fin : nat -> Prop :=
| fzero : forall n, Fin (S n)
| fsucc : forall n, Fin n -> Fin (S n).

Extraction Language Ocaml.
Extraction "./fin.hs" Fin.
