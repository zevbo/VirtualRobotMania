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
use simulator::aliases::{MechWorld, GeoWorld, Bodies, Colliders, Constraints, ForceGens, ColliderHandle};
use crate::display_engine::{Item, start_game_thread};

// not sure every one of these should be default
// just going with that for le momento
// also these types should almost certianly be gotten from aliasses from the simulator package
pub struct Robotbed{
    width: u32,
    height: u32,
    mechanical_world : MechWorld, 
    geometrical_world : GeoWorld, 
    bodies : Bodies, 
    colliders : Colliders, 
    constraints : Constraints, 
    force_generators : ForceGens, // I'm not sure if f32 makes sense here
    collider_images : Vec<ImgBuf>,
    collider_items : HashMap<ColliderHandle, Item>,
    collider_image_ids : HashMap<(ColliderHandle, String), usize>,
    collider_img_names : HashMap<ColliderHandle, String>,
    curr_img_id : usize,
    callback : fn(&MechWorld, &GeoWorld, &Bodies, &Colliders, &Constraints, &ForceGens) -> ()
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

fn unpack_def<'a, T>(opt: std::option::Option<&'a T>, default: &'a T) -> &'a T {
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
        mechanical_world : MechWorld, 
        geometrical_world : GeoWorld, 
        bodies : Bodies, 
        colliders : Colliders, 
        constraints : Constraints, 
        force_generators : ForceGens) -> Robotbed{
            return Robotbed{width, height, mechanical_world, geometrical_world, bodies, colliders, constraints, force_generators, 
                collider_images: Vec::new(), collider_items: HashMap::new(), collider_image_ids: HashMap::new(), 
                collider_img_names: HashMap::new(), curr_img_id: 0, callback: |_,_,_,_,_,_|{}};
    }

    pub fn make_collider_item(&mut self, handle : DefaultColliderHandle){
        let item = Item{position:(0.,0.), scale:(1.,1.), rotation:0., image_id: 0};
        self.collider_items.insert(handle, item);
        self.update_collider_item(handle);
    }

    pub fn add_collider_image(&mut self, handle : DefaultColliderHandle, image : ImgBuf, img_name : String){
        let collider = self.colliders.get(handle).unwrap();
        let (width, height) = width_and_height(collider.shape());
        //let scaled_img = scale_image(image, width as u32, height as u32, ImgFit::None);
        self.collider_image_ids.insert((handle, img_name), self.curr_img_id);
        self.collider_images.push(image);
        self.curr_img_id += 1;
    }

    pub fn set_collider_image(&mut self, handle : DefaultColliderHandle, img_name : String){
        if self.collider_image_ids.contains_key(&(handle, img_name.clone())){
            self.collider_img_names.insert(handle, img_name);
        } else {
            println!("INTERNAL ERROR: collider {:?} has no image named {:?}", handle, img_name);
        }
    }

    pub fn run_callback(&self){
        (self.callback)(&self.mechanical_world, &self.geometrical_world, &self.bodies, &self.colliders, &self.constraints, &self.force_generators)
    }

    pub fn get_items(&self) -> Vec<Item>{
        let mut items = Vec::new();
        for (handle, _collider) in self.colliders.iter(){
            items.push(*self.collider_items.get(&handle).unwrap());
        }
        return items;
    }

    pub fn run(&mut self){
        let sender = start_game_thread(self.collider_images.clone(), self.width as i32, self.height as i32);
        let mut handles = Vec::new();
        for (handle, _collider) in self.colliders.iter(){
            handles.push(handle);
        }
        for handle in handles {
            self.make_collider_item(handle);
        }
        loop {
            //handle_input_events();
            self.mechanical_world.step(
                        &mut self.geometrical_world,
                        &mut self.bodies,
                        &mut self.colliders,
                        &mut self.constraints,
                        &mut self.force_generators,
                    );
            self.run_callback();
            sender.send(self.get_items()).unwrap();
            std::thread::sleep(std::time::Duration::from_millis(16));
        }
    }

    fn get_collider_image_id(&self, handle : DefaultColliderHandle) -> usize{
        let name = self.collider_img_names.get(&handle).unwrap().clone();
        return *self.collider_image_ids.get(&(handle, name)).unwrap();
    }

    fn update_collider_item(&mut self, handle: DefaultColliderHandle){
        let collider = self.colliders.get(handle).unwrap();
        let pos = *collider.position();
        // currently not using rotation b/c we don't know how it is represented
        let rotation = 0.0; // pos.rotation.into_inner().re;
        let vec = pos.translation.vector;
        let img_id = self.get_collider_image_id(handle);
        let mut item = *self.collider_items.get(&handle).unwrap();
        item.position = (vec.x, vec.y);
        item.rotation = rotation;
        item.image_id = img_id;
    }

} 