Require Import Coq.MSets.MSets Coq.Arith.Peano_dec Coq.Arith.Compare_dec.

Inductive hoge : Set :=
  | Hoge : nat -> hoge.

Module HogeOrderedType <: OrderedType.

  Definition t := hoge.
  Definition eq :=
    fun h1 h2 =>
      match h1, h2 with
        | Hoge n1, Hoge n2 => n1 = n2
      end.
  Lemma reflexive_eq : Reflexive eq.
  Proof.
    unfold Reflexive.
    intros.
    destruct x.
    simpl.
    auto.
  Qed.
  Lemma symmetric_eq : Symmetric eq.
  Proof.
    unfold Symmetric.
    intros.
    destruct x.
    destruct y.
    simpl.
    simpl in H.
    auto.
  Qed.
  Lemma transitive_eq : Transitive eq.
  Proof.
    unfold Transitive.
    intros.
    destruct x; destruct y; destruct z.
    simpl; simpl in H; simpl in H0.
    rewrite H.
    rewrite H0.
    auto.
  Qed.
  Definition eq_equiv :=
    Build_Equivalence hoge eq reflexive_eq symmetric_eq transitive_eq.

  Definition lt :=
    fun h1 h2 =>
      match h1, h2 with
        | Hoge n1, Hoge n2 => lt n1 n2
      end.
  Lemma irreflexive_lt : Irreflexive lt.
  Proof.
    unfold Irreflexive.
    unfold Reflexive.
    unfold complement.
    intros.
    destruct x.
    simpl in H.
    omega.
  Qed.
  Lemma transitive_lt : Transitive lt.
  Proof.
    unfold Transitive.
    intros.
    destruct x; destruct y; destruct z.
    simpl; simpl in H; simpl in H0.
    omega.
  Qed.
  Definition lt_strorder :=
    Build_StrictOrder hoge lt irreflexive_lt transitive_lt.
  Definition lt_compat : Proper (eq ==> eq ==> iff) lt.
  Proof.
    unfold Proper.
    unfold respectful.
    unfold iff.
    intros.
    destruct x, y, x0, y0.
    simpl; simpl in H, H0.
    omega.
  Qed.
  Definition compare :=
    fun h1 h2 =>
      match h1, h2 with
        | Hoge n1, Hoge n2 => nat_compare n1 n2
      end.
  Definition compare_spec : forall x y : t,
                              CompareSpec (eq x y) (lt x y) (lt y x) (compare x y).
  Proof.
    unfold t.
    intros.
    destruct x, y.
    simpl.
    remember (nat_compare n n0).
    destruct c.
      apply CompEq.
      apply nat_compare_eq.
      auto.

      apply CompLt.
      apply nat_compare_lt.
      auto.

      apply CompGt.
      apply nat_compare_gt.
      auto.
  Qed.

  Definition eq_dec : forall x y : t, {eq x y} + {~ eq x y}.
  Proof.
    unfold t.
    intros.
    destruct x, y.
    simpl.
    apply eq_nat_dec.
  Qed.
End HogeOrderedType.

(* Module Type OrderedType = *)
(*  Sig *)
(*    Parameter t : Type. *)
(*    Parameter eq : t -> t -> Prop. *)
(*    Parameter eq_equiv : Equivalence eq. *)
(*    Parameter lt : t -> t -> Prop. *)
(*    Parameter lt_strorder : StrictOrder lt. *)
(*    Parameter lt_compat : Proper (eq ==> eq ==> iff) lt. *)
(*    Parameter compare : t -> t -> comparison. *)
(*    Parameter compare_spec : *)
(*      forall x y : t, CompareSpec (eq x y) (lt x y) (lt y x) (compare x y). *)
(*    Parameter eq_dec : forall x y : t, {eq x y} + {~ eq x y}. *)
(*  End *)

(* Record Equivalence (A : Type) (R : relation A) : Prop := Build_Equivalence *)
(*   { Equivalence_Reflexive : Reflexive R; *)
(*     Equivalence_Symmetric : Symmetric R; *)
(*     Equivalence_Transitive : Transitive R } *)

(* relation = fun A : Type => A -> A -> Prop *)
(*      : Type -> Type *)

(* Reflexive = *)
(* fun (A : Type) (R : relation A) => forall x : A, R x x *)
(*      : forall A : Type, relation A -> Prop *)

(* Symmetric = *)
(* fun (A : Type) (R : relation A) => forall x y : A, R x y -> R y x *)
(*      : forall A : Type, relation A -> Prop *)

(* Transitive = *)
(* fun (A : Type) (R : relation A) => forall x y z : A, R x y -> R y z -> R x z *)
(*      : forall A : Type, relation A -> Prop *)

(* Irreflexive =  *)
(* fun (A : Type) (R : relation A) => Reflexive (complement R) *)
(*      : forall A : Type, relation A -> Prop *)

(* Record StrictOrder (A : Type) (R : relation A) : Prop := Build_StrictOrder *)
(*   { StrictOrder_Irreflexive : Irreflexive R; *)
(*     StrictOrder_Transitive : Transitive R } *)

(* Proper = *)
(* fun (A : Type) (R : relation A) (m : A) => R m m *)
(*      : forall A : Type, relation A -> A -> Prop *)

(* respectful =  *)
(* fun (A B : Type) (R : relation A) (R' : relation B) (f g : A -> B) => *)
(* forall x y : A, R x y -> R' (f x) (g y) *)
(*      : forall A B : Type, relation A -> relation B -> relation (A -> B) *)

(* Inductive CompareSpec (Peq Plt Pgt : Prop) : comparison -> Prop := *)
(*     CompEq : Peq -> CompareSpec Peq Plt Pgt Eq *)
(*   | CompLt : Plt -> CompareSpec Peq Plt Pgt Lt *)
(*   | CompGt : Pgt -> CompareSpec Peq Plt Pgt Gt *)


Module HogeSets := MSetList.Ops(HogeOrderedType).

Definition single_hoge := HogeSets.singleton(Hoge O).
