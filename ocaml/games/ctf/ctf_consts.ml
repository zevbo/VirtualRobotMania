open Virtuality2d
open Geo_graph

let frame_width = 500.
let frame_height = 500.

module Border = struct
  let energy_ret = 1.4
  let coll_group = 0
end

module Bots = struct
  let width = 75.
  let height = 50.
  let material = Material.create ~energy_ret:1.
  let mass = 1.
  let start_angle = 0.01
  let x_mag = (frame_width /. 2.) -. width
  let shape = Shape.create_standard_rect width height ~material
  let side_fric_k = 100000.
  let air_resistance_c = 1.

  module Offense = struct
    let start_lives = 3
    let force_over_input = 500.
    let coll_group = 1
  end

  module Defense = struct
    let force_over_input = 400.
    let coll_group = 2
    let black_list = [ 1 ]
  end
end

module Laser = struct
  let length = 25.
  let width = 5.
  let color = Color.red
  let coll_group = 3
  let black_list = [ 1 ]
  let material = Material.create ~energy_ret:2.
  let shape = Shape.create_standard_rect length width ~material
  let v = 1000.
  let cooldown = 1.
end
