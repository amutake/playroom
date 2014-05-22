CoInductive Stream (A : Type) : Type :=
| cons : A -> Stream A -> Stream A.

CoFixpoint streamMap {A B : Type} (f : A -> B) (s : Stream A) : Stream B :=
  match s with
    | cons a s' => cons B (f a) (streamMap f s')
  end.

CoFixpoint zeros := cons nat 0 zeros.

CoFixpoint ones := cons nat 1 ones.

CoInductive stream_eq {A} : Stream A -> Stream A -> Prop :=
| stream_eq_refl : forall h s1 s2, stream_eq s1 s2 -> stream_eq (cons A h s1) (cons A h s2).

Goal stream_eq (streamMap S zeros) ones.
Proof.
  cofix.
  apply stream_eq_refl.
