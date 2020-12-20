open! Core_kernel

let state = Lazy.from_fun Main.init
let exportable f = f (force state)
let step () = exportable Main.step
let set_motors = exportable Main.set_motors
let l_input () = exportable Main.l_input
let r_input () = exportable Main.r_input
let use_offense_bot () = exportable Main.use_offense_bot
let use_defense_bot () = exportable Main.use_defense_bot
let shoot_laser () = exportable Main.shoot_laser
