extern crate nalgebra as na;

use na::{Point2, RealField, Vector2};
use ncollide2d::shape::{Ball, Cuboid, ShapeHandle};
use nphysics2d::force_generator::DefaultForceGeneratorSet;
use nphysics2d::joint::DefaultJointConstraintSet;
use nphysics2d::object::{
    BodyPartHandle, ColliderDesc, DefaultBodySet, DefaultColliderSet, Ground, RigidBodyDesc,
};
use nphysics2d::world::{DefaultGeometricalWorld, DefaultMechanicalWorld};
use nphysics_testbed2d::Testbed;

/*
 * NOTE: The `r` macro is only here to convert from f64 to the `N` scalar type.
 * This simplifies experimentation with various scalar types (f32, fixed-point numbers, etc.)
 */
pub fn run() {
    let mut testbed = Testbed::new_empty();
    /*
     * World
     */
    let mut mechanical_world = DefaultMechanicalWorld::new(Vector2::new(0.0, 0.0));
    let mut geometrical_world = DefaultGeometricalWorld::new();

    let mut bodies = DefaultBodySet::new();
    let mut colliders = DefaultColliderSet::new();
    let mut joint_constraints = DefaultJointConstraintSet::new();
    let mut force_generators = DefaultForceGeneratorSet::new();

    /*
     * Ground
     */
    let ground_thickness = 0.6;
    let ground_shape =
        ShapeHandle::new(Cuboid::new(Vector2::new(3.0, ground_thickness)));

    let ground_handle = bodies.insert(Ground::new());
    let co = ColliderDesc::new(ground_shape)
        .translation(Vector2::y() * -ground_thickness)
        .build(BodyPartHandle(ground_handle, 0));
    // Add the collider to the collider set.
    let ground_co_handle = colliders.insert(co);


    /*
     * Set up the testbed.
     * 
    
    
    testbed.look_at(Point2::new(0.0, 0.0), 0.0);
    testbed.set_collider_color(ground_co_handle, Point3::new(0.0, 1.0, 0.0));
    testbed.run()
     */
    testbed.set_ground_handle(Some(ground_handle));
    testbed.set_world(mechanical_world, geometrical_world, bodies, colliders, joint_constraints, force_generators);
    testbed.look_at(Point2::new(0.0, 0.0), 90.0);
    testbed.run();
}