Require Import Definitions.
Lemma Excluded_Middle P:P\/~P.
intro;apply callcc;auto.
Qed.
