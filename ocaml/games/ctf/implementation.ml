open! Core_kernel

let state = Lazy.from_fun Main.init
let exportable f = f (force state)
let step () = exportable Main.step
let set_motors (x, y) = exportable Main.set_motors x y
let l_input () = exportable Main.l_input
let r_input () = exportable Main.r_input
let use_offense_bot () = exportable Main.use_offense_bot
let use_defense_bot () = exportable Main.use_defense_bot
let shoot_laser () = exportable Main.shoot_laser
let set_offense_image s = exportable State.load_offense_image s
let set_defense_image s = exportable State.load_defense_image s

let group =
  let impl = Csexp_rpc.Implementation.create in
  let impl' = Csexp_rpc.Implementation.create' in
  Csexp_rpc.Implementation.Group.create
    [ impl Protocol.l_input l_input
    ; impl Protocol.r_input r_input
    ; impl Protocol.set_motors set_motors
    ; impl Protocol.shoot_laser shoot_laser
    ; impl Protocol.step step
    ; impl Protocol.use_defense_bot use_defense_bot
    ; impl Protocol.use_offense_bot use_offense_bot
    ; impl' Protocol.set_offense_image set_offense_image
    ; impl' Protocol.set_defense_image set_defense_image
    ]
