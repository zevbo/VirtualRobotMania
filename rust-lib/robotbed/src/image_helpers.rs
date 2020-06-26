extern crate core;

use image::{ImageBuffer, Rgb, open, GenericImage, GenericImageView, Pixel};
use image::imageops::FilterType;
use core::ops::Deref;
use crate::aliases::ImgBuf;

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
    return open(link).unwrap().into_rgb()
}

// rotation is in radians
pub fn rotate_overlay<I, J>(bottom: &mut I, top: &J, x_shift: u32, y_shift: u32, rotate: f32) 
where
    I: GenericImage,
    J: GenericImageView<Pixel = I::Pixel> {
        for x in 0..top.width(){
            for y in 0..top.height(){
                
            }
        }
    }