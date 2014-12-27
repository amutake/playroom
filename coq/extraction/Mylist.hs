module Mylist where

import qualified Prelude
import qualified Datatypes


data Coq_mylist a =
   Coq_my_nil
 | Coq_my_cons a (Coq_mylist a)

mylist_rect :: a2 -> (a1 -> (Coq_mylist a1) -> a2 -> a2) -> (Coq_mylist 
               a1) -> a2
mylist_rect f f0 m =
  case m of {
   Coq_my_nil -> f;
   Coq_my_cons y m0 -> f0 y m0 (mylist_rect f f0 m0)}

mylist_rec :: a2 -> (a1 -> (Coq_mylist a1) -> a2 -> a2) -> (Coq_mylist 
              a1) -> a2
mylist_rec =
  mylist_rect

map :: (a1 -> a2) -> (Coq_mylist a1) -> Coq_mylist a2
map f l =
  case l of {
   Coq_my_nil -> Coq_my_nil;
   Coq_my_cons h t -> Coq_my_cons (f h) (map f t)}

length :: (Coq_mylist a1) -> Datatypes.Coq_nat
length l =
  case l of {
   Coq_my_nil -> Datatypes.O;
   Coq_my_cons a t -> Datatypes.S (length t)}

