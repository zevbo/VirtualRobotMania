pub mod aliases;
pub mod genSimulator;
pub mod shootWorldSimulator;
pub mod ncollideHelper;

fn main(){
    let mut robotbed = shootWorldSimulator::new_robotbed("../../test-robot.png");
    robotbed.run();
}