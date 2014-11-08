module Monoid = struct
  module type Basic = sig
    type t
    val zero : t
    val app : t -> t -> t
  end

  module type T = sig
    type t
    val zero : t
    val app : t -> t -> t
    val concat : t list -> t
  end

  module Make(M : Basic) : (T with type t = M.t) = struct
    type t = M.t
    let zero = M.zero
    let app = M.app
    let concat l = List.fold_right app l zero
  end
end

let triple (type s) (module M : Monoid.T with type t = s) a = M.concat [a;a;a]

module String_monoid = Monoid.Make
                         (struct
                           type t = string
                           let zero = ""
                           let app = (^)
                         end)

module Sum_monoid = Monoid.Make
                      (struct
                        type t = int
                        let zero = 0
                        let app = (+)
                      end)

module Product_monoid = Monoid.Make
                          (struct
                            type t = int
                            let zero = 1
                            let app = ( * )
                          end)

module Endo_monoid = Monoid.Make
                       (struct
                         type t = F : ('a -> 'a) -> t
                         let zero = F (fun x -> x)
                         let app f g = match f, g with
                           | F f', F g' -> F (fun a -> g' (f' a))
                       end)

let () =
  let hhh = triple (module String_monoid) "hoge" in
  let six = triple (module Sum_monoid) 2 in
  let sss = triple (module Product_monoid) six in
  print_endline hhh
