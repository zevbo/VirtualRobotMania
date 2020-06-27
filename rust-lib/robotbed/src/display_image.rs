extern crate core;
extern crate throw;
use image::Pixel;
//use image::{ImageBuffer, Rgb};
//use core::ops::Deref;
use crate::aliases::{ImgBuf, ImgPxl};

#[allow(dead_code)]
pub fn display_static_image(img_buf: ImgBuf) {
    displayer(&mut || img_buf.clone());
}

pub fn display_with_tick<F: Fn(u64) -> ImgBuf>(f: F) {
    let mut i: u64 = 0;
    let mut get_img = || {
        i = i + 1;
        return f(i);
    };
    displayer(&mut get_img);
}

pub fn displayer<F: FnMut() -> ImgBuf>(get_img: &mut F) {
    let img = get_img();
    let (_buffer, image_width, image_height) = image_buffer_to_buffer(img);

    let mut window = match minifb::Window::new(
        "Test",
        image_width,
        image_height,
        minifb::WindowOptions::default(),
    ) {
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
        let (buffer, curr_image_width, curr_image_height) = image_buffer_to_buffer(get_img());
        if (curr_image_width == image_width) & (curr_image_height == image_height) {
            window
                .update_with_buffer(&buffer, image_width, image_height)
                .unwrap();
        } else {
            println!("Attempted to display image with dimensions {:?}x{:?} on a canvas with dimensions {:?}x{:?}",
        curr_image_width, curr_image_height, image_width, image_height)
        }
    }
}

fn collapse_rgb(rgb: &ImgPxl) -> u32 {
    let r = rgb[0] as u32;
    let g = rgb[1] as u32;
    let b = rgb[2] as u32;
    return (r << 16) | (g << 8) | b;
}

fn image_buffer_to_buffer(img_buf: ImgBuf) -> (Vec<u32>, usize, usize) {
    let image_width = img_buf.width() as usize;
    let image_height = img_buf.height() as usize;
    let pixels = img_buf.pixels();
    let mut buffer = Vec::new();
    for pixel in pixels {
        buffer.push(collapse_rgb(&pixel.to_rgba()));
    }
    return (buffer, image_width, image_height);
}
