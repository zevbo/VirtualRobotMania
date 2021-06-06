open! Core_kernel
module Call = Csexp_rpc.Call

module With_bot (M : Sexpable) = struct
  type t = Bot_name.t * M.t [@@deriving sexp]
end

let step = Call.create "step" (module Unit) (module Unit)

let set_robot_image_contents =
  Call.create
    "set-robot-image-contents"
    (module With_bot (Image_contents))
    (module Unit)

let set_flag_image_contents =
  Call.create "set-flag-image-contents" (module Image_contents) (module Unit)

let set_flag_protector_image_contents =
  Call.create
    "set-flag-protector-image-contents"
    (module Image_contents)
    (module Unit)

let set_motors =
  let module Query = struct
    type t = float * float [@@deriving sexp]
  end
  in
  Call.create "set-motors" (module With_bot (Query)) (module Unit)

let l_input = Call.create "l-input" (module With_bot (Unit)) (module Float)
let r_input = Call.create "r-input" (module With_bot (Unit)) (module Float)

let shoot_laser =
  Call.create "shoot-laser" (module With_bot (Unit)) (module Unit)

let boost = Call.create "boost" (module With_bot (Unit)) (module Unit)

let just_returned_flag =
  Call.create "just-returned-flag" (module Unit) (module Bool)

let just_killed = Call.create "just-killed" (module Unit) (module Bool)
let enhance_border = Call.create "enhance-border" (module Unit) (module Unit)
let setup_shield = Call.create "setup-shield" (module Unit) (module Unit)
let num_flags = Call.create "num-flags" (module Unit) (module Int)

let offense_has_flag =
  Call.create "offense-has-flag" (module With_bot (Unit)) (module Bool)

let angle_to_opp =
  Call.create "angle-to-opp" (module With_bot (Unit)) (module Float)

let dist_to_opp =
  Call.create "dist-to-opp" (module With_bot (Unit)) (module Float)

let angle_to_flag =
  Call.create "angle-to-flag" (module With_bot (Unit)) (module Float)

let dist_to_flag =
  Call.create "dist-to-flag" (module With_bot (Unit)) (module Float)

let get_angle = Call.create "get-angle" (module With_bot (Unit)) (module Float)

let get_opp_angle =
  Call.create "get-opp-angle" (module With_bot (Unit)) (module Float)

let just_fired = Call.create "just-fired" (module With_bot (Unit)) (module Bool)

let laser_cooldown_left =
  Call.create "laser-cooldown-left" (module With_bot (Unit)) (module Int)

let just_boosted =
  Call.create "just-boosted" (module With_bot (Unit)) (module Bool)

let boost_cooldown_left =
  Call.create "boost-cooldown-left" (module With_bot (Unit)) (module Int)

let looking_dist =
  Call.create "looking-dist" (module With_bot (Float)) (module Float)

let load_laser = Call.create "load-laser" (module With_bot (Unit)) (module Unit)

let restock_laser =
  Call.create "restock-laser" (module With_bot (Unit)) (module Unit)

let next_laser_power =
  Call.create "next-laser-power" (module With_bot (Unit)) (module Int)
