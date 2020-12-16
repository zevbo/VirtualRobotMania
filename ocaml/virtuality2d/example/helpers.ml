open Core
open Geo_graph
open Tsdl

let fps = 20.
let frame_width = 1000
let frame_height = 1000

module State = struct
  type t =
    { event : Sdl.event
    ; display : Display.t
    }

  let create () =
    { event = Sdl.Event.create ()
    ; display = Display.init ~w:frame_width ~h:frame_height ~title:"test"
    }
end

let sim_loop (state : State.t) f =
  while true do
    let start = Time.now () in
    if Sdl.poll_event (Some state.event)
    then (
      match Sdl.Event.enum (Sdl.Event.get state.event Sdl.Event.typ) with
      | `Key_up ->
        let key = Sdl.Event.get state.event Sdl.Event.keyboard_keycode in
        printf "Key: %s\n%!" (Sdl.get_key_name key);
        if key = Sdl.K.q then Caml.exit 0
      | _ -> ());
    Display.clear state.display Color.white;
    f ();
    Display.present state.display;
    let time_spent_ms =
      let stop = Time.now () in
      Time.Span.to_ms (Time.diff stop start)
    in
    let target_delay_ms = 1000. /. fps in
    let time_left_ms = Float.max 0. (target_delay_ms -. time_spent_ms) in
    Sdl.delay (Int32.of_float time_left_ms)
  done
