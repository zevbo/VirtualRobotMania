use robotbed::aliases::CallbackF;
use robotbed::robotbed::{Robotbed, NPhysicsWorld};

pub fn make_robotbed<Data>(nphysics_world : NPhysicsWorld, data : Data, width : u32, height : u32) -> Robotbed<Data>{
    return Robotbed::new(width, height, data, nphysics_world);
}