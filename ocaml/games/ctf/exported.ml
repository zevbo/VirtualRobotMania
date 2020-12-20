open! Core_kernel

let state = Lazy.from_fun Main.init
let step () = Main.step (force state)
let set_motors l_input r_input = Main.set_motors (force state) l_input r_input
let l_input () = Main.l_input (force state)
let r_input () = Main.r_input (force state)
