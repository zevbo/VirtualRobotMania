open! Core_kernel
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph

module Offense_bot = struct
  type t =
    { mutable lives : int
    ; mutable l_input : float
    ; mutable r_input : float
    }

  let create () =
    { lives = Ctf_consts.Bots.Offense.start_lives; l_input = 0.; r_input = 0. }
end

module Defense_bot = struct
  type t =
    { mutable last_fire_ts : float
    ; mutable l_input : float
    ; mutable r_input : float
    }

  let create () = { last_fire_ts = 0.; l_input = 0.; r_input = 0. }
end

type t =
  { mutable world : World.t
  ; mutable last_step_end : Time.t option
        (** The last time step was called. Used to make sure that the step can
            be elongated to match a single animation frame *)
  ; mutable images : Display.Image.t Map.M(World.Id).t
  ; event : Sdl.event
  ; display : Display.t
  ; offense_bot : Offense_bot.t * World.Id.t
  ; defense_bot : Defense_bot.t * World.Id.t
  ; mutable ts : float
  ; mutable on_offense_bot : bool
  ; laser : Display.Image.t
  }

let create world images display offense_bot defense_bot =
  { world
  ; last_step_end = None
  ; images
  ; event = Sdl.Event.create ()
  ; display
  ; offense_bot
  ; defense_bot
  ; ts = 0.
  ; on_offense_bot = true
  ; laser = Display.Image.pixel display Color.red
  }

let load_bot_image t id imagefile =
  let open Async in
  let bmpfile = Caml.Filename.temp_file "image" ".bmp" in
  let%bind () =
    Process.run_expect_no_output_exn
      ~prog:"convert"
      ~args:[ imagefile; bmpfile ]
      ()
  in
  let image = Display.Image.of_bmp_file t.display bmpfile in
  let%bind () = Unix.unlink bmpfile in
  t.images
    <- Map.update t.images id ~f:(fun old_image ->
           Option.iter old_image ~f:Display.Image.destroy;
           image);
  return ()

let load_defense_image t imagefile =
  let id = snd t.defense_bot in
  load_bot_image t id imagefile

let load_offense_image t imagefile =
  let id = snd t.offense_bot in
  load_bot_image t id imagefile
