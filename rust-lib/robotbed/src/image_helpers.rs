extern crate core;

use image::{ImageBuffer, Rgb, open, GenericImage, GenericImageView, Pixel};
use image::imageops::FilterType;
use geo::purePt;
use geo::point::Point;
use crate::aliases::ImgBuf;
use std::cmp;

const GLOBAL_FILTER_TYPE: FilterType = FilterType::CatmullRom;

pub fn resize(img_buf: ImgBuf, width: u32, height: u32) -> ImgBuf{
    return image::imageops::resize(&img_buf, width, height, GLOBAL_FILTER_TYPE);
}

pub fn scale_down(img_buf: ImgBuf, scale_factor: f32) -> ImgBuf{
    let width  = (img_buf.width() as f32 * scale_factor) as u32;
    let height = (img_buf.width() as f32 * scale_factor) as u32;
    return resize(img_buf, width, height);
}

pub fn download_img(link: &str) -> ImgBuf{
    return open(link).unwrap().into_rgba()
}

fn unpack<'a, T>(opt: std::option::Option<&'a T>, default: &'a T) -> &'a T{
    match opt {
        Some(val) => return val,
        None => default,
    }
}
fn min<T: std::cmp::Ord>(vec: &Vec<T>) -> &T {return unpack(vec.iter().min(), &vec[0]);}
fn max<T: std::cmp::Ord>(vec: &Vec<T>) -> &T {return unpack(vec.iter().max(), &vec[0]);}

// rotation is in radians
pub fn rotate_overlay(bot: &mut ImgBuf, top: &ImgBuf, x_shift: u32, y_shift: u32, angle: f32) {
    let center = Point::new(top.width() as f32/2.0, top.height() as f32/2.0);
    let shift_point = Point::new(x_shift as f32, y_shift as f32);
    let rotate = |p: Point| {
        purePt::rotate_pt_around(p, angle, center) + shift_point
    };
    println!("rotate defined");
    let tl = rotate(Point::new(0.0,0.0));
    let tr = rotate(Point::new((top.width() - 1) as f32,0.0));
    let bl = rotate(Point::new(0.0,(top.height() - 1) as f32));
    let br = rotate(Point::new((top.width() - 1) as f32,(top.height() - 1) as f32));
    println!("points rotated");
    let minX = cmp::max(*min(&vec![tl.x as i32, tr.x as i32, bl.x as i32, br.x as i32]), 0) as u32;
    let maxX = cmp::min(*max(&vec![tl.x as i32, tr.x as i32, bl.x as i32, br.x as i32]), bot.width() as i32 - 1) as u32;
    let minY = cmp::max(*min(&vec![tl.y as i32, tr.y as i32, bl.y as i32, br.y as i32]), 0) as u32;
    let maxY = cmp::min(*max(&vec![tl.y as i32, tr.y as i32, bl.y as i32, br.y as i32]), bot.height() as i32 - 1) as u32;
    // We will run through all of the xs and ys in the bounding rectangle of the final displayed image
    // Then we will only overlay pixels that when transformed back on to the original canvas, are in frame
    for bot_x in minX..maxX{
        for bot_y in minY..maxY {
            let bot_pos = Point::new(bot_x as f32, bot_y as f32);
            let top_pos = purePt::rotate_pt_around(bot_pos - shift_point, 0.0 - angle, center);
            let top_x = top_pos.x.round() as i32;
            let top_y = top_pos.y.round() as i32;
            if (top_x > 0) & (top_y > 0) & ((top_x as u32) < top.width()) & ((top_y as u32) < top.height()){
                bot.put_pixel(bot_x, bot_y, *top.get_pixel(top_x as u32, top_y as u32));
            }
        }
    }
}