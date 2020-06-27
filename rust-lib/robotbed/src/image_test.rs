extern crate nalgebra as na;

use crate::display_image;
use crate::image_helpers::{download_img, rotate_overlay, scale_down};
use image::ImageBuffer;

const WIDTH: u32 = 1200;
const HEIGHT: u32 = 1200;

pub fn display_img() {
    // a default (black) image containing Rgb values
    println!("downloading image...");
    let on_top_big = download_img("../pelosi.jpeg");
    println!("downloaded!");
    let on_top = scale_down(on_top_big, 0.3);
    println!("scaled!");
    let mut imgbuf = ImageBuffer::new(WIDTH, HEIGHT);
    println!("new imbuf");
    //image::imageops::overlay(&mut imgbuf, &on_top, 400, 120);
    let mut tester =
        |x: f32| rotate_overlay(&mut imgbuf, &on_top, 400, 120, x * core::f32::consts::PI);
    let mut count = 0.;
    loop {
        count = count + 0.05;
        tester(count);
        if count > 1. {
            break;
        }
    }
    println!("overlayed");
    display_image::display_static_image(imgbuf);
}
