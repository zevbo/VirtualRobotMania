open! Core
open! Async
open! Import

(** Start a server listening on a unix-domain socket *)
val run
  :  Implementation.Group.t
  -> filename:string
  -> log_s:(Sexp.t -> unit)
  -> unit Deferred.t
