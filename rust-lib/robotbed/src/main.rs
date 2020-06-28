pub mod aliases;
pub mod display_engine;
pub mod image_helpers;
//use core::f32::consts::PI;
use display_engine::Item;

// "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Official_photo_of_Speaker_Nancy_Pelosi_in_2019.jpg/960px-Official_photo_of_Speaker_Nancy_Pelosi_in_2019.jpg",
// "https://upload.wikimedia.org/wikipedia/commons/4/44/Nancy_Pelosi_1993_congressional_photo.jpg");

fn main() {
    let img1 = image_helpers::download_img("../pelosi.jpeg");
    let img2 = image_helpers::download_img("../pelosi.jpeg");
    let images = vec![img1, img2];
    let sender = display_engine::start_game_thread(images);
    let mut rotation = 0.0;
    loop {
        rotation += 0.01;
        let items = vec![
            Item {
                position: (-400., 0.),
                scale: (0.2, 0.2),
                rotation,
                image_id: 0,
            },
            Item {
                position: (400., 0.),
                scale: (0.2, 0.2),
                rotation: -rotation,
                image_id: 1,
            },
        ];
        sender.send(items).unwrap();
        std::thread::sleep(std::time::Duration::from_millis(16));
    }
}
