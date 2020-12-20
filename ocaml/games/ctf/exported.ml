open! Core_kernel

let state = Lazy.from_fun State.create
let step () = State.step (force state)
let set_motors l_input r_input = State.set_motors (force state) l_input r_input
let l_input () = State.l_input (force state)
let r_input () = State.r_input (force state)
