open Core_kernel
open Virtuality2d
module Sdl := Tsdl.Sdl
open Geo_graph

type 'a with_id =
  { bot : 'a
  ; id : World.Id.t
  }

type t =
  { mutable world : World.t
  ; mutable last_step_end : Time.t option
  ; mutable images : Display.Image.t Map.M(World.Id).t
  ; mutable invisible : Set.M(World.Id).t
  ; mutable lasers : Set.M(World.Id).t
  ; event : Sdl.event
  ; display : Display.t
  ; offense_bot : Offense_bot.t with_id
  ; defense_bot : Defense_bot.t with_id
  ; flag : World.Id.t
  ; flag_protector : World.Id.t
  ; mutable ts : float
  ; laser : Display.Image.t
  ; end_line : Display.Image.t
  ; mutable last_wall_enhance : float
  }

val create
  :  World.t
  -> Display.Image.t Map.M(World.Id).t
  -> Display.t
  -> Offense_bot.t with_id
  -> Defense_bot.t with_id
  -> World.Id.t
  -> World.Id.t
  -> t

val set_world : t -> World.t -> unit
val set_image : t -> Bot_name.t * string -> unit Async.Deferred.t
val get_offense_bot_body : t -> Body.t
val get_defense_bot_body : t -> Body.t
