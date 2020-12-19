open! Core_kernel
open Geo
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph

module State = struct
  let fps = 20.
  let frame = 700, 700

  type t =
    { mutable world : World.t
    ; mutable last_step_end : Time.t option
          (** The last time step was called. Used to make sure that the step can
              be elongated to match a single animation frame *)
    ; event : Sdl.event
    ; display : Display.t
    }

  let create () =
    { world = World.empty
    ; event = Sdl.Event.create ()
    ; last_step_end = None
    ; display =
        Display.init
          ~physical:frame
          ~logical:frame
          ~title:"Virtual Robotics Arena"
    }

  let rand_around_zero x = Random.float (x *. 2.) -. x

  let add_bot t =
    let world, id =
      World.add_body
        t.world
        (Body.create
           ~v:(Vec.create (rand_around_zero 500.) (rand_around_zero 500.))
           ~angle:(Random.float (2. *. Float.pi))
           ~pos:(Vec.create (rand_around_zero 350.) (rand_around_zero 350.))
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

  let status_s sexp =
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
    let dt = 1. /. fps in
    for _i = 1 to 10 do
      t.world <- World.advance t.world ~dt:(dt /. 50.)
    done;
    Display.clear t.display Color.white;
    let robot_width = 50. in
    let robot_length = 75. in
    Map.iter t.world.bodies ~f:(fun robot ->
        let half_length =
          Vec.rotate (Vec.create (robot_length /. 2.) 0.) robot.angle
        in
        status_s [%sexp (robot : Body.t)];
        Display.draw_line
          ~width:robot_width
          t.display
          (Vec.add robot.pos half_length)
          (Vec.sub robot.pos half_length)
          Color.black);
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
end

let state = Lazy.from_fun State.create
let add_bot () = State.add_bot (force state)
let step () = State.step (force state)
