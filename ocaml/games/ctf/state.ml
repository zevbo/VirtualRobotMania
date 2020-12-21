open! Core_kernel
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph

type t =
  { mutable world : World.t
  ; mutable last_step_end : Time.t option
        (** The last time step was called. Used to make sure that the step can
            be elongated to match a single animation frame *)
  ; mutable images : (Display.Image.t * bool) Map.M(World.Id).t
  ; event : Sdl.event
  ; display : Display.t
  ; offense_bot : Offense_bot.t * World.Id.t
  ; defense_bot : Defense_bot.t * World.Id.t
  ; flag : World.Id.t
  ; flag_protector : World.Id.t
  ; mutable ts : float
  ; mutable on_offense_bot : bool
  ; laser : Display.Image.t
  }

let create
    world
    images
    display
    offense_bot
    defense_bot
    flag_id
    flag_protector_id
  =
  { world
  ; last_step_end = None
  ; images
  ; event = Sdl.Event.create ()
  ; display
  ; offense_bot
  ; defense_bot
  ; flag = flag_id
  ; flag_protector = flag_protector_id
  ; ts = 0.
  ; on_offense_bot = true
  ; laser = Display.Image.pixel display Color.red
  }

let set_world t world = t.world <- world

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
           Option.iter old_image ~f:(fun (old_image, _to_use) ->
               Display.Image.destroy old_image);
           image, true);
  return ()

let load_defense_image t imagefile =
  let id = snd t.defense_bot in
  load_bot_image t id imagefile

let load_offense_image t imagefile =
  let id = snd t.offense_bot in
  load_bot_image t id imagefile

let get_offense_bot_body state =
  let body_op = Map.find state.world.bodies (snd state.offense_bot) in
  match body_op with
  | Some body -> body
  | None ->
    raise
      (Failure
         "Called get_offense_bot_body before offense bot generation or after \
          its deletion")

let get_defense_bot_body state =
  let body_op = Map.find state.world.bodies (snd state.defense_bot) in
  match body_op with
  | Some body -> body
  | None ->
    raise
      (Failure
         "Called get_defense_bot_body before defense bot generation or after \
          its deletion")
