use crate::aliases::ImgBuf;
use std::sync::mpsc::{channel, Receiver, Sender};
use std::thread;
use tetra::graphics::{self, Color, DrawParams, Texture};
use tetra::math::Vec2;
use tetra::{Context, ContextBuilder, State};

const ARENA_HEIGHT: f32 = 1000.;
const ARENA_WIDTH: f32 = 1000.;

pub struct Item {
    position: (f32, f32), // coordinates. x and y go to the right and up respectively
    scale: (f32, f32),    // (1.,1.) is the identity
    rotation: f32,        // in radians
    image_id: usize,
}

pub struct GameState {
    images: Vec<Texture>,
    items: Vec<Item>,
    receiver: Receiver<Vec<Item>>,
}

impl State for GameState {
    fn draw(&mut self, ctx: &mut Context) -> tetra::Result {
        for item in &self.items {
            let image = &self.images[item.image_id];
            graphics::clear(ctx, Color::rgb(1., 1., 1.));
            let width = Texture::width(image) as f32;
            let height = Texture::height(image) as f32;
            let (x, y) = item.position;
            let (sx, sy) = item.scale;
            let scale = Vec2::new(sx, sy);
            graphics::draw(
                ctx,
                image,
                DrawParams::new()
                    .position(Vec2::new(x - ARENA_WIDTH / 2.0, ARENA_HEIGHT / 2.0 - y))
                    .origin(Vec2::new(width / 2.0, height / 2.0))
                    .rotation(item.rotation)
                    .scale(scale),
            );
        }

        Ok(())
    }
}

pub fn start_game_thread(images: Vec<ImgBuf>) -> Sender<Vec<Item>> {
    let (s, r): (Sender<Vec<Item>>, Receiver<Vec<Item>>) = channel();
    let new_gamestate = |_ctx: &mut Context| {
        return Ok(GameState {
            images: Vec::new(),
            items: Vec::new(),
            receiver: r,
        });
    };
    let _join_handle = thread::spawn(move || {
        ContextBuilder::new("Virtual robot arena", 1000, 1000)
            .quit_on_escape(true)
            .build()?
            .run(new_gamestate)
    });
    return s;
}
