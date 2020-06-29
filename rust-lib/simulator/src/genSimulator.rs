use robotbed::robotbed::{Robotbed, NPhysicsWorld};

pub fn make_robotbed<Data>(nphysics_world : NPhysicsWorld, data : Data) -> Robotbed<Data>{
    return Robotbed::new(data, nphysics_world);
}