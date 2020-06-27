use nphysics2d::world::{DefaultMechanicalWorld, DefaultGeometricalWorld};
use nphysics2d::object::{DefaultBodySet, DefaultColliderSet, DefaultBodyHandle, DefaultColliderHandle};
use nphysics2d::joint::{DefaultJointConstraintSet};
use nphysics2d::force_generator::{DefaultForceGeneratorSet};
use image::ImageBuffer;
use crate::aliases::ImgBuf;
use crate::image_helpers::{resize, scale_img};
use std::ptr::null;

// not sure every one of these should be default
// just going with that for le momento
// also these types should almost certianly be gotten from aliasses from the simulator package
pub struct BodyImage{image: ImgBuf, handle: DefaultBodyHandle}
pub struct ColliderImage{image: ImgBuf, handle: DefaultColliderHandle}
pub struct Robotbed{
    mechanical_world : DefaultMechanicalWorld<f32>, 
    geometrical_world : DefaultGeometricalWorld<f32>, 
    bodies : DefaultBodySet<f32>, 
    colliders : DefaultColliderSet<f32>, 
    joint_constraints : DefaultJointConstraintSet<f32>, 
    force_generators : DefaultForceGeneratorSet<f32>, // I'm not sure if f32 makes sense here
    body_images : Vec<BodyImage>,
    collider_images : Vec<ColliderImage>,
}

pub enum ImgFit{
    None,
    // scale fits will keeps the ratio of width/height
    ScaleWidth,
    ScaleHeight,
    ScaleBarely, // largest scale that both the width and height fit
    ScaleNearly, // largest scale where one of the width or height fits
    ScaleMinPad(i32, i32), // largest scale that both the width and height fit by the number of pixels given for each side (width, height)
    ScaleMaxPad(i32, i32), // largest scale that one of width and height fit by the number of pixels given for each side (width, height)
    ScaleMinPadPer(f32, f32), // largest scale that both the width and height fit by the percentage of pixels given for each side (width, height)
    ScaleMaxPadPer(f32, f32), // largest scale that one of width and height fit by the percentage of pixels given for each side (width, height)

    StretchTight, // fits so that width and height are exactly the bodies size
    StretchPad(i32, i32), 
    StretchPadPer(f32, f32), 
}

fn min(n1 : f32, n2 : f32) -> f32{return if n1 < n2 {n1} else {n2};}
fn max(n1 : f32, n2 : f32) -> f32{return if n1 > n2 {n1} else {n2};}

fn scale_image(image : ImgBuf, width : u32, height : u32, fit : ImgFit) -> ImgBuf{
    let fl_width = width as f32;
    let fl_height = height as f32;
    let im_width = width as f32;
    let im_height = height as f32;
    let new_scale =
        match fit {
            ImgFit::ScaleWidth => fl_width / im_width,
            ImgFit::ScaleHeight => fl_height / im_height,
            ImgFit::ScaleBarely => min(fl_width / im_width, fl_height / im_height),
            ImgFit::ScaleNearly => max(fl_width / im_width, fl_height / im_height),
            ImgFit::ScaleMinPad(width_pad, height_pad) =>
                min(fl_width  / (im_width  - 2.0 * width_pad  as f32), 
                    fl_height / (im_height - 2.0 * height_pad as f32)),
            ImgFit::ScaleMaxPad(width_pad, height_pad) =>
                max(fl_width  / (im_width  - 2.0 * width_pad  as f32), 
                    fl_height / (im_height - 2.0 * height_pad as f32)),
            ImgFit::ScaleMinPadPer(width_pad, height_pad) =>
                min(fl_width  / (im_width  * (1.0 - width_pad)), 
                    fl_height / (im_height * (1.0 - height_pad))),
            ImgFit::ScaleMaxPadPer(width_pad, height_pad) =>
                max(fl_width  / (im_width  * (1.0 - width_pad)), 
                    fl_height / (im_height * (1.0 - height_pad))),
            _ => 0.0,
        };
    let (new_width, new_height) =
        match fit {
            ImgFit::StretchTight => (width, height),
            ImgFit::StretchPad(width_pad, height_pad) =>
                ((image.width() as i32 - 2 * width_pad)  as u32, 
                (image.height() as i32 - 2 * height_pad) as u32),
            ImgFit::StretchPadPer(width_pad, height_pad) =>
                ((im_width  * (1.0 - width_pad)).floor()  as u32, 
                (im_height * (1.0 - height_pad)).floor() as u32),
            _ => (0, 0),
        };
    if new_scale == 0.0{
        return scale_img(image, new_scale);
    } else {
        return resize(image, new_width, new_height);
    }
}

impl Robotbed {

    pub fn new(mechanical_world : DefaultMechanicalWorld<f32>, 
        geometrical_world : DefaultGeometricalWorld<f32>, 
        bodies : DefaultBodySet<f32>, 
        colliders : DefaultColliderSet<f32>, 
        joint_constraints : DefaultJointConstraintSet<f32>, 
        force_generators : DefaultForceGeneratorSet<f32>) -> Robotbed{
            return Robotbed{mechanical_world, geometrical_world, bodies, colliders, joint_constraints, force_generators, 
                body_images: Vec::new(), collider_images: Vec::new()};
    }

    /*pub fn set_body_image(&self, handle, image : ImgBuf, fit : ImageFit){

    }*/

} 