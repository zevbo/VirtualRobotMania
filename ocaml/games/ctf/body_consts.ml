open Virtuality2d
open Geo_graph

module Border = struct
  let coll_group = 0
end

module Bots = struct
  let width = 75.
  let height = 50.
  let material = Material.create ~energy_ret:0.3
  let mass = 1.
  let start_angle = 0.01
  let x_mag = (Ctf_consts.frame_width /. 2.) -. width
  let shape = Shape.create_standard_rect width height ~material

  module Offense = struct
    let coll_group = 1
  end

  module Defense = struct
    let coll_group = 2
  end
end

module Laser = struct
  let length = 25.
  let width = 5.
  let color = Color.red
  let coll_group = 3
  let black_list = [ 1 ]
  let material = Material.create ~energy_ret:1.
  let shape = Shape.create_standard_rect length width ~material
end
