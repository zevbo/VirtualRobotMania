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
    { mutable last_fire_ts : float
    ; mutable l_input : float
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
  ; offense_bot : Offense_bot.t * World.Id.t
  ; defense_bot : Defense_bot.t * World.Id.t
  ; mutable ts : float
  ; mutable on_offense_bot : bool
  }

val create
  :  World.t
  -> Display.Image.t Map.M(World.Id).t
  -> Display.t
  -> Offense_bot.t * World.Id.t
  -> Defense_bot.t * World.Id.t
  -> t
