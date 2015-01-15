fn main() {
    let x = 15;
    fn f(x: i32) -> i32 {
        x + 10
    }
    let g = |&: y| {
        x + y
    };
    println!("{}", f(x));
    println!("{}", g(x));
}
