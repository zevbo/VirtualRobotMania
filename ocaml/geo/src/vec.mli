(** Represents a 2d vector *)
type t =
  { x : float
  ; y : float
  }
[@@deriving sexp]

val create : float -> float -> t
val mag_sq : t -> float
val mag : t -> float
val scale : t -> float -> t
val add : t -> t -> t
val sub : t -> t -> t
val dot : t -> t -> float
val to_unit : t -> t
val collinear : epsilon:float -> t -> t -> t -> bool
val dist_sq : t -> t -> float
val dist : t -> t -> float
val equals : epsilon:float -> t -> t -> bool
val rotate : t -> float -> t
val mid_point : t -> t -> t
val avg_point : t list -> t
val angle_of : t -> float
val angle_between : t -> t -> float
val angle_with_origin : t -> t -> float
val unit_vec : float -> t

(* Constants *)
val normal_angle_range : float
val min_angle : float
val max_angle : float
val origin : t
