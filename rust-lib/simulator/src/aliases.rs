extern crate nphysics2d;

use nphysics2d::world::{DefaultMechanicalWorld, DefaultGeometricalWorld};
use nphysics2d::object::{DefaultBodySet, DefaultColliderSet, DefaultBodyHandle, DefaultColliderHandle, Collider};
use nphysics2d::joint::{DefaultJointConstraintSet};
use nphysics2d::force_generator::{DefaultForceGeneratorSet};

pub type MechWorld = DefaultMechanicalWorld<f32>;
pub type GeoWorld = DefaultGeometricalWorld<f32>;
pub type Bodies = DefaultBodySet<f32>;
pub type Colliders = DefaultColliderSet<f32>;
pub type Constraints = DefaultJointConstraintSet<f32>;
pub type ForceGens = DefaultForceGeneratorSet<f32>;
pub type ColliderHandle = DefaultColliderHandle;