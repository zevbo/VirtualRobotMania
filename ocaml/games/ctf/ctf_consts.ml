open Core
open Virtuality2d
open Geo_graph

let frame_width = 800.
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
  let start_angle = 0.0
  let x_mag = (frame_width /. 2.) -. width
  let y_offset = height /. 1.5
  let shape = Shape.create_standard_rect width height ~material
  let side_fric_k = 100000.
  let air_resistance_c = 1.

  module Offense = struct
    let start_pos = Geo.Vec.create (-.x_mag) y_offset
    let boost_cooldown = 15.
    let boost_v_scale = 2.
    let start_lives = 3
    let force_over_input = 650.
    let coll_group = 1
  end

  module Defense = struct
    let start_pos = Geo.Vec.create x_mag (-.y_offset)
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
  let black_list = [ 0; 1; 2; 3; 4 ]
  let material = Material.create ~energy_ret:2.
  let shape = Shape.create_standard_rect length width ~material
  let v = 1000.
  let cooldown = 1.
end

module Flag = struct
  let width = 30.
  let height = 30.
  let image_path ~root = root ^/ "images/flag.bmp"
  let no_defense_dist = 75.
  let max_y = (frame_height /. 2.) -. 30.
  let min_x = 100.
  let max_x = (frame_width /. 2.) -. width
  let m = Float.infinity

  let shape =
    Shape.create_standard_rect
      width
      height
      ~material:(Material.create ~energy_ret:0.)

  let coll_group = 4
  let black_list = [ 0; 1; 2; 3 ]

  module Protector = struct
    let initial_defense_passing = 30.
    let material = Material.create ~energy_ret:2.

    let shape =
      Shape.create_standard_rect
        (no_defense_dist *. 2.)
        (no_defense_dist *. 2.)
        ~material

    let coll_group = 5
    let m = Float.infinity
    let black_list = [ 1 ]
    let image_path ~root = root ^/ "images/green-outline.bmp"
  end
end

module End_line = struct
  let x = 70. -. (frame_width /. 2.)
  let w = 7.
end
