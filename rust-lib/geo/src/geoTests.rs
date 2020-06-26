use crate::purePt;
use crate::point::Point;

#[cfg(test)]
mod tests {

    const origin: Point = Point::new(0.0,0.0);
    const p10: Point = Point::new(1.0,0.0);
    const p01: Point = Point::new(0.0,1.0);
    const pRand1: Point = Point::new(76.0,-32.6);
    const pRand2: Point = Point::new(1332.87,-23489.3);

    #[test]
    fn add1() {
        assert_eq!(p10 + p01, Point::new(1.0, 1.0));
    }
    #[test]
    fn mul1() {
        assert_eq!(purePt::scale_point(5.3, p10), Point::new(5.3, 0.0));
    }
}