trait Monad<M> {
    fn wrap<A>(a: A) -> M<A>,
    fn bind<A, B>(ma: M<A>, f: |A| -> M<B>) -> M<B>
}

enum Identity<A> {
    I(A)
}

impl Monad<Identity> {
    fn wrap
