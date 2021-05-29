open! Core_kernel
open Async_kernel

val group : unit -> Csexp_rpc.Implementation.Group.t Deferred.t
