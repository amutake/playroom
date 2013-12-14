Require Import Classical.
Lemma Peirce(P Q:Prop)(H:((P->Q)->P)):P.
intros;apply Peirce;intro;apply H;easy.
Qed.
