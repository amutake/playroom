Goal (forall P Q R : Prop, P -> Q -> R) <->
     (forall P : Prop, P -> forall Q : Prop, Q -> forall R : Prop, R).
Proof.
  split; intros.
  - apply (H P Q R H0 H1).
  - apply (H P H0 Q H1 R).
Qed.
