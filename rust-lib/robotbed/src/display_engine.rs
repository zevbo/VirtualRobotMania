use crate::aliases::ImgBuf;
use std::sync::mpsc::{channel, Receiver, Sender};
use std::thread;
use tetra::graphics::{self, Color, DrawParams, Texture};
use tetra::math::Vec2;
use tetra::{Context, ContextBuilder, State};

const ARENA_HEIGHT: i32 = 1000;
const ARENA_WIDTH: i32 = 1000;

#[derive(Copy,Clone)]
pub struct Item {
    pub position: (f32, f32), // coordinates. x and y go to the right and up respectively
    pub scale: (f32, f32),    // (1.,1.) is the identity
    pub rotation: f32,        // in radians
    pub image_id: usize,
}

struct GameState {
    textures: Vec<Texture>,
    items: Vec<Item>,
    receiver: Receiver<Vec<Item>>,
}

impl State for GameState {
    fn draw(&mut self, ctx: &mut Context) -> tetra::Result {
        // Grab any items that have been sent, and slam them in to the game state
        for items in self.receiver.try_iter() {
            self.items = items;
        }
        // Walk through the items, and draw each one
        for item in &self.items {
            let texture = &self.textures[item.image_id];
            graphics::clear(ctx, Color::rgb(1., 1., 1.));
            let width = Texture::width(texture) as f32;
            let height = Texture::height(texture) as f32;
            let (x, y) = item.position;
            let (sx, sy) = item.scale;
            let scale = Vec2::new(sx, sy);
            graphics::draw(
                ctx,
                texture,
                DrawParams::new()
                    .position(Vec2::new(
                        x - ARENA_WIDTH as f32 / 2.0,
                        ARENA_HEIGHT as f32 / 2.0 - y,
                    ))
                    .origin(Vec2::new(width / 2.0, height / 2.0))
                    .rotation(item.rotation)
                    .scale(scale),
            );
        }

        Ok(())
    }
}

pub fn start_game_thread(images: Vec<ImgBuf>) -> Sender<Vec<Item>> {
    let (sender, receiver): (Sender<Vec<Item>>, Receiver<Vec<Item>>) = channel();
    let new_gamestate = move |ctx: &mut Context| {
        let textures: Vec<Texture> = images
            .iter()
            .map(|img: &ImgBuf| {
                let img = img.clone();
                let width = img.width() as i32;
                let height = img.height() as i32;
                let raw = img.into_raw();
                return Texture::from_rgba(ctx, width, height, raw.as_slice()).unwrap();
            })
            .collect::<Vec<_>>();
        return Ok(GameState {
            textures,
            items: Vec::new(),
            receiver,
        });
    };
    let _join_handle = thread::spawn(move || {
        ContextBuilder::new("Virtual robot arena", ARENA_WIDTH, ARENA_HEIGHT)
            .quit_on_escape(true)
            .build()?
            .run(new_gamestate)
    });
    return sender;
}
