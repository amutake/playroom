CoInductive colist (A : Type) : Type :=
| co_nil : colist A
| co_cons : A -> colist A -> colist A.

Arguments co_nil [A].
Arguments co_cons [A] _ _.

CoInductive list_bisimulation (A : Type) : colist A -> colist A -> Prop :=
| list_bisim_nil : list_bisimulation A co_nil co_nil
| list_bisim_cons : forall a s s' t,
                      s = co_cons a s' ->
                      (exists t', t = co_cons a t' /\
                                  list_bisimulation A s' t') ->
                      list_bisimulation A s t.

Arguments list_bisim_nil [A].
Arguments list_bisim_cons [A] _ _ _ _ _ _.

Theorem list_bisim_cons_inv : forall A (a : A) t t' s,
                                list_bisimulation A s t ->
                                t = co_cons a t' ->
                                exists s', s = co_cons a s' /\
                                           list_bisimulation A s' t'.
Proof.
  intros.
  destruct H.
  - inversion H0.
  - inversion_clear H1.
    inversion_clear H2.
    subst.
    inversion H1; subst.
    exists s'.
    split; auto.
Qed.
