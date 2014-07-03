use std::io::stdio;

enum List<T> {
    Nil,
    Cons(T, Box<List<T>>)
}

fn head<T>(l: List<T>) -> Option<T> {
    match l {
        Nil => None,
        Cons(t, _) => Some(t)
    }
}

fn main() {
    let str_list = Cons("Rust", box Cons("Haskell", box Cons("OCaml", box Nil)));
    stdio::println(head(str_list).unwrap_or("nil"));
}
