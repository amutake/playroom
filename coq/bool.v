Require Import Coq.Logic.Classical.

Goal forall P Q R, P /\ (Q \/ R) <-> (P /\ Q) \/ (P /\ R).
Proof.
  intros.
  split; intros.
    inversion H.
    inversion H1.
      left; split; assumption.
      right; split; assumption.

    split.
      inversion H; inversion H0; assumption.
      inversion H; inversion H0.
        left; assumption.
        right; assumption.
Qed.

Goal forall P Q : Prop, ((P -> Q) -> P) -> P.
Proof.
  intros.
  apply H.
  intros.
  destruct (classic Q).
    assumption.

    destruct (classic P).

Qed.
