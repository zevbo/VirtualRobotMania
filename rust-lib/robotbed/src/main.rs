pub mod aliases;
pub mod display_engine;
pub mod image_helpers;
use display_engine::Item;

// "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Official_photo_of_Speaker_Nancy_Pelosi_in_2019.jpg/960px-Official_photo_of_Speaker_Nancy_Pelosi_in_2019.jpg",
// "https://upload.wikimedia.org/wikipedia/commons/4/44/Nancy_Pelosi_1993_congressional_photo.jpg");

fn main() {
    let img1 = image_helpers::download_img("../pelosi.jpeg");
    let img2 = image_helpers::download_img("../clap.jpeg");
    let img3 = image_helpers::download_img("../pelosi-blue.jpg");
    let images = vec![img1, img2, img3];
    let sender = display_engine::start_game_thread(images, 2000, 1500);
    let mut rotation = 0.0;
    loop {
        rotation += 0.05;
        let items = vec![
            Item {
                position: (500., 0.),
                scale: (0.2, 0.2),
                rotation,
                image_id: 0,
            },
            Item {
                position: (0., 0.),
                scale: (0.4, 0.4),
                rotation: -rotation,
                image_id: 1,
            },
            Item {
                position: (500., 500.),
                scale: (0.3, 0.3),
                rotation: rotation,
                image_id: 2,
            },
            Item {
                position: (-200., -300.),
                scale: (0.5, 0.5),
                rotation: -rotation * 3.,
                image_id: 0,
            },
        ];
        let send_result = sender.send(items);
        match send_result {
            Ok(()) => std::thread::sleep(std::time::Duration::from_millis(16)),
            Err(_) => break,
        }
    }
}
