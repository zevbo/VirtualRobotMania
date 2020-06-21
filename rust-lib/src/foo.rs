#[no_mangle]
pub extern "C" fn fnurk(x: i32, y: i32) -> i32 {
    return x + 2 * y;
}
