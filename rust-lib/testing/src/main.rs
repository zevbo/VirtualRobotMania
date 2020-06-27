fn twice<F: Fn(u32) -> u32>(x: u32, f: F) -> u32 {
    return f(f(x));
}

fn main() {
    let c = |x: u32| x + 1;
    let x = twice(3, c);
    println!("{}", x);
}
