open! Core

type t

val create : ('a, 'b) Call.t -> ('a -> 'b) -> t

module Group : sig
  type impl := t
  type t

  val create : impl list -> t
  val handle_query : t -> Sexp.t -> Sexp.t
end
