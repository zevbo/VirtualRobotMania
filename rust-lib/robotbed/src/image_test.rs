extern crate nalgebra as na;

use crate::display_image;
use crate::image_helpers::scale_down;
use image::{ImageBuffer, Rgb, open};

const WIDTH: u32 = 600;
const HEIGHT: u32 = 600;

pub fn display_img() {
    // a default (black) image containing Rgb values
    println!("starting");
    let on_top_big = open("/Users/goobjar/Downloads/pelosi.JPEG").unwrap().into_rgb();
    let on_top = scale_down(on_top_big, 0.2);
    let mut imgbuf = ImageBuffer::new(WIDTH, HEIGHT);
    println!("here");
    image::imageops::overlay(&mut imgbuf, &on_top, 0, 0);
    imgbuf.put_pixel(WIDTH/2, HEIGHT/2, Rgb([200 as u8,0 as u8,0 as u8]));
    display_image::display_image(imgbuf);
    
}