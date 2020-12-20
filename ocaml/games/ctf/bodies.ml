open Common
open Virtuality2d
open Geo

let frame_width = 500.
let frame_height = 500.
let border = Border.generate_border ~energy_ret:0.3 frame_width frame_height
let bot_material = Material.create ~energy_ret:0.3
let bot_width = 75.
let bot_height = 50.

let bot_shape =
  Shape.create_standard_rect bot_width bot_height ~material:bot_material

let bot_mass = 1.

let bot1 =
  Body.create
    ~pos:(Vec.create (bot_width -. (frame_width /. 2.)) 0.)
    ~m:bot_mass
    bot_shape
