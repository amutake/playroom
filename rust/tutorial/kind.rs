struct IdentityT<M, A> {
    run_identity: M<A>
}

// fn run_identity_t<M, A>(i: IdentityT<M, A>) -> M<A> {
//     match i {
//         Identity(m) => m
//     }
// }

enum List<A> {
    Nil,
    Cons(A, List<A>)
}

fn head<A>(l: List<A>) -> Option<A> {
    match l {
        Nil => None,
        Cons(a, _) => Some(a)
    }
}

fn main() {
    let i = IdentityT{ run_identity: Cons(0i, Nil)};
    let n = head(i.run_identity);
    println!("{}", n);
}
