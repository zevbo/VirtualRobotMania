open Core_kernel
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph

module Offense_bot : sig
  type t =
    { mutable l_input : float
    ; mutable r_input : float
    }

  val create : unit -> t
end

module Defense_bot : sig
  type t =
    { mutable l_input : float
    ; mutable r_input : float
    }

  val create : unit -> t
end

type t =
  { mutable world : World.t
  ; mutable last_step_end : Time.t option
  ; mutable images : Display.Image.t Map.M(World.Id).t
  ; event : Sdl.event
  ; display : Display.t
  ; offense_bot : Offense_bot.t
  }

val create
  :  World.t
  -> Display.Image.t Map.M(World.Id).t
  -> Display.t
  -> Offense_bot.t
  -> t
