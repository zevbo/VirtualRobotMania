open Core
open Tsdl

let run () =
  let module Game = Robot_sim.Ctf_sim in
  Game.set_motors 0.8 1.;
  let rec loop () =
    Game.step ();
    let key_state = Sdl.get_keyboard_state () in
    let w = key_state.{Sdl.Scancode.w} in
    let s = key_state.{Sdl.Scancode.s} in
    let u = key_state.{Sdl.Scancode.up} in
    let d = key_state.{Sdl.Scancode.down} in
    let move_by = 0.01 in
    let l_input =
      Game.l_input ()
      +. (move_by *. if w = 1 then 1. else if s = 1 then -1. else 0.)
    in
    let r_input =
      Game.r_input ()
      +. (move_by *. if u = 1 then 1. else if d = 1 then -1. else 0.)
    in
    (*Stdio.printf "inputs: %f, %f\n" l_input r_input; *)
    Game.set_motors l_input r_input;
    loop ()
  in
  loop ()

let () =
  Command.basic
    ~summary:"Test out API we plan to expose to Racket"
    (let%map_open.Command () = return () in
     fun () -> run ())
  |> Command.run
