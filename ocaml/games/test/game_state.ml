open! Core
open Geo
open Virtuality2d
module Sdl = Tsdl.Sdl
open Geo_graph_tsdl
module Color = Geo_graph.Color

let fps = 20.
let frame = 700, 700

type t =
  { mutable world : World.t
  ; mutable last_status : Time.t
  ; mutable last_step_end : Time.t option
        (** The last time step was called. Used to make sure that the step can
            be elongated to match a single animation frame *)
  ; mutable images : Display.Image.t Map.M(World.Id).t
  ; event : Sdl.event
  ; display : Display.t
  }

let create () =
  { world = World.empty
  ; images = Map.empty (module World.Id)
  ; last_status = Time.epoch
  ; event = Sdl.Event.create ()
  ; last_step_end = None
  ; display =
      Display.init
        ~physical:frame
        ~logical:frame
        ~title:"Virtual Robotics Arena"
        ~log_s:Async.Log.Global.info_s
  }

let rand_around_zero x = Random.float (x *. 2.) -. x
let robot_width = 50.
let robot_length = 75.

let add_bot t =
  let world, id =
    World.add_body
      t.world
      (Body.create
         ~v:(Vec.create (rand_around_zero 500.) (rand_around_zero 500.))
         ~angle:(Random.float (2. *. Float.pi))
         ~pos:(Vec.create (rand_around_zero 350.) (rand_around_zero 350.))
         ~m:1.
         ~collision_group:0
         (Shape.create_standard_rect
            robot_width
            robot_length
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

let status_s t sexp =
  let now = Time.now () in
  if Time.Span.( > ) (Time.diff now t.last_status) (Time.Span.of_sec 0.5)
  then (
    t.last_status <- now;
    let sexp = force sexp in
    let data =
      String.concat
        ~sep:"\n"
        [ Time.to_string_abs_trimmed ~zone:Time.Zone.utc (Time.now ())
        ; Sexp.to_string_hum sexp
        ]
    in
    Out_channel.write_all "/tmp/status.sexp" ~data)

let step t =
  handle_events t;
  let dt = 1. /. fps in
  for _i = 1 to 10 do
    t.world <- World.advance t.world ~dt:(dt /. 50.)
  done;
  Display.clear t.display Color.white;
  status_s t (lazy [%sexp (t.world : World.t)]);
  Map.iteri t.world.bodies ~f:(fun ~key:id ~data:robot ->
      match Map.find t.images id with
      | Some image ->
        Display.draw_image_wh
          t.display
          image
          ~w:robot_width
          ~h:robot_length
          ~center:robot.pos
          ~angle:robot.angle
      | None ->
        let half_length =
          Vec.rotate (Vec.create (robot_length /. 2.) 0.) robot.angle
        in
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

open! Async

let load_bot_image _t id imagefile =
  let _id = World.Id.of_int id in
  let bmpfile = Caml.Filename.temp_file "image" ".bmp" in
  let%bind () =
    Process.run_expect_no_output_exn
      ~prog:"convert"
      ~args:[ imagefile; bmpfile ]
      ()
  in
  (* let image = Display.Image.of_bmp_file t.display bmpfile in *)
  let%bind () = Unix.unlink bmpfile in
  (* t.images <- Map.update t.images id ~f:(fun old_image -> Option.iter
     old_image ~f:Display.Image.destroy; image); *)
  return ()
