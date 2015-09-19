Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defencive.

Require Import ssreflect ssrfun ssrbool ssrnat div eqtype seq.
Require Import Morphisms Relations RelationClasses.

Section Mod3.
  Locate "%%".
  Eval compute in (5 %% 3).

  Definition mod3_equiv : relation nat :=
    fun n m : nat => n %% 3 = m %% 3.

  Lemma mod3_equiv_refl : Reflexive mod3_equiv.
  Proof.
      by [].
  Qed.

  Lemma mod3_equiv_sym : Symmetric mod3_equiv.
  Proof.
    by [].
  Qed.

  Lemma mod3_equiv_trans : Transitive mod3_equiv.
  Proof.
    move=> x y z.
    rewrite/mod3_equiv.
    by move=> -> ->.
  Qed.

  Instance mod3_equiv_Equiv : Equivalence mod3_equiv.
  Proof.
    split;
    [ exact: mod3_equiv_refl
    | exact: mod3_equiv_sym
    | exact: mod3_equiv_trans
    ].
  Qed.

  Infix "==_mod3" := mod3_equiv (at level 70).

  Instance succ_proper (n : nat) : Proper (mod3_equiv ==> mod3_equiv) S.
  Proof.
    elim=> [|x IHx]; elim=> [|y IHy] H.
    - by [].
    - rewrite/mod3_equiv.
  Abort.
End Mod3.

Module Equivalence.

  Definition axiom T (R : relation T) (r : rel T) :=
    forall x y, reflect (R x y) (r x y).

  Structure mixin_of T (R : relation T) := Mixin {
                                               op : rel T;
                                               _ : Equivalence R;
                                               _ : axiom R op
                                             }.
  Notation class_of := mixin_of (only parsing).

  Section ClassDef.

    Structure type := Pack {
                          sort;
                          R : relation sort;
                          _ : class_of R;
                          _ : Type
                        }.
    Print type.
    Local Coercion sort : type >-> Sortclass.
    Variables (T : Type) (RT : relation T) (cT : type).

    Print Equality.class.
    Print sort.
    Print R.
    Check (@R cT).
    Definition class := let: Pack _ _ c _ := cT return class_of (@R cT) in c.

    Definition pack c := @Pack T RT c T.

    Definition clone := fun c & cT -> T & phant_id (pack c) cT => pack c.
  End ClassDef.

  Module Exports.
    Coercion sort : type >-> Sortclass.
    Notation equivType := type.
    Notation EquivMixin := Mixin.
    Notation EquivType T m := (@pack T m).
    Notation "[ 'equivMixin' 'of' T ]" := (class _ : mixin_of T)
                                         (at level 0, format "[ 'equivMixin'  'of'  T ]") : form_scope.
    Notation "[ 'equivType' 'of' T 'for' C ]" := (@clone T C _ idfun id)
                                                (at level 0, format "[ 'equivType'  'of'  T  'for'  C ]") : form_scope.
    Notation "[ 'equivType' 'of' T ]" := (@clone T _ _ id id)
                                        (at level 0, format "[ 'equivType'  'of'  T ]") : form_scope.
  End Exports.

End Equivalence.
Export Equivalence.Exports.

Check perm_eq_mem.
Locate "=i".
Print eq_mem.
Print in_mem.
Print mem.
Print mem_pred.
Definition equiv_op T := Equivalence.op (Equivalence.class T).

Lemma equivE T x : equiv_op x = Equivalence.op (Equivalence.class T) x.
Proof. by []. Qed.

Lemma equivP T : Equivalence.axiom (@equiv_rel T) (@equiv_op T).
Proof. by case: T => ? []. Qed.
Arguments equivP [T x y].

Delimit Scope equiv_scope with EQUIV.
Open Scope equiv_scope.

Notation "x == y" := (equiv_op x y)
                       (at level 70, no associativity) : bool_scope.
Notation "x == y :> T" := ((x : T) == (y : T))
                            (at level 70, y at next level) : bool_scope.
Notation "x != y" := (~~ (x == y))
                       (at level 70, no associativity) : bool_scope.
Notation "x != y :> T" := (~~ (x == y :> T))
                            (at level 70, y at next level) : bool_scope.
Notation "x === y" := (equiv_rel x y)
                       (at level 70, no associativity) : type_scope.
Notation "x === y :> T" := ((x : T) === (y : T))
                            (at level 70, y at next level) : type_scope.
Notation "x !== y" := (~ (x === y))
                       (at level 70, no associativity) : type_scope.
Notation "x !== y :> T" := (~ (x === y :> T))
                            (at level 70, y at next level) : type_scope.
Notation "x =P y" := (equivP : reflect (x = y) (x == y))
                       (at level 70, no associativity) : equiv_scope.
Notation "x =P y :> T" := (equivP : reflect (x = y :> T) (x == y :> T))
                            (at level 70, y at next level, no associativity) : equiv_scope.

Prenex Implicits equiv_rel equiv_op equivP.

Lemma equiv_refl (T : equivType) (x : T) : x == x.
Proof.

  exact/equivP. Qed.
Notation eqxx := eq_refl.

Lemma eq_sym (T : eqType) (x y : T) : (x == y) = (y == x).
Proof. exact/eqP/eqP. Qed.

Hint Resolve eq_refl eq_sym.
