Require Import List EqNat NPeano Relations.
Import ListNotations.

Inductive Exp : Type :=
| var : nat -> Exp
| app : Exp -> Exp -> Exp
| abs : Exp -> Exp.

Fixpoint ble_nat (n m : nat) : bool :=
  match n, m with
    | O, _ => true
    | _, O => false
    | S n', S m' => ble_nat n' m'
  end.

Fixpoint subst (n : nat) (e e' : Exp) : Exp :=
  match e with
    | var n' => if beq_nat n n' then e' else e
    | app e1 e2 => app (subst n e1 e') (subst n e2 e')
    | abs e'' => abs (subst (S n) e'' e')
  end.

(* e ~> e' *)
Inductive Reduce : relation Exp :=
| reduce_app : forall e1 e2, Reduce (app (abs e1) e2) (subst 0 e1 e2)
| reduce_appL : forall e1 e1' e2, Reduce e1 e1' -> Reduce (app e1 e2) (app e1' e2)
| reduce_appR : forall e1 e2 e2', Reduce e2 e2' -> Reduce (app e1 e2) (app e1 e2')
| reduce_abs : forall e e', Reduce e e' -> Reduce (abs e) (abs e').

Hint Constructors Reduce.

Inductive not_abs : Exp -> Prop :=
| not_abs_var : forall n, not_abs (var n)
| not_abs_app : forall e1 e2, not_abs (app e1 e2).

Hint Constructors not_abs.

Inductive Stop : Exp -> Prop :=
| stop_var : forall n, Stop (var n)
| stop_abs : forall e, Stop e -> Stop (abs e)
| stop_app : forall e1 e2, not_abs e1 -> Stop e1 -> Stop e2 -> Stop (app e1 e2).

Hint Constructors Stop.

(* e ~> e1 ~> e2 ~> ... ~> e' *)
Definition reduce_stop (e e' : Exp) : Prop :=
  clos_trans Exp Reduce e e' /\ Stop e'.

(* (\f. f (\x. x)) (\x. x) ~>+ \x. x *)
Example reduce_example : reduce_stop
                           (app (abs (app (var 0) (abs (var 0)))) (abs (var 0)))
                           (abs (var 0)).
Proof.
  unfold reduce_stop.
  split.
  - eapply t_trans.
    + apply t_step.
      apply reduce_app.
    + simpl.
      apply t_step.
      apply reduce_app.
  - apply stop_abs.
    apply stop_var.
Qed.

Example reduce_example2 : ~ exists e, reduce_stop
                                        (app (abs (app (var 0) (var 0))) (abs (app (var 0) (var 0))))
                                        e.
Proof.
  unfold not.
  unfold reduce_stop.
  intros H.
  inversion_clear H; subst.
  inversion_clear H0; subst.
  induction x.
  - inversion_clear H; subst.
    + inversion H0.
    +















Fixpoint size (e : Exp) : nat :=
  match e with
    | var _ => 0
    | app e1 e2 => S (size e1 + size e2)
    | abs e' => S (size e')
  end.

Require Import Omega Recdef.

Function eval (e : Exp) {measure size e} : Exp :=
  match e with
    | var _ => e
    | app (abs e1) e2 => eval (subst 0 e1 e2)
    | app e1 e2 => (app (eval e1) (eval e2))
    | abs e' => abs (eval e')
  end.
- auto.
- simpl.
  intros e e1 e2 n H H1.
  omega.
- simpl.
  intros e e1 e2 e0 e3 H H1.
  subst.
  omega.
- simpl.
  intros e e1 e2 e0 e3 H H1.
  omega.
- simpl.
  intros e e1 e2 e0 H H1.
  subst.
  assert (forall e1 e2, size (subst 0 e1 e2) = size e1 + size e2)
  induction e0.
  + simpl.
    destruct n; simpl; omega.
  + simpl.







Fixpoint up (n : nat) (e : Exp) :=
  match e with
    | var n' => var (n' + 1)
    | app e1 e2 => app (up n e1) (up n e2)
    | abs e => abs (up (S n) e)
  end.

Fixpoint set (n : nat) (e1 e2 : Exp) : Exp :=
  match e1 with
    | var n' => if beq_nat n n' then e2 else
                  if ble_nat n n' then var (n' - 1) else
                    var n'
    | app e1' e2' => app (set n e1' e2) (set n e2' e2)
    | abs e => abs (set (S n) e (up 0 e2))
  end.

Fixpoint apply (e1 e2 : Exp) : Exp :=
  match e1, e2 with
    | (var n), _ => app (var n) e2
    | (app e1' e2'), _ => app (app e1' e2') e2
    | (abs e1'), _ => eval (set 0 e1' e2)
  end
with eval (e : Exp) : Exp :=
       match e with
         | var n => var n
         | app e1 e2 => apply (eval e1) (eval e2)
         | abs e => abs (eval e)
       end.
