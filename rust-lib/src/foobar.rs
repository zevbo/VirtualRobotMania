use crate::tester;

pub fn boop(){
    tester::for_buildo();
}
pub fn a(){
    println!("a");
}

#[cfg(test)]
mod tests {
    use crate::foobar;
    #[test]
    fn buildo() {
        foobar::boop();
        assert_eq!(0, 0);
    }
}