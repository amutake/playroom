(* http://comments.gmane.org/gmane.science.mathematics.logic.coq.club/7801 *)

Inductive Foo : Set :=
  | mkFoo : (nat + Foo) -> Foo.

Inductive P : Foo -> Prop :=
 | mkP : forall (s : nat + Foo), (forall f, (s = inr _ f) -> P f) -> P (mkFoo s).

(* Inductive P : Foo -> Prop := *)
(*   | mkP : forall (s : nat + Foo), (match s with inl n => True | inr f => P f end) -> P (mkFoo s). *)

Require Import List.

Fixpoint all_and {X} (xs : list X) (P : X -> Prop) : Prop :=
  match xs with
    | nil => True
    | cons x xs' => P x /\ all_and xs' P
  end.

Fixpoint imply (ps : list Prop) (G : Prop) : Prop :=
  match ps with
    | nil => G
    | cons p ps' => p -> imply ps' G
  end.

(* Inductive Bar : Prop := *)
(*   | bar : Bar *)
(*   | bar_all : forall (bars : list Prop), imply bars Bar. *)

Inductive Bar : Prop :=
  | bar : Bar
  | bar_all : forall (bars : list Bar) P, all_and bars P -> Bar.

case x of
  y1 -> p1
  y2 -> p2
  y3 -> p3
  _ -> nil
