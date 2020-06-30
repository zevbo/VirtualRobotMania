extern crate nalgebra as na;

use crate::genSimulator;
use ncollide2d::{pipeline::CollisionGroups, shape::{ShapeHandle, Ball, ConvexPolygon}};
use nphysics2d::object::{DefaultBodyHandle, BodyPartHandle, Collider, ColliderDesc, RigidBodyDesc, RigidBody, DefaultColliderHandle};
use nphysics2d::{algebra::Velocity2, math::{Velocity, Inertia}};
use crate::ncollideHelper;
use robotbed::image_helpers;
use robotbed::robotbed::{NPhysicsWorld, Robotbed};
use robotbed::display_engine;
use robotbed::aliases::ImgBuf;
use na::Vector2;

// CG = collision group
const CG_ROBOTS: usize = 1;
const CG_BALLS: usize = 2;
const CG_WALLS: usize = 3;

pub struct Robot{
    pub balls_left : u32,
    pub left_input : f32,
    pub right_input : f32
}

impl Robot{
    pub fn new(balls_left : u32) -> Robot{
        return Robot{balls_left, left_input: 0., right_input: 0.};
    }
    pub fn make_body(&self) -> RigidBody<f32>{
        return RigidBodyDesc::new()
            .gravity_enabled(false)
            .linear_damping(0.)
            .angular_damping(10.)
            .angular_inertia(3.0)
            .velocity(Velocity::linear(100.0, 0.0))
            .max_linear_velocity(100.0)
            .max_angular_velocity(0.0)
            .mass(1.2)
            .build();
    }
    pub fn make_collider(&self, robotBodyHandle : DefaultBodyHandle) -> Collider<f32, DefaultColliderHandle>{
        let shape = ncollideHelper::rect_shape(ROBOT_WIDTH, ROBOT_LENGTH);
        return ColliderDesc::new(shape)
            .collision_groups(CollisionGroups::new()
                .with_membership(&[CG_ROBOTS])
                .with_whitelist(&[CG_WALLS]))
            .build(BodyPartHandle(robotBodyHandle, 0));
    }
}

fn make_wall_image(length : f32, width : f32) -> ImgBuf{
    return ImgBuf::from_fn(length as u32, width as u32, |_x, _y|{return image::Rgba([0,0,0,255])});
}

fn add_wall_data(robotbed : &mut Robotbed<WorldData>, center : Vector2<f32>, length : f32, width : f32, angle : f32){
    let body = RigidBodyDesc::new()
        .gravity_enabled(false)
        .translation(center)
        .mass(f32::INFINITY)
        .max_linear_velocity(0.0)
        .max_angular_velocity(0.0)
        .rotation(angle)
        .build();
    let body_handle = robotbed.nphysics_world.bodies.insert(body);
    let shape = ncollideHelper::rect_shape(length, width);
    let collider =
        ColliderDesc::new(shape)
        .collision_groups(CollisionGroups::new()
            .with_membership(&[CG_WALLS]))
        .build(BodyPartHandle(body_handle, 0));
    let collider_handle = robotbed.nphysics_world.colliders.insert(collider);
    let image = make_wall_image(length, width);
    robotbed.add_collider_image(collider_handle, image, String::from("main"));
    robotbed.set_collider_image(collider_handle, String::from("main"));
}

pub struct WorldData{
    pub robot : Robot,
}

const ROBOT_WIDTH: f32 = 100.;
const ROBOT_LENGTH: f32 = 150.;
const WORLD_WIDTH: i32 = 1000;
const WORLD_HEIGHT: i32 = 1000;
const DISPLAY_SCALE_FACTOR: f32 = 0.7;

fn new_nphysics_world() -> NPhysicsWorld{
    let nphysics_world = NPhysicsWorld::new_empty();
    return nphysics_world;
}

pub fn new_robotbed(robot_img_path: &str) -> Robotbed<WorldData>{
    let img = image_helpers::download_img(robot_img_path);
    println!("{:?},{:?}", img.width(), img.height());
    let robot = Robot::new(3);
    let mut nphysics_world = new_nphysics_world();
    let robot_body_handle = nphysics_world.bodies.insert(robot.make_body());
    let robot_collider_handle = nphysics_world.colliders.insert(robot.make_collider(robot_body_handle));
    let world_data = WorldData{robot};
    let mut robotbed = genSimulator::make_robotbed(nphysics_world, world_data, DISPLAY_SCALE_FACTOR);
    robotbed.add_collider_image(robot_collider_handle, img, String::from("main"));
    robotbed.set_collider_image(robot_collider_handle, String::from("main"));
    add_wall_data(&mut robotbed, Vector2::new(WORLD_WIDTH as f32/2.0,0.), 400., 10., 1.5708);
    return robotbed;
}

pub fn run_robotbed(robotbed : Robotbed<WorldData>){
    robotbed::display_engine::run_robotbed(robotbed, WORLD_WIDTH, WORLD_HEIGHT)
}