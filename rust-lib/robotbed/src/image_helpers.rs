extern crate core;

use crate::aliases::ImgBuf;
use geo::point::Point;
use geo::pure_pt;
use image::imageops::FilterType;
//use image::{open, ImageBuffer, Rgb};
use image::open;
use std::cmp;
//use std::time::Duration;
use std::time::Instant;

const GLOBAL_FILTER_TYPE: FilterType = FilterType::CatmullRom;

pub fn resize(img_buf: ImgBuf, width: u32, height: u32) -> ImgBuf {
    return image::imageops::resize(&img_buf, width, height, GLOBAL_FILTER_TYPE);
}

pub fn scale_down(img_buf: ImgBuf, scale_factor: f32) -> ImgBuf {
    let width = (img_buf.width() as f32 * scale_factor) as u32;
    let height = (img_buf.width() as f32 * scale_factor) as u32;
    return resize(img_buf, width, height);
}

pub fn download_img(link: &str) -> ImgBuf {
    return open(link).unwrap().into_rgba();
}

fn unpack<'a, T>(opt: std::option::Option<&'a T>, default: &'a T) -> &'a T {
    match opt {
        Some(val) => return val,
        None => default,
    }
}
fn min<T: std::cmp::Ord>(vec: &Vec<T>) -> &T {
    return unpack(vec.iter().min(), &vec[0]);
}
fn max<T: std::cmp::Ord>(vec: &Vec<T>) -> &T {
    return unpack(vec.iter().max(), &vec[0]);
}

// rotation is in radians
pub fn rotate_overlay(bot: &mut ImgBuf, top: &ImgBuf, x_shift: i32, y_shift: i32, angle: f32) {
    let center = Point::new(top.width() as f32 / 2.0, top.height() as f32 / 2.0);
    let center_x = (top.width() / 2) as i32;
    let center_y = (top.height() / 2) as i32;
    let shift_point = Point::new(x_shift as f32, y_shift as f32);
    let rotate = |p: Point| pure_pt::rotate_pt_around(p, angle, center) + shift_point;
    //println!("rotate defined");
    let tl = rotate(Point::new(0.0, 0.0));
    let tr = rotate(Point::new((top.width() - 1) as f32, 0.0));
    let bl = rotate(Point::new(0.0, (top.height() - 1) as f32));
    let br = rotate(Point::new(
        (top.width() - 1) as f32,
        (top.height() - 1) as f32,
    ));
    //println!("points rotated");
    let min_x = cmp::max(
        *min(&vec![tl.x as i32, tr.x as i32, bl.x as i32, br.x as i32]),
        0,
    ) as i32;
    let max_x = cmp::min(
        *max(&vec![tl.x as i32, tr.x as i32, bl.x as i32, br.x as i32]),
        bot.width() as i32 - 1,
    ) as i32;
    let min_y = cmp::max(
        *min(&vec![tl.y as i32, tr.y as i32, bl.y as i32, br.y as i32]),
        0,
    ) as i32;
    let max_y = cmp::min(
        *max(&vec![tl.y as i32, tr.y as i32, bl.y as i32, br.y as i32]),
        bot.height() as i32 - 1,
    ) as i32;
    // We will run through all of the xs and ys in the bounding rectangle of the final displayed image
    // Then we will only overlay pixels that when transformed back on to the original canvas, are in frame
    let _scale = 100000;
    let sin = angle.sin();
    let cos = angle.cos();
    let start = Instant::now();
    for bot_x in min_x..max_x {
        for bot_y in min_y..max_y {
            let un_rot_x = bot_x - x_shift - center_x;
            let un_rot_y = bot_y - y_shift - center_y;
            let top_x = (un_rot_x as f32 * cos - un_rot_y as f32 * sin) as i32 + center_x;
            let top_y = (un_rot_x as f32 * sin + un_rot_y as f32 * cos) as i32 + center_y;
            if (top_x >= 0)
                & (top_y >= 0)
                & ((top_x as u32) < top.width())
                & ((top_y as u32) < top.height())
            {
                bot.put_pixel(
                    bot_x as u32,
                    bot_y as u32,
                    *top.get_pixel(top_x as u32, top_y as u32),
                );
            }
        }
    }
    let duration = Instant::now().duration_since(start);
    println!(
        "time elapsed:{:?},{:?}",
        duration.subsec_nanos(),
        duration.subsec_millis()
    );
}
