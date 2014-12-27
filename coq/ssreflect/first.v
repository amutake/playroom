(* http://ilyasergey.net/pnp/pnp.pdf chapter5 *)

Require Import ssreflect ssrbool.

(* 5.1 *)

Lemma imp_trans4 P Q R S : (P -> Q) -> (R -> S) -> (Q -> R) -> P -> S.
Proof.
  move => H1 H2 H3.             (* intros H1 H2 H3. *)
  move => p; move: (H1 p).      (* intros p; apply H1 in p; generalize p. *)
  Undo.
  move/H1.                      (* popして適用してpush？ *)
  move/H3 /H2.                  (* popして適用してpushしてpopして適用してpush? *)
  done.                         (* by auto? *)
Qed.

Lemma falseP : reflect False false.
Proof.
  by constructor.
Qed.

Goal false -> False.
Proof.
  case: falseP.                 (* move: falseP. case. *)
  move => //.
  move => //.
Qed.

Goal forall P Q R, (P -> Q /\ R) -> P -> R.
Proof.
  move => P Q R H.
  case/H.
