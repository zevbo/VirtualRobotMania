open Common
open Virtuality2d
open Geo

let frame_width = 500.
let frame_height = 500.
let body_collision_group = 0

let border =
  Border.generate_border
    ~energy_ret:0.3
    ~collision_group:body_collision_group
    frame_width
    frame_height

let bot_material = Material.create ~energy_ret:0.3
let bot_width = 75.
let bot_height = 50.

let bot_shape =
  Shape.create_standard_rect bot_width bot_height ~material:bot_material

let bot_mass = 1.
let epsilon = 0.01
let offense_x = bot_width -. (frame_width /. 2.)
let defense_x = -.offense_x
let offense_bot_collision_group = 1
let defense_bot_collision_group = 2

let offense_bot =
  Body.create
    ~pos:(Vec.create offense_x 0.)
    ~m:bot_mass
    ~angle:epsilon
    ~collision_group:offense_bot_collision_group
    bot_shape

let defense_bot =
  Body.create
    ~pos:(Vec.create defense_x 0.)
    ~m:bot_mass
    ~angle:(Float.pi -. epsilon)
    ~collision_group:defense_bot_collision_group
    bot_shape
