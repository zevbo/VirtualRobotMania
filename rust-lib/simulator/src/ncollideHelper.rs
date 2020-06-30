use ncollide2d::shape::{ShapeHandle, Ball, ConvexPolygon, Shape};
use ncollide2d::math::Point;
use nalgebra::Vector2;

pub fn polygon_shape(points : &[Point<f32>]) -> ShapeHandle<f32>{
    return ShapeHandle::new(ConvexPolygon::try_from_points(points).unwrap());
}

pub fn rotated_rect_shape(width : f32, height : f32, angle : f32) -> ShapeHandle<f32>{
    let cos = angle.cos();
    let sin = angle.sin();
    return polygon_shape(
        &[
        Point::new(width * cos /  2.0 + height * sin /  2.0, width * sin /  2.0 + height * cos /  2.0),
        Point::new(width * cos / -2.0 + height * sin /  2.0, width * sin / -2.0 + height * cos /  2.0),
        Point::new(width * cos /  2.0 + height * sin / -2.0, width * sin /  2.0 + height * cos / -2.0),
        Point::new(width * cos / -2.0 + height * sin / -2.0, width * sin / -2.0 + height * cos / -2.0)]);
}
pub fn rect_shape(width : f32, height : f32) -> ShapeHandle<f32>{
    return rotated_rect_shape(width, height, 0.);
}
pub fn line_shape(del_x : f32, del_y : f32) -> ShapeHandle<f32>{
    return polygon_shape(
        &[
        Point::new(del_x/2.0,del_y/2.0),
        Point::new(del_x/-2.0,del_y/-2.0)]);
}