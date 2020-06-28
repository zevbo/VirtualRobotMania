use tetra::graphics::Texture;
use tetra::Context;

pub struct Item {
    position: (f32, f32),
    rotation: f32,
    image: Texture,
}

pub struct EngineState {
    items: Vec<Item>,
    context: Context,
}
