open! Core
module Call = Csexp_rpc.Call

let step = Call.create "step" (module Unit) (module Unit)

let set_motors =
  let module Query = struct
    type t = float * float [@@deriving sexp]
  end
  in
  Call.create "set-motors" (module Query) (module Unit)

let l_input = Call.create "l-input" (module Unit) (module Float)
let r_input = Call.create "r-input" (module Unit) (module Float)
let use_offense_bot = Call.create "use-offense-bot" (module Unit) (module Unit)
let use_defense_bot = Call.create "use-defense-bot" (module Unit) (module Unit)
let shoot_laser = Call.create "shoot-laser" (module Unit) (module Unit)
let boost = Call.create "boost" (module Unit) (module Unit)

let set_offense_image =
  Call.create "set-offense-image" (module String) (module Unit)

let set_defense_image =
  Call.create "set-defense-image" (module String) (module Unit)

let opp_angle = Call.create "opp-angle" (module Unit) (module Float)
let opp_dist = Call.create "opp-dist" (module Unit) (module Float)
let opp_shot = Call.create "opp-shot?" (module Unit) (module Bool)
let enhance_border = Call.create "enhance-border" (module Unit) (module Unit)
let num_flags = Call.create "num-flags" (module Unit) (module Int)
