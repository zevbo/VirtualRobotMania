use simulator::shootWorldSimulator;

#[no_mangle]
pub extern "C" fn fnurk() -> i32 {
    let mut robotbed = shootWorldSimulator::new_robotbed("../../rust-lib/test-robot.png");
    robotbed.setup_items();
    shootWorldSimulator::run_robotbed(robotbed);
    return 1;
}