#[cfg(test)]
mod tests {
    use crate::foo;
    use na::Vector2;
    extern crate nalgebra as na;

    #[test]
    fn it_works() {
        let mut x = Vector2::new(3.3, 0.3);
        let y = Vector2::new(3.3, 2.);
        x[1] = 2.0;
        assert_eq!(x, y);
    }

    #[test]
    fn another_test() {
        assert_eq!(foo::fnurk(3, 4), 11);
    }
}
