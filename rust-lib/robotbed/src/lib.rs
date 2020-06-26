pub mod image_test;
pub mod display_image;
pub mod image_helpers;

#[cfg(test)]
mod tests {
    use crate::image_test;
    #[test]
    fn it_works() {
        image_test::display_img();
        assert_eq!(2 + 2, 4);
    }
}