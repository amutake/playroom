Axiom excluded_middle : forall P : Prop, P \/ ~ P.

Theorem peirce : forall P : Prop, ((P -> False) -> P) -> P.
Proof.
  intros.
  destruct (excluded_middle P).
    auto.
    apply H in H0; auto.
Qed.

Theorem double_neg_elim : forall P, ~ ~ P -> P.
Proof.
  intros.
  destruct (excluded_middle P).
    auto.
    apply H in H0; contradiction.
Qed.
