open! Core_kernel
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph

module Offense_bot = struct
  type t =
    { mutable l_input : float
    ; mutable r_input : float
    }

  let create () = { l_input = 0.; r_input = 0. }
end

module Defense_bot = struct
  type t =
    { mutable l_input : float
    ; mutable r_input : float
    }

  let create () = { l_input = 0.; r_input = 0. }
end

type t =
  { mutable world : World.t
  ; mutable last_step_end : Time.t option
        (** The last time step was called. Used to make sure that the step can
            be elongated to match a single animation frame *)
  ; mutable images : Display.Image.t Map.M(World.Id).t
  ; event : Sdl.event
  ; display : Display.t
  ; offense_bot : Offense_bot.t
  ; defense_bot : Defense_bot.t
  ; mutable on_offense_bot : bool
  }

let create world images display offense_bot defense_bot =
  { world
  ; last_step_end = None
  ; images
  ; event = Sdl.Event.create ()
  ; display
  ; offense_bot
  ; defense_bot
  ; on_offense_bot = true
  }
