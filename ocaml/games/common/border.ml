open Virtuality2d
open Geo

let default_border_width = 40.

let generate_border
    ?(border_width = default_border_width)
    ?(shift = Vec.origin)
    ?(black_list = [])
    ~energy_ret
    ~collision_group
    width
    height
  =
  let border_material = Material.create ~energy_ret in
  let vertical_border_shape =
    Shape.create_standard_rect border_width height ~material:border_material
  in
  let horizontal_border_shape =
    Shape.create_standard_rect width border_width ~material:border_material
  in
  let create_border pos shape =
    Body.create
      ~m:Float.infinity
      ~pos:(Vec.add pos shift)
      ~collision_group
      ~black_list
      shape
  in
  let create_vertical sign =
    create_border
      (Vec.create (sign *. (width +. border_width) /. 2.) 0.)
      vertical_border_shape
  in
  let create_horizontal sign =
    create_border
      (Vec.create 0. (sign *. (height +. border_width) /. 2.))
      horizontal_border_shape
  in
  let border_1 = create_vertical 1. in
  let border_2 = create_vertical (-1.) in
  let border_3 = create_horizontal 1. in
  let border_4 = create_horizontal (-1.) in
  [ border_1; border_2; border_3; border_4 ]
