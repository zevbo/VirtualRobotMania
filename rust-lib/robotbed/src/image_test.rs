extern crate nalgebra as na;

use na::{Point2, Vector2};
use ncollide2d::shape::{Ball, Cuboid, ShapeHandle};
use nphysics2d::force_generator::DefaultForceGeneratorSet;
use nphysics2d::joint::DefaultJointConstraintSet;
use nphysics2d::object::{
    BodyPartHandle, ColliderDesc, DefaultBodySet, DefaultColliderSet, Ground, RigidBodyDesc,
};
use nphysics2d::world::{DefaultGeometricalWorld, DefaultMechanicalWorld};

use image::{ImageBuffer, Rgb};

const WIDTH: u32 = 600;
const HEIGHT: u32 = 600;

pub fn collapse_rgb(rgb : &Rgb<u8>) -> u32{
    let r = rgb[0] as u32;
    let g = rgb[1] as u32;
    let b = rgb[2] as u32;
    return (r << 16) | (g << 8) | b;
}

const DISPLAY_WIDTH: usize = WIDTH as usize;
const DISPLAY_HEIGHT: usize = HEIGHT as usize;

pub fn displayer(buffer : &mut Vec<u32>) {

    let mut window = 
        match minifb::Window::new("Test", DISPLAY_WIDTH, DISPLAY_HEIGHT, minifb::WindowOptions::default()) {
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
            .update_with_buffer(&buffer, DISPLAY_WIDTH, DISPLAY_HEIGHT)
            .unwrap();
    }
}

pub fn display_img() {
    // a default (black) image containing Rgb values
    let mut imgbuf = image::ImageBuffer::new(WIDTH, HEIGHT);
    imgbuf.put_pixel(WIDTH/2, HEIGHT/2, image::Rgb([200 as u8,0 as u8,0 as u8]));
    let pixels = imgbuf.pixels();
    let mut displayable_vec = Vec::new();
    for rgb in pixels{
        displayable_vec.push(collapse_rgb(rgb));
    }    

    // write it out to a file
    //imgbuf.save("output.png").unwrap();
    displayer(&mut displayable_vec);
    
}