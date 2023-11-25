open! Core
open Async_kernel

val group
  :  log_s:(Sexp.t -> unit)
  -> Csexp_rpc.Implementation.Group.t Deferred.t
