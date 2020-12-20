open! Core_kernel
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph

let fps = 20.
let frame = Int.of_float Bodies.frame_width, Int.of_float Bodies.frame_height

type t =
  { mutable world : World.t
  ; mutable last_step_end : Time.t option
        (** The last time step was called. Used to make sure that the step can
            be elongated to match a single animation frame *)
  ; mutable images : Display.Image.t Map.M(World.Id).t
  ; event : Sdl.event
  ; display : Display.t
  ; offense_robot_state : Offense_robot_state.t
  }

let dt = 1. /. fps
let dt_sim = dt /. 50.

let create () =
  let world = World.empty in
  let world =
    List.fold Bodies.border ~init:world ~f:(fun world border_edge ->
        fst (World.add_body world border_edge))
  in
  let offense_robot_state = Offense_robot_state.create () in
  let defense_robot_state = Offense_robot_state.create () in
  let world, offense_body_id =
    World.add_body
      world
      ~updater:(Offense_robot_state.gen_updater offense_robot_state dt_sim)
      Bodies.offense_bot
  in
  let world, defense_body_id =
    World.add_body
      world
      ~updater:(Offense_robot_state.gen_updater defense_robot_state dt_sim)
      Bodies.defense_bot
  in
  let t =
    { world
    ; event = Sdl.Event.create ()
    ; last_step_end = None
    ; images = Map.empty (module World.Id)
    ; display =
        Display.init
          ~physical:frame
          ~logical:frame
          ~title:"Virtual Robotics Arena"
    ; offense_robot_state
    }
  in
  let robot_image =
    Display.Image.of_bmp_file t.display "../../images/test-robot.bmp"
  in
  t.images <- Map.update t.images ~f:(fun _ -> robot_image) offense_body_id;
  t.images <- Map.update t.images ~f:(fun _ -> robot_image) defense_body_id;
  t

(** Handle any keyboard or other events *)
let handle_events t =
  if Sdl.poll_event (Some t.event)
  then (
    match Sdl.Event.enum (Sdl.Event.get t.event Sdl.Event.typ) with
    | `Key_up ->
      let key = Sdl.Event.get t.event Sdl.Event.keyboard_keycode in
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

let step t =
  handle_events t;
  for _i = 1 to 10 do
    t.world <- World.advance t.world ~dt:dt_sim
  done;
  Display.clear t.display Color.white;
  Map.iteri t.world.bodies ~f:(fun ~key:id ~data:robot ->
      match Map.find t.images id with
      | Some image ->
        let w = robot.shape.bounding_box.width in
        let h = robot.shape.bounding_box.height in
        Display.draw_image_wh
          t.display
          ~w
          ~h
          image
          ~center:robot.pos
          ~angle:robot.angle
      | None -> ());
  Display.present t.display;
  (match t.last_step_end with
  | None -> ()
  | Some last_step_end ->
    let now = Time.now () in
    let elapsed_ms = Time.Span.to_ms (Time.diff now last_step_end) in
    let target_delay_ms = 1000. *. dt in
    let time_left_ms = Float.max 0. (target_delay_ms -. elapsed_ms) in
    Sdl.delay (Int32.of_float time_left_ms));
  t.last_step_end <- Some (Time.now ())

let max_input = 1.

let set_motors t l_input r_input =
  let make_valid input =
    if Float.O.(Float.abs input < max_input)
    then input
    else Float.copysign max_input input
  in
  t.offense_robot_state.l_input <- make_valid l_input;
  t.offense_robot_state.r_input <- make_valid r_input

let l_input t = t.offense_robot_state.l_input
let r_input t = t.offense_robot_state.r_input
