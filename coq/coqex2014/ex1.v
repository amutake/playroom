Theorem Modus_ponens : forall P Q : Prop, P -> (P -> Q) -> Q.
Proof.
  intros.
  apply H0.
  apply H.
Qed.

Theorem Modus_tollens : forall P Q : Prop, ~Q /\ (P -> Q) -> ~P.
Proof.
  intros.
  intro.
  inversion H.
  apply H1.
  apply H2.
  apply H0.
Qed.

Theorem Disjunctive_syllogism : forall P Q : Prop, (P \/ Q) -> ~P -> Q.
Proof.
  intros.
  inversion H.
    (* contradiction. *)
    exfalso.
    apply H0.
    apply H1.

    apply H1.
Qed.

Theorem DeMorgan1 : forall P Q : Prop, ~P \/ ~Q -> ~(P /\ Q).
Proof.
  intros.
  intro.
  inversion H0.
  inversion H.
    apply H3.
    apply H1.

    apply H3.
    apply H2.
Qed.

Theorem DeMorgan2 : forall P Q : Prop, ~P /\ ~Q -> ~(P \/ Q).
Proof.
  intros.
  intro.
  inversion H.
  inversion H0.
  apply H1; apply H3.
  apply H2; apply H3.
Qed.

Theorem DeMorgan3 : forall P Q : Prop, ~(P \/ Q) -> ~P /\ ~Q.
Proof.
  intros.
  split; intro.
    apply H.
    left; apply H0.

    apply H.
    right; apply H0.
Qed.

Theorem NotNot_LEM : forall P : Prop, ~ ~(P \/ ~P).
Proof.
  intros.
  intro.
  apply DeMorgan3 in H.
  inversion H.
  apply H1.
  apply H0.
Qed.
