open Virtuality2d

module Make (Display : Geo_graph.Display_intf.S) : sig
  val flag : Body.t -> Body.t
  val flag_protector : Body.t -> Body.t
  val update : State.Make(Display).t -> unit
end
