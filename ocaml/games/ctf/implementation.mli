open! Core_kernel
open Async_kernel

val group
  :  (module Geo_graph.Display_intf.S)
  -> Csexp_rpc.Implementation.Group.t Deferred.t
