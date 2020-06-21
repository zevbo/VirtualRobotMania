% Rust and Racket

The Rust code here is for building the guts of the robot simulation.  This code has to then be exported so that it's made available for dispatching to from Racket.  Part of this is (maybe?) generating an include file.  The include file is perhaps somewhat redundant -- the ffi lib in Racket doesn't necessarily need it.  But it at least gives you a guide as to what C types you should expect for your racket function.

To update your includes, you need cbindgen, which you can get by doing `cargo install cbindgen`.  There's a script in this directory that you can then run which will generate the .h file in the include directory.