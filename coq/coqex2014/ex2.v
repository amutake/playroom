Require Import Arith.

Goal forall x y, x < y -> x + 10 < y + 10.
Proof.
  intros.
  apply plus_lt_compat_r.
  assumption.
Qed.

Goal forall P Q : nat -> Prop, P O -> (forall x, P x -> Q x) -> Q O.
Proof.
  intros.
  apply H0; assumption.
Qed.

Goal forall P : nat -> Prop, P 2 -> (exists y, P (1 + y)).
Proof.
  intros.
  exists 1.
  simpl.
  assumption.
Qed.

Goal forall P : nat -> Prop, (forall n m, P n -> P m) -> (exists p, P p) -> forall q, P q.
Proof.
  intros.
  inversion H0.
  apply H with x.
  assumption.
Qed.
