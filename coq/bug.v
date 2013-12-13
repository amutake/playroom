Inductive A : Set := a : A.

Definition fantom (n : nat) := A.

Definition fantom_succ {n : nat} : fantom n -> fantom (S n) :=
  fun _ => a.

Inductive ty : forall n : nat, fantom n -> Prop :=
| zero : ty O a
| succ : forall (x : nat) (f : fantom x), ty x f -> ty (S x) (fantom_succ f).

Goal forall (n : nat) (f : fantom n), ty n f -> f = a.
Proof.
  intros.
  inversion H.
Admitted.
