open! Core_kernel
module State = Game_state

let state = Lazy.from_fun State.create
let add_bot () = State.add_bot (force state)
let step () = State.step (force state)
let load_bot_image id string = State.load_bot_image (force state) id string
