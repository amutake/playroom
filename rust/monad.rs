trait Monad<M> {
    fn wrap<A>(a: A) -> &Self<A>;
    fn bind<A, B>(&self: &Self<A>, f: |A| -> &Self<B>) -> M<B>;
}

enum Identity<A> {
    I(A)
}

fn run_identity<A>(i: Identity<A>) -> A {
    match i {
        I(a) => a
    }
}

impl Monad for Identity<_> {
    fn wrap<A>(a: A) -> Identity<A> {
        I(a)
    }
    fn bind<A, B>(ma: Identity<A>, f: |A| -> Identity<B>) -> Identity<B> {
        f(run_identity(ma))
    }
}

fn main() {
    let i = I(0i);
    let plus1 = |n| { I(n + 1) };
    let n = run_identity(i.bind(plus1));
    println!("{}", n)
}
