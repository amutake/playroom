(* http://dl.acm.org/citation.cfm?doid=1411203.1411226 *)

(* Inductive term : Type := *)
(*   | App : term -> term -> term *)
(*   | Abs : (term -> term) -> term. *)
(* =>
Error: Non strictly positive occurrence of "term" in
 "(term -> term) -> term".
 *)

Inductive term (v : Type) : Type :=
  | Var : v -> term v
  | App : term v -> term v -> term v
  | Abs : (v -> term v) -> term v.

Definition Term := forall v : Type, term v.

(*** Example: numVars *)

Fixpoint numVars (t : term unit) : nat :=
  match t with
    | Var _ => 1
    | App e1 e2 => numVars e1 + numVars e2
    | Abs f => numVars (f tt)
  end.

Definition NumVars (t : Term) : nat := numVars (t unit).

(*** Example: canEta *)

Require Import Bool.

Fixpoint canEta' (t : term bool) : bool :=
  match t with
    | Var b => b
    | App e1 e2 => canEta' e1 && canEta' e2
    | Abs f => canEta' (f true)
  end.

Definition canEta (t : term bool) : bool :=
  match t with
    | Abs f => match f false with
                 | App e1 (Var false) => canEta' e1
                 | _ => false
               end
    | _ => false
  end.

Definition CanEta (t : Term) : bool := canEta (t bool).

(* \x. (\x. x) x (identity function) *)
Definition term_example1 : Term :=
  fun v =>
    Abs v (fun x =>
             App v (Abs v (fun x => Var v x)) (Var v x)).

Example can_eta_example : CanEta term_example1 = true.
Proof.
  compute; auto.
Qed.

(*** Example: subst *)

Fixpoint subst {v} (t : term (term v)) : term v :=
  match t with
    | Var e => e
    | App e1 e2 => App v (subst e1) (subst e2)
    | Abs f => Abs v (fun x => subst (f (Var v x)))
  end.

Definition Term1 := forall v, v -> term v.

Definition Subst (e1 : Term1) (e2 : Term) : Term :=
  fun v =>
    subst (e1 (term v) (e2 v)).

Lemma subst_example : Subst (fun v _ => term_example1 v) term_example1 = term_example1.
Proof.
  compute; auto.
Qed.
