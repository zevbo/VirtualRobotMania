open! Vec

type t =
  { base : Vec.t
  ; offset : Vec.t
  ; flips : float list
  }
[@@deriving sexp]

val create : Vec.t -> Vec.t -> float list -> t
val start_on : t -> bool
val param_of_proj_point : t -> Vec.t -> float
val is_param_on : t -> float -> bool
val param_to_point : t -> float -> Vec.t
val flip_points_of : t -> Vec.t list

(** These functions depend on some epsilon tolerance value *)
module type Epsilon_dependent = sig
  (** The epsilon used for these functions *)
  val epsilon : float

  val on_line : t -> Vec.t -> bool
  val create_w_flip_points : Vec.t -> Vec.t -> Vec.t list -> t
  val param_of : t -> Vec.t -> float option
  val are_parallel : t -> t -> bool
  val intersection : t -> t -> Vec.t option
end

(** Here, we default Epsilon to 0.00001 *)
include Epsilon_dependent

module type Epsilon = sig
  val epsilon : float
end

module With_epsilon (Epsilon : Epsilon) : Epsilon_dependent
