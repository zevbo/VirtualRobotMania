open! Core
open! Async_kernel

type t

val create : ('a, 'b) Call.t -> ('a -> 'b) -> t
val create' : ('a, 'b) Call.t -> ('a -> 'b Deferred.t) -> t

module Group : sig
  type impl := t
  type t

  val create : impl list -> t
  val handle_query : t -> Sexp.t -> Sexp.t Deferred.t
end
