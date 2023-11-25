open! Core
open! Async_kernel
open! Import

(** Handles the server side of a single connection *)
val run
  :  Implementation.Group.t
  -> context:string
  -> Input.t
  -> Output.t
  -> log_s:(Sexp.t -> unit)
  -> unit Deferred.t
