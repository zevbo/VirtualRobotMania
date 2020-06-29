use ncollide2d::shape::{ShapeHandle, Ball, ConvexPolygon, Shape};
use ncollide2d::math::Point;

pub fn rectangle_shape(width : f32, height : f32) -> ShapeHandle<f32>{
    let points = 
        [Point::new(width /  2.0, height /  2.0)
        ,Point::new(width / -2.0, height /  2.0)
        ,Point::new(width /  2.0, height / -2.0)
        ,Point::new(width / -2.0, height / -2.0)];
    return ShapeHandle::new(ConvexPolygon::try_from_points(&points).unwrap());
}