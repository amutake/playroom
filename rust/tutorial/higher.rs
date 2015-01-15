fn f(a: int, b: int) -> (|int| -> int) {
    |x: int| {
        a + b + x
    }
}

fn main() {
    println!("{}", f(10, 20)(30))
}
