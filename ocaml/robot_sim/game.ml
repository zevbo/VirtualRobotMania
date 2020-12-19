open! Core_kernel
open Geo
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph

module State = struct
  let fps = 20.
  let frame_width = 700
  let frame_height = 700

  type t =
    { mutable world : World.t
    ; mutable last_step : Time.t option
          (** The last time step was called. Used to make sure that the step can
              be elongated to match a single animation frame *)
    ; event : Sdl.event
    ; display : Display.t
    }

  let create () =
    { world = World.empty
    ; event = Sdl.Event.create ()
    ; last_step = None
    ; display =
        Display.init
          ~w:frame_width
          ~h:frame_height
          ~title:"Virtual Robotics Arena"
    }

  let add_bot t =
    let world, id =
      World.add_body
        t.world
        (Body.create
           ~pos:(Vec.create (Random.float 1000.) (Random.float 1000.))
           ~m:1.
           (Shape.create_standard_rect
              30.
              100.
              ~material:(Material.create ~energy_ret:0.3)))
    in
    t.world <- world;
    World.Id.to_int id

  (** Handle any keyboard or other events *)
  let handle_events t =
    if Sdl.poll_event (Some t.event)
    then (
      match Sdl.Event.enum (Sdl.Event.get t.event Sdl.Event.typ) with
      | `Key_up ->
        let key = Sdl.Event.get t.event Sdl.Event.keyboard_keycode in
        if key = Sdl.K.q then Caml.exit 0
      | _ -> ())

  let step t =
    handle_events t;
    let dt = 1. /. fps in
    t.world <- World.advance t.world ~dt;
    Display.clear t.display Color.white;
    (* do any actual rendering here *)
    Display.present t.display;
    let now = Time.now () in
    (match t.last_step with
    | None -> ()
    | Some last_step ->
      let elasped_ms = Time.Span.to_ms (Time.diff now last_step) in
      let target_delay_ms = 1000. *. dt in
      let time_left_ms = Float.max 0. (target_delay_ms -. elasped_ms) in
      Sdl.delay (Int32.of_float time_left_ms));
    t.last_step <- Some now
end

let state = Lazy.from_fun State.create
let add_bot () = State.add_bot (force state)
let step () = State.step (force state)
