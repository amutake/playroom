// https://gist.github.com/amutake/5858803

#![feature(box_syntax)]

use Expr::{ Var, App, Abs };

#[derive(Clone)]
enum Expr {
    Var(u32),
    App(Box<Expr>, Box<Expr>),
    Abs(Box<Expr>),
}

impl Expr {
    fn subst(self, i: u32, e: Expr) -> Expr {
        match self {
            Var(i2) if i2 == i => e,
            v@Var(_) => v,
            App(e1, e2) => App(box e1.subst(i, e.clone()), box e2.subst(i, e.clone())),
            Abs(e2) => Abs(box e2.subst(i + 1, e)),
        }
    }

    fn eval(self) -> Expr {
        match self {
            App(e1, e2) => match *e1 {
                Abs(e) => e.subst(0, e2.eval()).eval(),
                Var(n) => App(box Var(n), box e2.eval()),
                e@App(_, _) => App(box e.eval(), e2).eval(),
            },
            e => e
        }
    }

    fn to_string(self) -> String {
        match self {
            Var(i) => format!("{}", i),
            App(e1, e2) => format!("({} {})", e1.to_string(), e2.to_string()),
            Abs(e) => format!("\\({})", e.to_string()),
        }
    }
}

fn main() {
    // s :: Expr
    // s = Abs (Abs (Abs (App (App (Var 2) (Var 0)) (App (Var 1) (Var 0)))))
    let s = Abs(box Abs(box Abs(box App(box App(box Var(2), box Var(0)), box App(box Var(1), box Var(0))))));

    // k :: Expr
    // k = Abs (Abs (Var 1))
    let k = Abs(box Abs(box Var(1)));

    // i :: Expr
    // i = Abs (Var 0)
    let i = Abs(box Var(0));

    println!("{}", s.clone().eval().to_string());

    let skk = App(box App(box s.clone(), box k.clone()), box k);

    println!("ii = {}", App(box i.clone(), box i.clone()).eval().to_string());
    println!("skki = {}", App(box skk, box i.clone()).eval().to_string());
}

// eval (App (Abs e) (Var n)) = eval (subst e 0 (Var n))
// eval (App (Abs e) (App e1 e2)) = eval (App (Abs e) (eval (App e1 e2)))
// eval (App (Abs e) (Abs e')) = eval (subst e 0 (Abs e'))
// eval (App (Var n) e) = eval (App (Var n) (eval e)) // inifinitely loop?
// eval (App (App e1 e2) e) = eval (App (eval (App e1 e2)) e)
