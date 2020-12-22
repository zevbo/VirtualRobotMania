open! Core
module Call = Csexp_rpc.Call

module With_bot (M : Sexpable) = struct
  type t = Bot_name.t * M.t [@@deriving sexp]
end

let step = Call.create "step" (module Unit) (module Unit)
let set_image = Call.create "set-image" (module With_bot (String)) (module Unit)

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
let opp_angle = Call.create "opp-angle" (module With_bot (Unit)) (module Float)
let opp_dist = Call.create "opp-dist" (module With_bot (Unit)) (module Float)
let opp_shot = Call.create "opp-shot?" (module With_bot (Unit)) (module Bool)
let enhance_border = Call.create "enhance-border" (module Unit) (module Unit)
let num_flags = Call.create "num-flags" (module Unit) (module Int)
