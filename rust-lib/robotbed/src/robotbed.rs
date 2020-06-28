use nphysics2d::world::{DefaultMechanicalWorld, DefaultGeometricalWorld};
use nphysics2d::object::{DefaultBodySet, DefaultColliderSet, DefaultBodyHandle, DefaultColliderHandle, Collider};
use nphysics2d::joint::{DefaultJointConstraintSet};
use nphysics2d::force_generator::{DefaultForceGeneratorSet};
use image::ImageBuffer;
use crate::aliases::ImgBuf;
use crate::image_helpers::{resize, scale_img, rotate_overlay};
use std::ptr::null;
use ncollide2d::shape::Shape;
use ncollide2d::shape::ConvexPolyhedron;
use std::collections::HashMap;

// not sure every one of these should be default
// just going with that for le momento
// also these types should almost certianly be gotten from aliasses from the simulator package
pub struct ColliderImage{image: ImgBuf, handle: DefaultColliderHandle}
pub struct Robotbed{
    width: u32,
    height: u32,
    mechanical_world : DefaultMechanicalWorld<f32>, 
    geometrical_world : DefaultGeometricalWorld<f32>, 
    bodies : DefaultBodySet<f32>, 
    colliders : DefaultColliderSet<f32>, 
    joint_constraints : DefaultJointConstraintSet<f32>, 
    force_generators : DefaultForceGeneratorSet<f32>, // I'm not sure if f32 makes sense here
    collider_images : HashMap<DefaultColliderHandle, ImgBuf>,
    callback : fn(DefaultMechanicalWorld<f32>, DefaultGeometricalWorld<f32>, DefaultBodySet<f32>, DefaultColliderSet<f32>,
        DefaultJointConstraintSet<f32>,  DefaultForceGeneratorSet<f32>) -> ()
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

fn unpack<'a, T>(opt: std::option::Option<&'a T>, default: &'a T) -> &'a T {
    match opt {
        Some(val) => return val,
        None => default,
    }
}

// I dunno what dyn means, but it get's mad at me if I don't
fn width_and_height(_shape : &dyn Shape<f32>) -> (f32, f32){
    // choosing to do this with ConvexPolyhedron, might be wrong 
    // don't know how to do this yet. For the moment we should just use None
    return (0.0, 0.0);
}

fn scale_image(image : ImgBuf, width : u32, height : u32, fit : ImgFit) -> ImgBuf{
    let fl_width = width as f32;
    let fl_height = height as f32;
    let im_width = image.width() as f32;
    let im_height = image.height() as f32;
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
    if new_scale != 0.0{
        return scale_img(image, new_scale);
    } else if new_width != 0 {
        return resize(image, new_width, new_height);
    } else {
        return image.clone();
    }
}

impl Robotbed {

    pub fn new(width: u32, height: u32,
        mechanical_world : DefaultMechanicalWorld<f32>, 
        geometrical_world : DefaultGeometricalWorld<f32>, 
        bodies : DefaultBodySet<f32>, 
        colliders : DefaultColliderSet<f32>, 
        joint_constraints : DefaultJointConstraintSet<f32>, 
        force_generators : DefaultForceGeneratorSet<f32>) -> Robotbed{
            return Robotbed{width, height, mechanical_world, geometrical_world, bodies, colliders, joint_constraints, force_generators, 
                collider_images: HashMap::new(), callback: |_,_,_,_,_,_|{}};
    }

    pub fn set_collider_image(&mut self, handle : DefaultColliderHandle, image : ImgBuf){
        let collider_op = self.colliders.get(handle);
        match collider_op {
            Some(collider) => {
                let (width, height) = width_and_height(collider.shape());
                //let scaled_img = scale_image(image, width as u32, height as u32, ImgFit::None);
                self.collider_images.insert(handle, image); ()},
            None => ()
        }
    }

    pub fn run(&mut self){
        loop {
            //handle_input_events();
            self.mechanical_world.step(
                        &mut self.geometrical_world,
                        &mut self.bodies,
                        &mut self.colliders,
                        &mut self.joint_constraints,
                        &mut self.force_generators,
                    );
            callback(self.mechanical_world, self.geometrical_world, self.bodies, self.colliders, self.joint_constraints, self.force_generators)
        }
    }

    fn get_collider_image(&self, handle : DefaultColliderHandle) -> ImgBuf{
        match self.collider_images.get(&handle){
            Some(collider_img) => return collider_img.clone(), //not sure if there's a way to get around this clone
            None => return ImgBuf::new(0, 0),
        };
    }

    fn overlay_collider(&self, canvas: &mut ImgBuf, handle: DefaultColliderHandle){
        let collider_op = self.colliders.get(handle);
        match collider_op {
            Some(collider) => {
                let pos = *collider.position();
                // currently not using rotation b/c we don't know how it is represented
                let rotation = 0.0; // pos.rotation.into_inner().re;
                let vec = pos.translation.vector;
                let img = self.get_collider_image(handle);
                rotate_overlay(canvas, &img, vec.x as i32, vec.y as i32, rotation);
            }
            None => ()
        }
    }

    fn create_background(&self) -> ImgBuf{
        return ImgBuf::new(self.width, self.height);
    }

    fn create_image(&self) -> ImgBuf {
        let mut canvas = self.create_background();
        for (handle, _collider) in self.colliders.iter(){
            self.overlay_collider(&mut canvas, handle);
        }
        return canvas;
    }

} 