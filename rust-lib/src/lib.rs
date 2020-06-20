extern crate nalgebra as na;
//use na::Vector2;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let mut x = na::Vector2::new(3.3, 0.3);
        let y = na::Vector2::new(3.3, 2.);
        x = na::Vector2::new(x[0], 2.);
        assert_eq!(x, y);
    }
}
