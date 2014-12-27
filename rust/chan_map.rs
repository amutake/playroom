use std::fmt::Show;
use std::io::timer;
use std::time::Duration;

trait Function<A, B> {
    fn apply(&self, a: A) -> B;
}

struct Add {
    v: uint
}

impl Function<uint, uint> for Add {
    fn apply(&self, n: uint) -> uint {
        self.v + n
    }
}

fn cmap<A: Send, B: Send + Show, F: Function<A, B> + Send>(rxa: Receiver<A>, f: F) -> Receiver<B> {
    let (txb, rxb) = channel();
    spawn(proc() {
        for a in rxa.iter() {
            txb.send(f.apply(a));
        };
    });
    rxb
}

fn cforeach<A: Send>(rx: Receiver<A>, f: |A|) {
    for a in rx.iter() {
        f(a);
    }
}

fn main() {
    let (tx, rx) = channel();
    spawn(proc() {
        let mut n = 0u;
        loop {
            tx.send(n);
            n += 1;
            timer::sleep(Duration::seconds(1));
        };
    });
    let rx2 = cmap(rx, Add { v: 1 });
    cforeach(rx2, |b| println!("{}", b));
}
