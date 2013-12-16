(* http://www.slideshare.net/tmiya/coq-setoid-20110129 *)

Require Import Setoid Relation_Definitions Arith Compare_dec Omega.

Inductive Z' : Set :=
| mkZ' : nat -> nat -> Z'.

Definition Z'eq (z z' : Z') : Prop :=
  let (a, b) := z in
  let (c, d) := z' in
  a + d = b + c.                (* a - b = c - d *)

Notation "a =Z= b" := (Z'eq a b) (at level 70).

Lemma Z'eq_refl : reflexive Z' Z'eq.
Proof.
  unfold reflexive.
  unfold Z'eq.
  intros.
  destruct x.
  rewrite plus_comm.
  auto.
Qed.

Lemma Z'eq_sym : symmetric Z' Z'eq.
Proof.
  unfold symmetric.
  unfold Z'eq.
  destruct x, y.
  intro.
  rewrite plus_comm.
  symmetry.
  rewrite plus_comm.
  auto.
Qed.

Lemma Z'eq_trans : transitive Z' Z'eq.
Proof.
  unfold transitive.
  unfold Z'eq.
  destruct x, y, z.
  intros.
  omega.
Qed.

Add Parametric Relation : Z' Z'eq
  reflexivity proved by Z'eq_refl
  symmetry proved by Z'eq_sym
  transitivity proved by Z'eq_trans
  as Z'_rel.

Definition Z'plus (z z' : Z') : Z' :=
  let (a, b) := z in
  let (c, d) := z' in
  mkZ' (a + c) (b + d).

Add Parametric Morphism : Z'plus with
    signature Z'eq ==> Z'eq ==> Z'eq as Z'_plus_mor.
Proof.
  unfold Z'eq.
  unfold Z'plus.
  intros.
  destruct x, y, x0, y0.
  omega.
Qed.

Lemma Z'eq_plus_id_l : forall z a, Z'plus (mkZ' a a) z =Z= z.
Proof.
  intros.
  simpl.
  destruct z.
  unfold Z'eq.
  omega.
Qed.

Lemma Z'eq_plus_comm : forall z z', Z'plus z z' =Z= Z'plus z' z.
Proof.
  unfold Z'eq.
  destruct z, z'.
  simpl.
  omega.
Qed.

Lemma Z'eq_plus_id_r : forall z a, Z'plus z (mkZ' a a) =Z= z.
Proof.
  intros.
  setoid_rewrite Z'eq_plus_comm.
  apply Z'eq_plus_id_l.
Qed.
