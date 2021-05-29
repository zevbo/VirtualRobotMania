open! Core_kernel

val group
  :  (module Geo_graph.Display_intf.S)
  -> root:string
  -> Csexp_rpc.Implementation.Group.t
