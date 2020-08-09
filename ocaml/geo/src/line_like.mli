open! Vec

type 'a t =
  { base : Vec.t
  ; dir_vec : Vec.t
  ; flips : float list
  ; underlying : 'a
  }
[@@deriving sexp]

val create : 'a -> Vec.t -> Vec.t -> float list -> 'a t
val start_on : _ t -> bool
val param_of_proj_point : _ t -> Vec.t -> float
val is_param_on : _ t -> float -> bool
val param_to_point : _ t -> float -> Vec.t
val flip_points_of : _ t -> Vec.t list
val ignore : _ t -> unit t

(** These functions depend on some epsilon tolerance value *)
module type Epsilon_dependent = sig
  (** The epsilon used for these functions *)
  val epsilon : float

  val on_line : _ t -> Vec.t -> bool
  val create_w_flip_points : 'a -> Vec.t -> Vec.t -> Vec.t list -> 'a t
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
