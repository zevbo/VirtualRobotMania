open! Core
open! Async

(** Start a server listening on a unix-domain socket *)
val server : Implementation.Group.t -> filename:string -> unit Deferred.t
