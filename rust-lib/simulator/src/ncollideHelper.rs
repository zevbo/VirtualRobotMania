use ncollide2d::shape::{ShapeHandle, Ball, ConvexPolygon, Shape};
use ncollide2d::math::Point;
use nalgebra::Vector2;
use ncollide2d::shape;

pub fn polygon_shape(points : &[Point<f32>]) -> ShapeHandle<f32>{
    return ShapeHandle::new(ConvexPolygon::try_from_points(points).unwrap());
}
pub fn rect_shape(width : f32, height : f32) -> ShapeHandle<f32>{
    return ShapeHandle::new(shape::Cuboid::new(Vector2::new(width, height)));
}