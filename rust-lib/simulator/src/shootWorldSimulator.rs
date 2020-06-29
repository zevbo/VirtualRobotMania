use crate::genSimulator;
use ncollide2d::{pipeline::CollisionGroups, shape::{ShapeHandle, Ball, ConvexPolygon}};
use nphysics2d::object::{DefaultBodyPartHandle, Collider, ColliderDesc, RigidBodyDesc, RigidBody, DefaultColliderHandle};
use nphysics2d::math::{Velocity, Inertia};
use crate::ncollideHelper;
use robotbed::image_helpers;
use robotbed::robotbed::NPhysicsWorld;

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
    pub fn make_collider(&self, robotBodyHandle : DefaultBodyPartHandle) -> Collider<f32, DefaultColliderHandle>{
        let shape = ncollideHelper::rectangle_shape(ROBOT_WIDTH, ROBOT_LENGTH);
        return ColliderDesc::new(shape)
            .collision_groups(CollisionGroups::new()
                .with_membership(&[CG_ROBOTS])
                .with_whitelist(&[CG_WALLS]))
            .build(robotBodyHandle);
    }
}
struct WorldData{
    robot : Robot,
}
struct World{
    world_data : WorldData,
    nphysics_world : NPhysicsWorld,
}

const ROBOT_WIDTH: f32 = 50.;
const ROBOT_LENGTH: f32 = 75.;

fn new_nphysics_world() -> NPhysicsWorld{
    let mut nphysics_world = NPhysicsWorld::new_empty();
    return nphysics_world;
}

impl World{
    pub fn new(robot_img_path: &str) -> World{
        let img = image_helpers::download_img(robot_img_path);
        let robot = Robot::new(3);
        let mut nphysics_world = new_nphysics_world();
        let handle = nphysics_world.bodies.insert(robot.make_body());
        let world_data = WorldData{robot};
        return World{world_data, nphysics_world};
    }
}