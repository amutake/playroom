Require Import Arith.

Fixpoint sum_odd (n : nat) : nat :=
  match n with
  | O => O
  | S m => 1 + m + m + sum_odd m
  end.

Goal forall n, sum_odd n = n * n.
Proof.
  intros.
  induction n.
    reflexivity.

    simpl.
    rewrite IHn.
    rewrite mult_succ_r.
    replace (n * n + n) with (n + n * n).
      rewrite plus_assoc.
      reflexivity.

      rewrite plus_comm.
      reflexivity.
Qed.

Require Import Lists.List.

Fixpoint sum (xs : list nat) : nat :=
  match xs with
    | nil => 0
    | x :: xs => x + sum xs
  end.

Theorem Pigeon_Hole_Principle :
  forall (xs : list nat), length xs < sum xs -> (exists x, 1 < x /\ In x xs).
Proof.
  intros.
  induction xs.
    simpl in H.
    exfalso; apply lt_irrefl with 0; assumption.

    induction a.
      simpl in H.
      simpl.
      assert (forall n m, S n < m -> n < m).
        intros.
        apply lt_trans with (S n).
        apply lt_n_Sn.
        assumption.
      apply H0 in H.
      apply IHxs in H.
      inversion H.
      exists x.
      inversion H1.
      split; try right; assumption.

      induction a.
        simpl in H, IHa.
        simpl.
        apply lt_S_n in H.
        apply IHxs in H.
        inversion H.
        inversion H0.
        exists x.
        split; try right; assumption.

        exists (S (S a)).
        split.
          apply lt_n_S.
          apply lt_0_Sn.

          simpl.
          left; reflexivity.
Qed.

Inductive pos : Set :=
  | SO : pos
  | S : pos -> pos.

Fixpoint plus (n m : pos) : pos :=
  match n with
    | SO => S m
    | S n' => S (plus n' m)
  end.

Infix "+" := plus.

Theorem plus_assoc : forall n m p, n + (m + p) = (n + m) + p.
Proof.
  intros.
  induction n.
    reflexivity.

    simpl.
    rewrite IHn.
    reflexivity.
Qed.

Lemma pos_S : forall n, S n <> n.
Proof.
  intros; intro.
  induction n.
    discriminate.
    inversion H.
    apply IHn; assumption.
Qed.

Lemma pos_dec : forall n m : pos, {n = m} + {n <> m}.
Proof.
  induction n; destruct m; auto; try (right; intro; discriminate).
  induction (IHn m).
    left; rewrite a; auto.
    right; intro.
    inversion H; auto.
Qed.

Theorem FF : ~exists f, forall n, f (f n) = S n.
Proof.
  unfold not.
  intros.
  inversion H.
  specialize (H0 SO).




















Admitted.

Inductive Tree : Set :=
  | Node : list Tree -> Tree.

Lemma list_neq_cons : forall (T : Type) (a : T) l, a :: l <> l.
Proof.
  intros; intro.
  induction l; intros.
    discriminate.
    inversion H. rewrite H1 in IHl. auto.
Qed.

Lemma tree_eq : forall l1 l2 : Tree, Node l1 = Node l2 ->

Theorem Tree_dec : forall a b : Tree, {a = b} + {a <> b}.
Proof.
  destruct a, b.
  generalize l0.
  induction l; induction l1.
    left; auto.
    right; intro; discriminate.
    right; intro; discriminate.
    inversion_clear IHl1.
      inversion_clear H.
      right; intro.
      inversion H.
      symmetry in H2; apply list_neq_cons in H2; auto.



  destruct a, b.
  generalize dependent l0.
  induction l.
    induction l0.
      left; reflexivity.
      right; intro; discriminate.
    intros.
    induction l0.
      right; intro; discriminate.

      inversion_clear IHl0.
        inversion H.
        right; intro.
        inversion H0.
        symmetry in H4.
        apply list_neq_cons in H4; auto.

        specialize (IHl l0).
        inversion_clear IHl; subst.
          inversion_clear H0; subst.



    induction (IHl l0).
      right; intro.
      rewrite <- a0 in H.
      inversion H.
      apply list_neq_cons in H1; auto.

      induction l0.
        right; intro H; inversion H.
