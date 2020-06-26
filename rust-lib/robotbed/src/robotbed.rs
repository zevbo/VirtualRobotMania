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

const WIDTH: u32 = 10;
const HEIGHT: u32 = 10;

fn saveImg() {
    // a default (black) image containing Rgb values
    //let mut image = ImageBuffer::<Rgb<u8>>::new(WIDTH, HEIGHT);
    // set a central pixel to white
    //image.get_pixel_mut(5, 5).data = [255, 255, 255];

    // write it out to a file
    //image.save("output.png").unwrap();
}