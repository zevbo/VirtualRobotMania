extern crate throw;
extern crate core;
use image::{ImageBuffer, Rgb, Pixel};
use core::ops::Deref;

// Trying to change this so that the second ImageBuffer type can be anything that impl: Deref<Target = [Rgb<u8>::Subpixel]
//    but it says "ambiguous assosicated type"

pub fn display_image<Container: Deref<Target = [u8]>>(img_buf : ImageBuffer<Rgb<u8>,Container>){
    displayer(|| {img_buf});
}

pub fn displayer<Container: Deref<Target = [u8]>, F>(get_img: F) where F: FnOnce() -> ImageBuffer<Rgb<u8>,Container> {

    let (buffer, image_width, image_height) = image_buffer_to_buffer(get_img());

    let mut window = 
        match minifb::Window::new("Test", image_width, image_height, minifb::WindowOptions::default()) {
        Ok(win) => win,
        Err(err) => {
            println!("Unable to create window {}", err);
            return;
        }
    };

    // Limit to max ~60 fps update rate
    window.limit_update_rate(Some(std::time::Duration::from_micros(16600)));

    
    while window.is_open() && !window.is_key_down(minifb::Key::Escape) {

        // We unwrap here as we want this code to exit if it fails. Real applications may want to handle this in a different way
        window
            .update_with_buffer(&buffer, image_width, image_height)
            .unwrap();
    }
}

fn collapse_rgb(rgb : &Rgb<u8>) -> u32 {
    let r = rgb[0] as u32;
    let g = rgb[1] as u32;
    let b = rgb[2] as u32;
    return (r << 16) | (g << 8) | b;
}

fn image_buffer_to_buffer<Container: Deref<Target = [u8]>>(img_buf : ImageBuffer<Rgb<u8>, Container>) -> (Vec<u32>, usize, usize){
    let image_width  = img_buf.width()  as usize;
    let image_height = img_buf.height() as usize;
    let pixels = img_buf.pixels();
    let mut buffer = Vec::new();
    for pixel in pixels{
        buffer.push(collapse_rgb(&pixel.to_rgb()));
    }
    return (buffer, image_width, image_height);

}