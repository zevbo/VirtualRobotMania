open! Core_kernel

val group
  :  (module Geo_graph.Display_intf.S)
  -> root:string
  -> log_s:(Sexp.t -> unit)
  -> Csexp_rpc.Implementation.Group.t
