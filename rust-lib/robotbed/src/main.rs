#[macro_use]
extern crate throw;

mod image_test;
mod display_image;
mod image_helpers;
mod aliases;

fn main(){
    image_test::display_img();
}