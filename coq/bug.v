Inductive A : Set := a : A.

Definition fantom (n : nat) := A.

Inductive ty : forall n, fantom n -> Prop :=
| zero : ty O a.

Goal forall (n : nat) (f : fantom n), ty n f -> f = a.
Proof.
  intros.
  inversion H.
Admitted.
