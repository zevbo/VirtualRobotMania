open! Core_kernel
open! Async_kernel
open Virtuality2d
module Color = Geo_graph.Color

module Make (Display : Geo_graph.Display_intf.S) = struct
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

  let set_image_gen t id image_thunk =
    let open Async_kernel in
    let%bind image = image_thunk () in
    t.images
      <- Map.update t.images id ~f:(fun old_image ->
             Option.iter old_image ~f:(fun old_image ->
                 Display.Image.destroy old_image);
             image);
    return ()

  let set_image_by_name t id name =
    set_image_gen t id (fun () -> Display.Image.of_name t.display name)

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
    let state =
      { world
      ; last_step_end = None
      ; images
      ; invisible = Set.empty (module World.Id)
      ; lasers = Map.empty (module World.Id)
      ; display
      ; offense_bot
      ; defense_bot
      ; flag = flag_id
      ; flag_protector = flag_protector_id
      ; ts = 0.
      ; laser =
          List.map Ctf_consts.Laser.colors ~f:(Display.Image.pixel display)
      ; end_line = Display.Image.pixel display (Color.rgb 0 255 255)
      ; offense_shield = offense_shield_id
      ; last_wall_enhance = -.Ctf_consts.Border.enhance_period
      }
    in
    let%bind () = set_image_by_name state state.offense_bot.id "offense-bot" in
    let%bind () = set_image_by_name state state.defense_bot.id "defense-bot" in
    let%bind () = set_image_by_name state state.flag "flag" in
    let%bind () =
      set_image_by_name state state.flag_protector "flag-protector"
    in
    return state

  let set_world t world = t.world <- world

  let set_image_contents t id (image_contents : Image_contents.t) =
    let { Image_contents.contents; format } = image_contents in
    set_image_gen t id (fun () ->
        Display.Image.of_contents t.display ~contents ~format)

  let set_robot_image_contents t (bot_name, image_contents) =
    let id =
      match (bot_name : Bot_name.t) with
      | Defense -> t.defense_bot.id
      | Offense -> t.offense_bot.id
    in
    set_image_contents t id image_contents

  let set_robot_image_by_name t (bot_name, name) =
    let id =
      match (bot_name : Bot_name.t) with
      | Defense -> t.defense_bot.id
      | Offense -> t.offense_bot.id
    in
    set_image_by_name t id name

  let set_flag_image_contents t = set_image_contents t t.flag
  let set_flag_image_by_name t = set_image_by_name t t.flag

  let set_flag_protector_image_contents t =
    set_image_contents t t.flag_protector

  let set_flag_protector_image_by_name t = set_image_by_name t t.flag_protector

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
end
