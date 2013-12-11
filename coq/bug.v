Inductive A : Set := a : A.

Inductive B : Set := b : B.

Definition fantom (n : nat) := A -> B.

Definition const_b := fun _ : A => b.

Definition fantom_succ {n : nat} : fantom n -> fantom (S n) :=
  fun f => const_b.

Inductive ty : forall n : nat, fantom n -> Prop :=
| zero : ty O const_b
| succ : forall (x : nat) (f : fantom x), ty x f -> ty (S x) (fantom_succ f).

Goal forall (n : nat) (f : fantom n), ty n f -> f = const_b.
Proof.
  intros.
  inversion H.
Admitted.
