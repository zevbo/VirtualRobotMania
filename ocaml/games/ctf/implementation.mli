open! Core
open Async

val group : unit -> Csexp_rpc.Implementation.Group.t Deferred.t
