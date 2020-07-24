pub mod aliases;
pub mod genSimulator;
pub mod shootWorldSimulator;
pub mod ncollideHelper;

use robotbed::display_engine;

fn main(){
    let mut robotbed = shootWorldSimulator::new_robotbed("../../test-robot.png");
    robotbed.setup_items();
    shootWorldSimulator::run_robotbed(robotbed);
    //robotbed.run();
}