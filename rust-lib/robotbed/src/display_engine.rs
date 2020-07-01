use crate::aliases::ImgBuf;
use std::sync::mpsc::{channel, Receiver, Sender};
use std::thread;
use tetra::graphics::{self, Color, DrawParams, Texture};
use tetra::math::Vec2;
use tetra::{Context, ContextBuilder, State};
use crate::robotbed::Robotbed;

#[derive(Copy, Clone)]
pub struct Item {
    pub position: (f32, f32), // coordinates. x and y go to the right and up respectively
    pub scale: (f32, f32),    // (1.,1.) is the identity
    pub rotation: f32,        // in radians
    pub image_id: usize,
}

struct GameState<Data> {
    robotbed: Robotbed<Data>,
    textures: Vec<Texture>,
    arena_height: i32,
    arena_width: i32,
}

impl<Data> State for GameState<Data> {
    fn draw(&mut self, ctx: &mut Context) -> tetra::Result {
        // Grab any items that have been sent, and slam them in to the game state
        self.robotbed.run_tick();
        
        graphics::clear(ctx, Color::rgb(1., 1., 1.));
        // Walk through the items, and draw each one
        for item in &self.robotbed.get_items() {
            let texture = &self.textures[item.image_id];
            let width  = Texture::width(texture) as f32;
            let height = Texture::height(texture) as f32;
            let (x, y) = item.position;
            let (sx, sy) = item.scale;
            let scale = Vec2::new(sx, sy);
            graphics::draw(
                ctx,
                texture,
                DrawParams::new()
                    .position(Vec2::new(
                        x * self.robotbed.scale_factor + self.arena_width as f32 / 2.,
                        self.arena_height as f32 / 2. - y * self.robotbed.scale_factor,
                    ))
                    .scale(scale)
                    .origin(Vec2::new(width / 2.0, height / 2.0))
                    .rotation(-1. * item.rotation),
            );
        }

        Ok(())
    }
}

pub fn run_robotbed<Data>(
    robotbed: Robotbed<Data>,
    arena_width: i32,
    arena_height: i32){
    let real_arena_width  = (arena_width  as f32 * robotbed.scale_factor) as i32;
    let real_arena_height = (arena_height as f32 * robotbed.scale_factor) as i32;
    let new_gamestate = move |ctx: &mut Context| {
        let textures: Vec<Texture> = robotbed.collider_images
            .iter()
            .map(|img: &ImgBuf| {
                let img = img.clone();
                let width  = img.width() as i32;
                let height = img.height() as i32;
                let raw = img.into_raw();
                return Texture::from_rgba(ctx, width, height, raw.as_slice()).unwrap();
            })
            .collect::<Vec<_>>();
        return Ok(GameState {
            robotbed,
            textures,
            arena_width: real_arena_height,
            arena_height: real_arena_width
        });
    };
    let run = || {
        ContextBuilder::new("Virtual robot arena", real_arena_width, real_arena_height)
            .quit_on_escape(true)
            .build()?
            .run(new_gamestate)};
    run();
}