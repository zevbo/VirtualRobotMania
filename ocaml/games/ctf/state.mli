open Core_kernel
open Async_kernel
open Virtuality2d
module Display := Geo_graph.Display

type 'a with_id =
  { bot : 'a
  ; id : World.Id.t
  }

module Laser : sig
  type t =
    { mutable power : int
    ; mutable loaded : bool
    ; mutable loaded_ts : float
    }

  val create : float -> t
end

module Display_data : sig
  type t =
    { offense_bot_lives : int
    ; world : World.t
    ; invisible : Set.M(World.Id).t
    }

  val create : int -> World.t -> Set.M(World.Id).t -> t
end

type t =
  { mutable world : World.t
  ; mutable last_step_end : Time.t option
        (** The last time step was called. Used to make sure that the step can
            be elongated to match a single animation frame *)
  ; mutable images : Display.Image.t Map.M(World.Id).t
  ; mutable invisible : Set.M(World.Id).t
  ; mutable lasers : Laser.t Map.M(World.Id).t
  ; display : Display.t
  ; offense_bot : Offense_bot.t with_id
  ; defense_bot : Defense_bot.t with_id
  ; flag : World.Id.t
  ; flag_protector : World.Id.t
  ; boost : World.Id.t
  ; mutable ts : float
  ; laser : Display.Image.t list
  ; end_line : Display.Image.t
  ; powered : Display.Image.t
  ; offense_shield : World.Id.t
  ; mutable last_wall_enhance : float
  ; mutable past_display_data : Display_data.t list
  ; mutable display_wait : unit Deferred.t
  }

val create
  :  World.t
  -> Display.Image.t Map.M(World.Id).t
  -> Display.t
  -> Offense_bot.t with_id
  -> Defense_bot.t with_id
  -> World.Id.t
  -> World.Id.t
  -> World.Id.t
  -> World.Id.t
  -> Display.Image.t
  -> t Deferred.t

val set_world : t -> World.t -> unit

val set_robot_image_by_name
  :  t
  -> Bot_name.t * string
  -> unit Async_kernel.Deferred.t

val set_flag_image_by_name : t -> string -> unit Async_kernel.Deferred.t

val set_flag_protector_image_by_name
  :  t
  -> string
  -> unit Async_kernel.Deferred.t

val get_offense_bot_body : t -> Body.t
val get_defense_bot_body : t -> Body.t
