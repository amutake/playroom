Require Import ssreflect ssrbool.

Lemma imp_trans4 P Q R S : (P -> Q) -> (R -> S) -> (Q -> R) -> P -> S.
Proof.
  move => H1 H2 H3.
  move => p; move: (H1 p).
  Undo.
  move/H1.
  move/H3 /H2.
  done.
Qed.

Lemma falseP : reflect False false.
Proof.
  by constructor.
Qed.

Goal false -> False.
Proof.
  case: falseP.
  move => //.
  move => //.
