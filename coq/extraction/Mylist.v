Inductive mylist (A : Set) : Set :=
| my_nil : mylist A
| my_cons : A -> mylist A -> mylist A.

Arguments my_nil {A}.
Arguments my_cons {A} _ _.

Fixpoint map {A B : Set} (f : A -> B) (l : mylist A) : mylist B :=
  match l with
    | my_nil => my_nil
    | my_cons h t => my_cons (f h) (map f t)
  end.

Fixpoint length {A : Set} (l : mylist A) : nat :=
  match l with
    | my_nil => 0
    | my_cons _ t => S (length t)
  end.
