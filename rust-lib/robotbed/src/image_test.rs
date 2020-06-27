extern crate nalgebra as na;

use crate::display_image;
use crate::image_helpers::{download_img, rotate_overlay, scale_down};
use image::ImageBuffer;

const WIDTH: u32 = 600;
const HEIGHT: u32 = 600;

pub fn display_img() {
    // a default (black) image containing Rgb values
    println!("downloading image...");
    let on_top_big = download_img("../pelosi.jpeg");
    println!("downloaded!");
    let on_top = scale_down(on_top_big, 0.1);
    println!("scaled!");
    let mut imgbuf = ImageBuffer::new(WIDTH, HEIGHT);
    println!("new imbuf");
    //image::imageops::overlay(&mut imgbuf, &on_top, 400, 120);
    let mut tester = || rotate_overlay(&mut imgbuf, &on_top, 400, 120, 0.1 * core::f32::consts::PI);
    tester();
    tester();
    tester();
    tester();
    tester();
    tester();
    println!("overlayed");
    display_image::display_static_image(imgbuf);
}
