extern crate core;

use image::{ImageBuffer, Rgb};
use image::imageops::FilterType;
use core::ops::Deref;

const GLOBAL_FILTER_TYPE: FilterType = FilterType::CatmullRom;

pub fn resize<Container: Deref<Target = [u8]>>(img_buf: ImageBuffer<Rgb<u8>, Container>, width: u32, height: u32) 
        -> ImageBuffer<Rgb<u8>, std::vec::Vec<u8>>{
    return image::imageops::resize(&img_buf, width, height, GLOBAL_FILTER_TYPE);
}

pub fn scale_down<Container: Deref<Target = [u8]>>(img_buf: ImageBuffer<Rgb<u8>, Container>, scale_factor: f32) 
        -> ImageBuffer<Rgb<u8>, std::vec::Vec<u8>>{
    let width  = (img_buf.width() as f32 * scale_factor) as u32;
    let height = (img_buf.width() as f32 * scale_factor) as u32;
    return resize(img_buf, width, height);
}