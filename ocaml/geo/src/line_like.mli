open! Vec

type line = Line [@@deriving sexp]
type segment = Segment [@@deriving sexp]
type ray = Ray [@@deriving sexp]

(** The type parameter here is a phantom type, used to indicate
    the underlying kind of line-like item this represents *)
type 'a t = private
  { base : Vec.t
  ; dir_vec : Vec.t
  ; flips : float list
  }
[@@deriving sexp_of]

(** {2 Line Constructors} *)

val line : Vec.t -> Vec.t -> line t
val line_of_point_angle : Vec.t -> float -> line t
val line_of_point_slope : Vec.t -> float -> line t

(** {2 Ray Constructors} *)

val ray : Vec.t -> Vec.t -> ray t
val ray_of_point_angle : Vec.t -> float -> ray t
val ray_of_point_slope : Vec.t -> float -> ray t

(** {2 Segment Constructors} *)

val segment : Vec.t -> Vec.t -> segment t

(** {2 Other operators} *)

val start_on : _ t -> bool
val param_of_proj_point : _ t -> Vec.t -> float
val is_param_on : _ t -> float -> bool
val param_to_point : _ t -> float -> Vec.t
val flip_points_of : _ t -> Vec.t list

(** These functions depend on some epsilon tolerance value *)
module type Epsilon_dependent = sig
  (** The epsilon used for these functions *)
  val epsilon : float

  val on_line : _ t -> Vec.t -> bool
  val create_w_flip_points : Vec.t -> Vec.t -> Vec.t list -> 'a t
  val param_of : _ t -> Vec.t -> float option
  val are_parallel : _ t -> _ t -> bool
  val intersection : _ t -> _ t -> Vec.t option
end

(** Here, we default Epsilon to 0.00001 *)
include Epsilon_dependent

module type Epsilon = sig
  val epsilon : float
end

(** Use this functor to instantiate the epsilon-dependent values
    with a different value for Epsilon. *)
module With_epsilon (Epsilon : Epsilon) : Epsilon_dependent
