open Virtuality2d

module Make (Display : Geo_graph.Display_intf.S) : sig
  type state := State.Make(Display).t

  val laser : bot:Body.t -> Body.t
  val update : state -> unit
  val restock_laser : state -> World.Id.t -> unit
  val shoot_laser : state -> World.Id.t -> unit
end
