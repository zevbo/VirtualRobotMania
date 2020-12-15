(** Represents a 2d vector *)
type t =
  { x : float
  ; y : float
  }
[@@deriving sexp, fields]

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
val rotate : t -> Angle.t -> t
val mid_point : t -> t -> t
val avg_point : t list -> t
val angle_of : t -> Angle.t
val angle_between : t -> t -> Angle.t
val angle_with_origin : t -> t -> Angle.t
val unit_vec : Angle.t -> t

val normalize_angle
  :  ?min_angle:Angle.t
  -> ?max_angle:Angle.t
  -> Angle.t
  -> Angle.t

(* Constants *)
val normal_angle_range : Angle.t
val min_angle : Angle.t
val max_angle : Angle.t
val origin : t
