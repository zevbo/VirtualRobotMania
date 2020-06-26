extern crate nalgebra as na;

use crate::point::Point;

pub fn scale_pt(c: f32, p: Point) -> Point{
    return Point::new(c * p.x, c * p.y);
}
pub fn rotate_pt(p: Point, angle: f32) -> Point{
    return Point::new(p.x * angle.cos() - p.y * angle.sin(),
                      p.x * angle.sin() + p.y * angle.cos());
}
pub fn rotate_pt_around(p: Point, angle: f32, p_around: Point) -> Point{
    return rotate_pt(p - p_around, angle) + p_around;
}
pub fn magSq(p: Point) -> f32{
    return p.x.powf(2.0) + p.y.powf(2.0); 
}
pub fn mag(p: Point) -> f32{
    return magSq(p).sqrt();
}