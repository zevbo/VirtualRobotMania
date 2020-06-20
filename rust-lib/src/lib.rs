extern crate nalgebra as na;
//use nalgebra::Vector2;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let mut x = na::Vector2::new(3.3, 0.3);
        let y = na::Vector2::new(3.3, 2.);
        x[1] = 2.0;
        assert_eq!(x, y);
    }
}
