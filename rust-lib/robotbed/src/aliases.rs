use image::{ImageBuffer, Rgba};

pub type ImgN = u8; // In our images the number type T for the Rgb<T> pixels
pub type ImgCnt = Vec<ImgN>; // Container type for our images
pub type ImgPxl = Rgba<ImgN>; // Pixel type
pub type ImgBuf = ImageBuffer<ImgPxl, ImgCnt>;