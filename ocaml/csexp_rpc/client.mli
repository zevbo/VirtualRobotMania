open! Core
open! Async_kernel
open! Import

type t

val create : Input.t -> Output.t -> t

(** Dispatch a call over the connection, return the result *)
val dispatch : t -> ('a, 'b) Call.t -> 'a -> 'b Deferred.t

(** Close the connection, wait for it the result *)
val close : t -> unit Deferred.t
