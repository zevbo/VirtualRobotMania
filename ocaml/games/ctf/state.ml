open! Core_kernel
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph_tsdl

type 'a with_id =
  { bot : 'a
  ; id : World.Id.t
  }

module Laser = struct
  type t =
    { mutable power : int
    ; mutable loaded : bool
    ; mutable loaded_ts : float
    }

  let create loaded_ts = { power = 1; loaded = true; loaded_ts }
end

type t =
  { mutable world : World.t
  ; mutable last_step_end : Time.t option
        (** The last time step was called. Used to make sure that the step can
            be elongated to match a single animation frame *)
  ; mutable images : Display.Image.t Map.M(World.Id).t
  ; mutable invisible : Set.M(World.Id).t
  ; mutable lasers : Laser.t Map.M(World.Id).t
  ; event : Sdl.event
  ; display : Display.t
  ; offense_bot : Offense_bot.t with_id
  ; defense_bot : Defense_bot.t with_id
  ; flag : World.Id.t
  ; flag_protector : World.Id.t
  ; mutable ts : float
  ; laser : Display.Image.t list
  ; end_line : Display.Image.t
  ; offense_shield : World.Id.t
  ; mutable last_wall_enhance : float
  }

let create
    world
    images
    display
    offense_bot
    defense_bot
    flag_id
    flag_protector_id
    offense_shield_id
  =
  { world
  ; last_step_end = None
  ; images
  ; invisible = Set.empty (module World.Id)
  ; lasers = Map.empty (module World.Id)
  ; event = Sdl.Event.create ()
  ; display
  ; offense_bot
  ; defense_bot
  ; flag = flag_id
  ; flag_protector = flag_protector_id
  ; ts = 0.
  ; laser = List.map Ctf_consts.Laser.colors ~f:(Display.Image.pixel display)
  ; end_line = Display.Image.pixel display (Color.rgb 0 255 255)
  ; offense_shield = offense_shield_id
  ; last_wall_enhance = -.Ctf_consts.Border.enhance_period
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
           Option.iter old_image ~f:(fun old_image ->
               Display.Image.destroy old_image);
           image);
  return ()

let set_image t ((bot_name : Bot_name.t), imagefile) =
  let id =
    match bot_name with
    | Defense -> t.defense_bot.id
    | Offense -> t.offense_bot.id
  in
  load_bot_image t id imagefile

let get_offense_bot_body state =
  let body_op = Map.find state.world.bodies state.offense_bot.id in
  match body_op with
  | Some body -> body
  | None ->
    raise
      (Failure
         "Called get_offense_bot_body before offense bot generation or after \
          its deletion")

let get_defense_bot_body state =
  let body_op = Map.find state.world.bodies state.defense_bot.id in
  match body_op with
  | Some body -> body
  | None ->
    raise
      (Failure
         "Called get_defense_bot_body before defense bot generation or after \
          its deletion")
