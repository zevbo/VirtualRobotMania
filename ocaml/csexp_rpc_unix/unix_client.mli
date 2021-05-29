open! Core
open! Async
open! Import

(** Connect to the server over the specified Unix pipe *)
val connect : filename:string -> Csexp_rpc.Client.t Deferred.t

(** Like connect, but keep on trying until you succeed *)
val connect_aggressively : filename:string -> Csexp_rpc.Client.t Deferred.t
