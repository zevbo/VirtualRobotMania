open Core_kernel
open Virtuality2d
module Color = Geo_graph.Color

let frame_width = 800.
let frame_height = 500.

module Border = struct
  let enhance_period = 10.
  let energy_ret = 1.2
  let coll_group = 0
  let black_list = [ 3 ]
  let enhanced_black_list = []
end

module Bots = struct
  let width = 90.
  let height = 60.
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
    let max_restart_y = frame_height /. 3.
    let boost_cooldown = 15.
    let boost_v_scale = 1.3
    let boost_power_scale = 1.9
    let boost_time = 1.7
    let start_lives = 3
    let force_over_input = 650.
    let coll_group = 1
    let deaths_per_flag = 3

    module Shield = struct
      let width = width *. 1.4
      let height = width
      let material = Material.create ~energy_ret:1.4
      let shape = Shape.create_standard_rect width height ~material
      let coll_group = 6
      let off_black_list = [ 0; 1; 2; 3; 4; 5 ]
      let on_black_list = [ 0; 1; 2; 4; 5 ]
      let time = 5.
    end

    module Boost = struct
      let height = height *. 0.7
      let width_new = height
      let offset = Geo.Vec.create ((-0.5 *. width) -. (width_new /. 2.)) 0.0
      let width = width_new

      (* -1 implies no interactions with anyone *)
      let coll_group = -1
      let black_list = List.range (-1) 7
      let material = Material.create ~energy_ret:1.
      let shape = Shape.create_standard_rect width height ~material
    end
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
  let next_level_time = 1.
  let colors = [ Color.red; Color.rgb 200 0 0; Color.rgb 150 0 0 ]
  let coll_group = 3
  let black_list = [ 1; 2; 3; 4 ]
  let material = Material.create ~energy_ret:2.
  let shape = Shape.create_standard_rect length width ~material
  let v = 1000.
  let cooldown = 3.
  let wall_enhance_period = 10.
end

module Flag = struct
  let width = 30.
  let height = 30.
  let image_path ~root = Filename.concat root "images/flag.bmp"
  let no_defense_dist = 75.
  let max_y = (frame_height /. 2.) -. 30.
  let min_y = no_defense_dist +. 40.
  let min_x = 100.
  let max_x = (frame_width /. 2.) -. width
  let m = Float.infinity
  let top_display_x = (frame_height /. 2.) -. 80.
  let display_y_diff = height *. 1.5
  let display_x = (70. /. 2.) -. (frame_width /. 2.)

  let shape =
    Shape.create_standard_rect
      width
      height
      ~material:(Material.create ~energy_ret:0.)

  let coll_group = 4
  let black_list = [ 0; 1; 2; 3 ]

  module Protector = struct
    let initial_defense_passing = 30.
    let material = Material.create ~energy_ret:1.4

    let shape =
      Shape.create_standard_rect
        (no_defense_dist *. 2.)
        (no_defense_dist *. 2.)
        ~material

    let coll_group = 5
    let m = Float.infinity
    let black_list = [ 1 ]
    let image_path ~root = Filename.concat root "images/green-outline.bmp"
  end
end

module End_line = struct
  let x = 70. -. (frame_width /. 2.)
  let w = 7.
end
