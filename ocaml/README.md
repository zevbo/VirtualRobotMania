This directory is here for writing parts of the simulation in OCaml.
There are a few key directories:

- **src** is where the actual simulation code should go.
- **lib** has a file called `bindings.ml` which is where you put the
  ctypes declarations for exposing the functions in question to C.
- **stub_generator** should not need to be modified; that's just what
  generates the `.c` and `.h` files needed for hooking in to OCaml.
- **test** just tests the basic wrapper setup.

You can look at `../lib/test-ffi.rkt` to see how to call into these
stubs from Racket.  You should first run `dune build` to generate the
necessary dll.

This has been tested on MacOS and Linux so far.

# Building and Testing with Dune

Each library is organized as having a src and test directory.  You
can run:

- `dune build` to build the code itself
- `dune runtest` to run the tests
- `dune promote` to update any expect tests that need to be updated
- `dune runtest --auto-promote` do the runtest and promotion together.