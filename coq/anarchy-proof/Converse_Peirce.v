Require Import Definitions.
Lemma Excluded_Middle(P: Prop):P\/~P.
intro;apply Peirce with False;auto.
Qed.
