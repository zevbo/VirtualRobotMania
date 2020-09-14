open Geo

module type Intf = sig
  module Color : sig
    type t
    val rgb : int -> int -> int -> t
  end

  module Polygon : sig
    type t = { edges: Vec.t list
             ; color: Color.t
             }
  end

  val init: unit -> unit
  val draw: Polygon.t list -> unit
end
