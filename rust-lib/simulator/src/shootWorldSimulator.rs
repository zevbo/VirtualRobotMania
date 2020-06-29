use crate::genSimulator;
use ncollide2d::{pipeline::CollisionGroups, shape::{ShapeHandle, Ball, ConvexPolygon}};
use nphysics2d::object::{DefaultBodyHandle, BodyPartHandle, Collider, ColliderDesc, RigidBodyDesc, RigidBody, DefaultColliderHandle};
use nphysics2d::math::{Velocity, Inertia};
use crate::ncollideHelper;
use robotbed::image_helpers;
use robotbed::robotbed::{NPhysicsWorld, Robotbed};
use robotbed::display_engine;

// CG = collision group
const CG_ROBOTS: usize = 1;
const CG_BALLS: usize = 2;
const CG_WALLS: usize = 3;

struct Robot{
    balls_left : u32,
    left_input : f32,
    right_input : f32
}

impl Robot{
    pub fn new(balls_left : u32) -> Robot{
        return Robot{balls_left, left_input: 0., right_input: 0.};
    }
    pub fn make_body(&self) -> RigidBody<f32>{
        return RigidBodyDesc::new()
            .gravity_enabled(false)
            .velocity(Velocity::linear(0.0, 0.0))
            .linear_damping(2.0)
            .angular_damping(2.0)
            .angular_inertia(3.0)
            .mass(1.2)
            .build();
    }
    pub fn make_collider(&self, robotBodyHandle : DefaultBodyHandle) -> Collider<f32, DefaultColliderHandle>{
        let shape = ncollideHelper::rectangle_shape(ROBOT_WIDTH, ROBOT_LENGTH);
        return ColliderDesc::new(shape)
            .collision_groups(CollisionGroups::new()
                .with_membership(&[CG_ROBOTS])
                .with_whitelist(&[CG_WALLS]))
            .build(BodyPartHandle(robotBodyHandle, 0));
    }
}
pub struct WorldData{
    robot : Robot,
}

const ROBOT_WIDTH: f32 = 50.;
const ROBOT_LENGTH: f32 = 75.;
const WORLD_WIDTH: i32 = 400;
const WORLD_HEIGHT: i32 = 400;

fn new_nphysics_world() -> NPhysicsWorld{
    let mut nphysics_world = NPhysicsWorld::new_empty();
    return nphysics_world;
}

pub fn new_robotbed(robot_img_path: &str) -> Robotbed<WorldData>{
    let img = image_helpers::download_img(robot_img_path);
    let robot = Robot::new(3);
    let mut nphysics_world = new_nphysics_world();
    let robotBodyHandle = nphysics_world.bodies.insert(robot.make_body());
    let robotColliderHandle = nphysics_world.colliders.insert(robot.make_collider(robotBodyHandle));
    let world_data = WorldData{robot};
    let mut robotbed = genSimulator::make_robotbed(nphysics_world, world_data);
    robotbed.add_collider_image(robotColliderHandle, img, String::from("main"));
    robotbed.set_collider_image(robotColliderHandle, String::from("main"));
    return robotbed;
}

pub fn run_robotbed(robotbed : Robotbed<WorldData>){
    robotbed::display_engine::run_robotbed(robotbed, WORLD_WIDTH, WORLD_HEIGHT)
}