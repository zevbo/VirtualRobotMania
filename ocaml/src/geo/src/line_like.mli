open! Vec

type t =
  { pt : Vec.t
  ; dir_vec : Vec.t
  ; flips : float list
  }
[@@deriving sexp]

val create : Vec.t -> Vec.t -> float list -> t
val on_line : ?epsilon:float -> t -> Vec.t -> bool
val flip_points_of : t -> Vec.t list
val start_on : t -> bool
val is_param_on : t -> float -> bool
val param_to_point : t -> float -> Vec.t
val create_w_flip_points : Vec.t -> Vec.t -> Vec.t list -> t
val param_of : ?epsilon:float -> t -> Vec.t -> float option
val are_parallel : ?epsilon:float -> t -> t -> bool
val intersection : ?epsilon:float -> t -> t -> Vec.t option
