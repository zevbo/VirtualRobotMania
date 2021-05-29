open! Core_kernel

module Make (Display : Geo_graph.Display_intf.S) : sig
  val run : State.Make(Display).t -> dt:float -> int -> unit
end
