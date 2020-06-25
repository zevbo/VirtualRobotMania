extern crate nalgebra as na;

use crate::foobar;

pub fn for_buildo() {
    println!("for buildooooo!!!!!");
    foobar::a();
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let mut x = nalgebra::Vector2::new(3.3, 0.3);
        let y = nalgebra::Vector2::new(3.3, 2.);
        x[1] = 2.0;
        assert_eq!(x, y);
    }
}