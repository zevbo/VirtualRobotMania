open State
open! Core_kernel
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph

let fps = 20.
let frame = Int.of_float Bodies.frame_width, Int.of_float Bodies.frame_height
let dt = 1. /. fps
let dt_sim = dt /. 50.

let init () =
  let world = World.empty in
  let world =
    List.fold Bodies.border ~init:world ~f:(fun world border_edge ->
        fst (World.add_body world border_edge))
  in
  let offense_robot_state = State.Offense_bot.create () in
  let defense_robot_state = State.Defense_bot.create () in
  let state =
    State.create
      world
      (Map.empty (module World.Id))
      (Display.init
         ~physical:frame
         ~logical:frame
         ~title:"Virtual Robotics Arena")
      offense_robot_state
  in
  let world, offense_body_id =
    World.add_body
      world
      ~updater:(Offense_bot_logic.gen_updater state offense_robot_state dt_sim)
      Bodies.offense_bot
  in
  let world, defense_body_id =
    World.add_body
      world
      ~updater:(Defense_bot_logic.gen_updater state defense_robot_state dt_sim)
      Bodies.defense_bot
  in
  state.world <- world;
  let robot_image =
    Display.Image.of_bmp_file state.display "../../images/test-robot.bmp"
  in
  state.images
    <- Map.update state.images ~f:(fun _ -> robot_image) offense_body_id;
  state.images
    <- Map.update state.images ~f:(fun _ -> robot_image) defense_body_id;
  state

(** Handle any keyboard or other events *)
let handle_events (state : State.t) =
  if Sdl.poll_event (Some state.event)
  then (
    match Sdl.Event.enum (Sdl.Event.get state.event Sdl.Event.typ) with
    | `Key_up ->
      let key = Sdl.Event.get state.event Sdl.Event.keyboard_keycode in
      if key = Sdl.K.q then Caml.exit 0
    | _ -> ())

let _status_s sexp =
  let data =
    String.concat
      ~sep:"\n"
      [ Time.to_string_abs_trimmed ~zone:Time.Zone.utc (Time.now ())
      ; Sexp.to_string_hum sexp
      ]
  in
  Out_channel.write_all "/tmp/status.sexp" ~data

let step state =
  handle_events state;
  for _i = 1 to 10 do
    state.world <- World.advance state.world ~dt:dt_sim
  done;
  Display.clear state.display Color.white;
  Map.iteri state.world.bodies ~f:(fun ~key:id ~data:robot ->
      match Map.find state.images id with
      | Some image ->
        let w = robot.shape.bounding_box.width in
        let h = robot.shape.bounding_box.height in
        Display.draw_image_wh
          state.display
          ~w
          ~h
          image
          ~center:robot.pos
          ~angle:robot.angle
      | None -> ());
  Display.present state.display;
  (match state.last_step_end with
  | None -> ()
  | Some last_step_end ->
    let now = Time.now () in
    let elapsed_ms = Time.Span.to_ms (Time.diff now last_step_end) in
    let target_delay_ms = 1000. *. dt in
    let time_left_ms = Float.max 0. (target_delay_ms -. elapsed_ms) in
    Sdl.delay (Int32.of_float time_left_ms));
  state.last_step_end <- Some (Time.now ())

let max_input = 1.

let set_motors state l_input r_input =
  let make_valid input =
    if Float.O.(Float.abs input < max_input)
    then input
    else Float.copysign max_input input
  in
  state.offense_bot.l_input <- make_valid l_input;
  state.offense_bot.r_input <- make_valid r_input

let l_input state = state.offense_bot.l_input
let r_input state = state.offense_bot.r_input
