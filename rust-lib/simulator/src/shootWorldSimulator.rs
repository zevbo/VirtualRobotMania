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

struct Robot{
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
            .translation(Vector2::y() * 10.)
            .velocity(Velocity::linear(0.0, 0.0))
            .linear_damping(0.)
            .angular_damping(0.)
            .angular_inertia(3.0)
            .velocity(Velocity::linear(30.0, 0.0))
            .mass(1.2)
            .build();
    }
    pub fn make_collider(&self, robotBodyHandle : DefaultBodyHandle) -> Collider<f32, DefaultColliderHandle>{
        let shape = ncollideHelper::rect_shape(ROBOT_WIDTH, ROBOT_LENGTH);
        return ColliderDesc::new(shape)
            .translation(Vector2::x() * 1.)
            .collision_groups(CollisionGroups::new()
                .with_membership(&[CG_ROBOTS])
                .with_whitelist(&[CG_WALLS]))
            .build(BodyPartHandle(robotBodyHandle, 0));
    }
}

fn make_wall_image(length : f32, angle : f32, width : f32) -> ImgBuf{
    let line_image = ImgBuf::from_fn(length as u32, width as u32, |_x, _y|{return image::Rgba([0,0,0,1])});
    let background_x = length * angle.sin() + width * angle.cos();
    let background_y = length * angle.cos() + width * angle.sin();
    let mut wall_image = ImgBuf::from_fn(background_x as u32, background_y as u32, |_x, _y|{return image::Rgba([1,0,0,0])});
    image_helpers::rotate_overlay(&mut wall_image, &line_image, 0, 0, angle);
    return wall_image;
}

fn add_wall_data(robotbed : &mut Robotbed<WorldData>, center : Vector2<f32>, length : f32, angle : f32, width : f32){
    let body = RigidBodyDesc::new()
        .gravity_enabled(false)
        .translation(center)
        .build();
    let body_handle = robotbed.nphysics_world.bodies.insert(body);
    let shape = ncollideHelper::rotated_rect_shape(length, width, angle);
    let collider =
        ColliderDesc::new(shape)
        .collision_groups(CollisionGroups::new()
            .with_membership(&[CG_WALLS]))
        .translation(center)
        .build(BodyPartHandle(body_handle, 0));
    let collider_handle = robotbed.nphysics_world.colliders.insert(collider);
    let image = make_wall_image(length, angle, width);
    robotbed.add_collider_image(collider_handle, image, String::from("main"));
    robotbed.set_collider_image(collider_handle, String::from("main"));
    
}
pub struct WorldData{
    robot : Robot,
}

const ROBOT_WIDTH: f32 = 50.;
const ROBOT_LENGTH: f32 = 75.;
const WORLD_WIDTH: i32 = 400;
const WORLD_HEIGHT: i32 = 400;
const DISPLAY_SCALE_FACTOR: f32 = 1.5;

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
    let mut robotbed = genSimulator::make_robotbed(nphysics_world, world_data, DISPLAY_SCALE_FACTOR);
    robotbed.add_collider_image(robotColliderHandle, img, String::from("main"));
    robotbed.set_collider_image(robotColliderHandle, String::from("main"));
    add_wall_data(&mut robotbed, Vector2::new(0.,0.), 50., 45., 5.);
    return robotbed;
}

pub fn run_robotbed(robotbed : Robotbed<WorldData>){
    robotbed::display_engine::run_robotbed(robotbed, WORLD_WIDTH, WORLD_HEIGHT)
}