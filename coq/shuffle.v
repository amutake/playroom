Require Import List Peano_dec.
Import ListNotations.

Inductive nostutter {A : Type} : list A -> Prop :=
| nostutter_nil : nostutter []
| nostutter_cons : forall a l, nostutter l -> ~ In a l -> nostutter (a :: l).

Inductive shuffle {A : Type} (eq_dec : forall x y : A, {x = y} + {x <> y}) : list A -> list A -> Prop :=
| base : forall l l', Forall (fun a => In a l') l ->
                      Forall (fun a => In a l) l' ->
                      Forall2 (fun a b => count_occ eq_dec l b = count_occ eq_dec l' a) l l' ->
                      shuffle eq_dec l l'.

Hint Constructors shuffle.



Goal shuffle eq_nat_dec [1;2;3;4;5] [4;1;2;5;3].
Proof.
  constructor.
    constructor.
      right.
      left.
      auto.
    constructor.
      right; right; left; auto.
    constructor.
      right; right; right; right; left; auto.
    constructor.
      left; auto.
    constructor.







Inductive shuffle {A : Type} : list A -> list A -> Prop :=
| base : forall l, shuffle l l
| app_ll : forall l1 l1' l2 l2', shuffle l1 l1' -> shuffle l2 l2' -> shuffle (l1 ++ l2) (l1' ++ l2')
| app_lr : forall l1 l1' l2 l2', shuffle l1 l1' -> shuffle l2 l2' -> shuffle (l1 ++ l2) (l2' ++ l1')
| app_rl : forall l1 l1' l2 l2', shuffle l1 l1' -> shuffle l2 l2' -> shuffle (l2 ++ l1) (l1' ++ l2')
| app_rr : forall l1 l1' l2 l2', shuffle l1 l1' -> shuffle l2 l2' -> shuffle (l2 ++ l1) (l2' ++ l1').

Hint Constructors shuffle.

Theorem shuffle_length : forall (A : Type) (l l' : list A), shuffle l l' -> length l = length l'.
Proof.
  intros.
  induction H; auto.
    rewrite app_length.
    rewrite app_length.
    rewrite IHshuffle1.
    rewrite IHshuffle2.
    auto.

    rewrite app_length.
    rewrite app_length.
    rewrite IHshuffle1.
    rewrite IHshuffle2.
    rewrite Plus.plus_comm.
    auto.

    rewrite app_length.
    rewrite app_length.
    rewrite IHshuffle1.
    rewrite IHshuffle2.
    rewrite Plus.plus_comm.
    auto.

    rewrite app_length.
    rewrite app_length.
    rewrite IHshuffle1.
    rewrite IHshuffle2.
    auto.
Qed.

Example shuffle_refl : forall (A : Type) (l l' : list A), shuffle l l' -> shuffle l' l.
Proof.
  induction l.
    intros.
    inversion H; subst; auto.
    apply shuffle_length in H.
    inversion H.


Example shuffle_2 : shuffle [1;2] [2;1].
Proof.
  apply (app_lr [1] [1] [2] [2]); auto.
Qed.

Example shuffle_3 : shuffle [1;2;3] [3;2;1].
Proof.
  apply (app_lr [1] [1] [2;3] [3;2]); auto.
  apply (app_lr [2] [2] [3] [3]); auto.
Qed.

Example shuffle_4 : shuffle [1;2;3;4] [2;4;1;3].
Proof.
  apply (app



Example shuffle_1 : shuffle [1; 2; 3; 4; 5] [4; 1; 2; 5; 3].
Proof.
  apply app_
