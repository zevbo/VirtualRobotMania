extern crate nalgebra as na;

use crate::point::Point;

pub fn scale_point(c: f32, p: Point) -> Point{
    return Point::new(c * p.x, c * p.y);
}
pub fn rotate_point(p: Point, angle: f32) -> Point{
    return Point::new(p.x * angle.cos() - p.y * angle.sin(),
                      p.x * angle.sin() + p.y * angle.cos());
}