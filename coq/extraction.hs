module Extraction where

import qualified Prelude

data MyList__Coq_mylist a =
   MyList__Coq_my_nil
 | MyList__Coq_my_cons a (MyList__Coq_mylist a)

_MyList__mylist_rect :: a2 -> (a1 -> (MyList__Coq_mylist a1) -> a2 -> a2) ->
                        (MyList__Coq_mylist a1) -> a2
_MyList__mylist_rect f f0 m =
  case m of {
   MyList__Coq_my_nil -> f;
   MyList__Coq_my_cons y m0 -> f0 y m0 (_MyList__mylist_rect f f0 m0)}

_MyList__mylist_rec :: a2 -> (a1 -> (MyList__Coq_mylist a1) -> a2 -> a2) ->
                       (MyList__Coq_mylist a1) -> a2
_MyList__mylist_rec =
  _MyList__mylist_rect

_MyList__my_map :: (a1 -> a2) -> (MyList__Coq_mylist a1) ->
                   MyList__Coq_mylist a2
_MyList__my_map f l =
  case l of {
   MyList__Coq_my_nil -> MyList__Coq_my_nil;
   MyList__Coq_my_cons h t -> MyList__Coq_my_cons (f h) (_MyList__my_map f t)}

