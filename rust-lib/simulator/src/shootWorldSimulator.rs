extern crate nalgebra as na;

use crate::genSimulator;
use ncollide2d::{pipeline::CollisionGroups, shape::{ShapeHandle, Ball, ConvexPolygon}};
use nphysics2d::object::{DefaultBodyHandle, BodyPartHandle, Collider, ColliderDesc, RigidBodyDesc, RigidBody, DefaultColliderHandle, Ground};
use nphysics2d::{algebra::Velocity2, math::{Velocity, Inertia}, material::{Material, BasicMaterial, MaterialHandle}};
use crate::ncollideHelper;
use robotbed::image_helpers;
use robotbed::robotbed::{NPhysicsWorld, Robotbed};
use robotbed::display_engine;
use robotbed::aliases::ImgBuf;
use na::{Vector3, Vector2};
use std::f64::consts::PI;

// CG = collision group
const CG_ROBOTS: usize = 1;
const CG_BALLS: usize = 2;
const CG_WALLS: usize = 3;

#[derive (Copy, Clone)]
pub struct Robot{
    pub balls_left : u32,
    pub left_input : f32,
    pub right_input : f32,
}

impl Robot{
    pub fn new(balls_left : u32) -> Robot{
        return Robot{balls_left, left_input: 0., right_input: 0.};
    }
    pub fn make_body(&self, translation : Vector2<f32>) -> RigidBody<f32>{
        return RigidBodyDesc::new()
            .translation(translation)
            .gravity_enabled(false)
            .linear_damping(0.)
            .angular_damping(0.)
            .angular_inertia(3.0)
            .velocity(Velocity::linear(100.0, 0.0))
            //.linear_damping(1.)
            //.angular_damping(0.1)
            //.max_linear_velocity(100.0)
            //.max_angular_velocity(0.0)
            //.mass(1.2)
            .build();
    }
    pub fn make_collider(&self, robotBodyHandle : DefaultBodyHandle) -> Collider<f32, DefaultColliderHandle>{
        let shape = ncollideHelper::rect_shape(ROBOT_WIDTH, ROBOT_LENGTH);
        return ColliderDesc::new(shape)
            .collision_groups(CollisionGroups::new()
                .with_membership(&[CG_ROBOTS])
                .with_whitelist(&[CG_WALLS, CG_ROBOTS]))
            //.margin(0.0001)
            .density(1.)
            .material(MaterialHandle::new(BasicMaterial::new(0.9, 0.3)))
            .build(BodyPartHandle(robotBodyHandle, 0));
    }
}

fn make_wall_image(length : f32, width : f32) -> ImgBuf{
    return ImgBuf::from_fn(length as u32, width as u32, |_x, _y|{return image::Rgba([0,0,0,255])});
}

fn make_walls(robotbed : &mut Robotbed<WorldData>){
    //let body = Ground::new();
    let body = RigidBodyDesc::new()
        .mass(f32::INFINITY)
        .angular_inertia(f32::INFINITY)
        .build();
    let body_handle = robotbed.nphysics_world.bodies.insert(body);
    let right_angle = PI as f32/2.0;
    add_wall_data(robotbed, body_handle, Vector2::new(0., WORLD_HEIGHT as f32 / 2.0), WORLD_WIDTH as f32, 0.);
    add_wall_data(robotbed, body_handle, Vector2::new(WORLD_WIDTH as f32 / 2.0, 0.), WORLD_HEIGHT as f32, right_angle);
    add_wall_data(robotbed, body_handle, Vector2::new(0., WORLD_HEIGHT as f32 / -2.0), WORLD_WIDTH as f32, 0.);
    add_wall_data(robotbed, body_handle, Vector2::new(WORLD_WIDTH as f32 / -2.0, 0.), WORLD_HEIGHT as f32, right_angle);
}
const WALL_WIDTH: f32 = 10.;
fn add_wall_data(robotbed : &mut Robotbed<WorldData>, body_handle : DefaultBodyHandle, center : Vector2<f32>, length : f32, angle : f32){

    let body = Ground::new();
    let body_handle = robotbed.nphysics_world.bodies.insert(body);
    let shape = ncollideHelper::rect_shape(length, WALL_WIDTH);
    let collider =
        ColliderDesc::new(shape)
        .translation(center)
        .rotation(angle)
        .material(MaterialHandle::new(BasicMaterial::new(0.9, 0.3)))
        .collision_groups(CollisionGroups::new()
            .with_membership(&[CG_WALLS])
            .with_whitelist(&[CG_BALLS, CG_ROBOTS]))
        .build(BodyPartHandle(body_handle, 0));
    let collider_handle = robotbed.nphysics_world.colliders.insert(collider);
    let image = make_wall_image(length, WALL_WIDTH);
    robotbed.add_collider_image(collider_handle, image, String::from("main"));
    robotbed.set_collider_image(collider_handle, String::from("main"));
}

pub struct WorldData{
    pub robots : Vec<Robot>,
}

const ROBOT_WIDTH: f32 = 266.;
const ROBOT_LENGTH: f32 = 400.;
const WORLD_WIDTH: i32 = 2000;
const WORLD_HEIGHT: i32 = 2000;
const DISPLAY_SCALE_FACTOR: f32 = 0.3;

fn new_nphysics_world() -> NPhysicsWorld{
    let nphysics_world = NPhysicsWorld::new_empty();
    return nphysics_world;
}

pub fn add_robot(rb : &mut Robotbed<WorldData>, img : ImgBuf, translation : Vector2<f32>, robot_i : usize){
    let robot = rb.data.robots[robot_i];
    let robot_body_handle = rb.nphysics_world.bodies.insert(robot.make_body(translation));
    let robot_collider_handle = rb.nphysics_world.colliders.insert(robot.make_collider(robot_body_handle));
    rb.add_collider_image(robot_collider_handle, img, String::from("main"));
    rb.set_collider_image(robot_collider_handle, String::from("main"));
}

pub fn new_robotbed(robot_img_path: &str) -> Robotbed<WorldData>{
    return new_robotbed_img(image_helpers::scale_img(image_helpers::download_img(robot_img_path), 4.));
}

pub fn new_robotbed_img(img: ImgBuf) -> Robotbed<WorldData>{
    println!("{:?},{:?}", img.width(), img.height());
    let mut robots = Vec::new();
    let robot1 = Robot::new(3);
    let robot2 = Robot::new(3);
    robots.push(robot1);
    robots.push(robot2);
    let mut nphysics_world = new_nphysics_world();
    let world_data = WorldData{robots};
    let mut robotbed = genSimulator::make_robotbed(nphysics_world, world_data, DISPLAY_SCALE_FACTOR);
    add_robot(&mut robotbed, img.clone(), Vector2::new(300.,0.), 0);
    add_robot(&mut robotbed, img.clone(), Vector2::new(-300.,0.), 1);
    
    //add_wall_data(&mut robotbed, Vector2::new(WORLD_WIDTH as f32/2.0,0.), 100., 10., 1.57);
    make_walls(&mut robotbed);
    return robotbed;
}

pub fn run_robotbed(robotbed : Robotbed<WorldData>){
    robotbed::display_engine::run_robotbed(robotbed, WORLD_WIDTH, WORLD_HEIGHT)
}