pub mod aliases;
pub mod display_engine;
pub mod image_helpers;
//use core::f32::consts::PI;
use display_engine::Item;

fn main() {
    let img1 = image_helpers::download_img(
        "https://www.gstatic.com/tv/thumb/persons/573960/573960_v9_ba.jpg",
    );
    let img2 = image_helpers::download_img("https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.forbes.com%2Fsites%2Fkenrapoza%2F2020%2F06%2F25%2Fnancy-pelosi-just-protected-the-wto-from-trump-other-democrats%2F&psig=AOvVaw1BV0BeRBSy8X7UfhwmuksN&ust=1593465872767000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCPji1Iy5peoCFQAAAAAdAAAAABAS");
    let images = vec![img1, img2];
    let sender = display_engine::start_game_thread(images);
    let mut rotation = 0.0;
    loop {
        rotation += 0.01;
        let items = vec![
            Item {
                position: (-200., 0.),
                scale: (1., 1.),
                rotation,
                image_id: 0,
            },
            Item {
                position: (-200., 0.),
                scale: (1., 1.),
                rotation: -rotation,
                image_id: 1,
            },
        ];
        sender.send(items).unwrap();
        std::thread::sleep(std::time::Duration::from_millis(16));
    }
}
