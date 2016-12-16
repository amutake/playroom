Set Implicit Arguments.
Unset Strict Implicit.

Require Import Ssreflect.ssreflect Ssreflect.ssrbool Ssreflect.seq Ssreflect.eqtype Ssreflect.ssrnat.
Require Import Coq.Lists.List.

Inductive AB := A : nat -> AB | B : nat -> AB.

Fixpoint gen_As (n : nat) :=
  match n with
  | O => [::]
  | S n' => A n' :: gen_As n'
  end.

Lemma all_A :
  forall n,
    all (fun ab => match ab with
                   | A _ => true
                   | B _ => false
                   end) (gen_As n).
Proof.
  move=> n.
  elim: n=> //.
Qed.

Definition ab_match (ab : AB) (n : nat) :=
  match ab with
  | A n' => A n'
  | B n' => if n' == n.+1 then B n' else A n'
  end.

Lemma map_ext_in :
  forall (A B : Type) (l : seq.seq A) (f g : A -> B), (forall a, In a l -> f a = g a) -> map f l = map g l.
Proof.
  move=> A0 B0 l f g a_in.
  move: a_in.
  elim: l=> //.
  move=> a l IH a_in /=.
  congr (_ :: _).
  - apply/a_in.
    by constructor.
  - apply IH.
    move=> a0 in_a.
    apply a_in.
    by (constructor 2).
Qed.

Lemma tokenai :
  forall n,
    [seq match ab with
         | A n' => A n'
         | B n' => if n' == n.+1 then B n' else A n'
         end
         | ab <- gen_As n] = gen_As n.
Proof.
  move=> n.
  have H : [seq match ab with
                | A n' => A n'
                | B n' => if n' == n.+1 then B n' else A n'
                end | ab <- gen_As n] = [seq ab | ab <- gen_As n].
  apply map_ext_in.
  case=>//.
  move=> n' contra; exfalso.
  move: n' contra; elim: n=> //.
  move=> n IH n' /=.
  case=>//; apply/IH.

  rewrite H {H}.
  elim: n=>//.
  by move=> n IH /=; congr (_ :: _).
Qed.
