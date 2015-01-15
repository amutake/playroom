trait Functor {
    fn fmap<A, B>(self: Self<A>, f: |A| -> B) -> Self<B>;
}

enum List<A> {
    Nil,
    Cons(A, List<A>)
}

// impl Functor for List {
//     fn fmap<A, B>(self: List<A>, f: |A| -> B) -> List<B> {
//         match self {
//             Nil => Nil,
//             Cons(hd, tl) => Cons(f(hd), tl.fmap(f))
//         }
//     }
// }
impl<A> List<A> {
    fn head(

fn main() {
    let l = Cons(1u, box Cons(2u, box Nil));
