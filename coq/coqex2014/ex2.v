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

Goal forall m n : nat, (n * 10) + m = (10 * n) + m.
Proof.
  intros.
  rewrite mult_comm.
  reflexivity.
Qed.

Goal forall n m p q : nat, (n + m) + (p + q) = (n + p) + (m + q).
Proof.
  intros.
  rewrite plus_assoc.
  replace (n + m + p) with (n + p + m). (* いい感じに rewrite する方法がわかりません *)
    rewrite <- plus_assoc.
    reflexivity.

    rewrite <- plus_assoc.
    replace (p + m) with (m + p).
      rewrite plus_assoc.
      reflexivity.

      apply plus_comm.
Qed.

Lemma plus_l : forall n m p, n = m -> p + n = p + m.
Proof.
  intros; rewrite H; reflexivity.
Qed.

Goal forall n m : nat, (n + m) * (n + m) = n * n + m * m + 2 * n * m.
Proof.
  intros.
  rewrite mult_plus_distr_l.
  rewrite mult_plus_distr_r.
  rewrite <- plus_assoc.
  rewrite <- plus_assoc.
  apply plus_l.
  rewrite mult_plus_distr_r.

  rewrite plus_comm.
  replace (n * m + m * m) with (m * m + n * m).
    rewrite <- plus_assoc.
    apply plus_l.
    replace (m * n) with (n * m).
      simpl.
      rewrite mult_plus_distr_r.
      rewrite mult_plus_distr_r.
      rewrite mult_0_l.
      rewrite plus_0_r.
      reflexivity.

      apply mult_comm.
    apply plus_comm.
Qed.

Parameter G : Set.
Parameter mult : G -> G -> G.
Notation "x * y" := (mult x y).
Parameter one : G.
Notation "1" := one.
Parameter inv : G -> G.
Notation "/ x" := (inv x).

Axiom mult_assoc : forall x y z, x * (y * z) = (x * y) * z.
Axiom one_unit_l : forall x, 1 * x = x.
Axiom inv_l : forall x, /x * x = 1.

Lemma mult_eq_l_1 : forall x y z, x = y -> z * x = z * y.
Proof.
  intros.
  rewrite H.
  reflexivity.
Qed.

Lemma mult_eq_l_2 : forall x y z, z * x = z * y -> x = y.
Proof.
  intros.
  apply mult_eq_l_1 with (z := /z) in H.
  rewrite mult_assoc in H.
  rewrite mult_assoc in H.
  rewrite inv_l in H.
  rewrite one_unit_l in H.
  rewrite one_unit_l in H.
  assumption.
Qed.

Lemma mult_one_comm : forall x, 1 * x = x * 1.
Proof.
  intros.
  rewrite one_unit_l.
  apply mult_eq_l_2 with (/x).
  rewrite mult_assoc.
  rewrite inv_l.
  rewrite one_unit_l.
  reflexivity.
Qed.

Lemma inv_r : forall x, x * / x = 1.
Proof.
  intros.
  apply mult_eq_l_2 with (z := /x).
  rewrite mult_assoc.
  rewrite inv_l.
  apply mult_one_comm.
Qed.

Lemma one_unit_r : forall x, x * 1 = x.
Proof.
  intros.
  rewrite <- mult_one_comm.
  apply one_unit_l.
Qed.
