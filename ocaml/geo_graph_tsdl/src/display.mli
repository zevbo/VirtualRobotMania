open! Base

(** TSDL based implementation of the Geo_graph interface *)

type t

include Geo_graph.Display_intf.S with type t := t
