open! Core
open! Async
open! Import

type t

(** Connect to the server over the specified Unix pipe *)
val connect : filename:string -> t Deferred.t

(** Like connect, but keep on trying until you succeed *)
val connect_aggressively : filename:string -> t Deferred.t

(** Dispatch a call over the connection, return the result *)
val dispatch : t -> ('a, 'b) Call.t -> 'a -> 'b Deferred.t

(** Close the connection, wait for it the result *)
val close : t -> unit Deferred.t
