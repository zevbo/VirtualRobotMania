open! Core
open! Async
module Client = Csexp_rpc.Client

let log_s = Log.Global.error_s

let run_with_pipefile play ~pipefile =
  log_s [%message "Connecting"];
  let%bind client = Client.connect_aggressively ~filename:pipefile in
  log_s [%message "Connected"];
  play client

let run name play =
  let filename = Filename.temp_file "game" ".pipe" in
  printf "starting\n";
  log_s [%message "tmpfile for pipe" (filename : string)];
  let _exec_finished =
    Async.Process.run_exn
      ~prog:"dune"
      ~args:[ "exec"; "--"; "game_server/main.exe"; name; filename ]
      ()
  in
  run_with_pipefile play ~pipefile:filename

let with_existing_engine play =
  Command.async
    ~summary:"Use an existing server, and specify the pipe file"
    (let%map_open.Command pipefile = anon ("pipefile" %: Filename.arg_type) in
     fun () -> run_with_pipefile play ~pipefile)

let launch_engine name play =
  Command.async
    ~summary:"Launch a server automatically"
    (let%map_open.Command () = return () in
     fun () -> run name play)

(* let () = Ctf_tester.run () *)

let game_group name play =
  ( name
  , Command.group
      ~summary:"For testing out the Engine API for Racket, but from\n  OCaml"
      [ "with-existing-engine", with_existing_engine play
      ; "launch-engine", launch_engine name play
      ] )

let play_test client =
  let module Protocol = Test_game.Protocol in
  let dispatch x = Client.dispatch client x in
  let%bind () =
    log_s [%message "starting dispatch"];
    Deferred.Sequence.iter (Sequence.range 0 5) ~f:(fun _ ->
        let%bind (_ : int) = dispatch Protocol.add_bot () in
        return ())
  in
  let rec loop last_time =
    let%bind () = dispatch Protocol.step () in
    let now = Time.now () in
    printf
      "#### %s ####\n%!"
      (Time.Span.to_string_hum (Time.diff now last_time));
    loop now
  in
  loop (Time.now ())

let play_ctf client =
  let module Protocol = Ctf.Protocol in
  let dispatch x = Client.dispatch client x in
  let%bind () =
    dispatch Protocol.set_defense_image "../images/test-robot.JPEG"
  in
  let%bind () =
    dispatch Protocol.set_offense_image "../images/test-robot.JPEG"
  in
  let maybe p then_ else_ =
    if Float.O.(Random.float 1. < p) then force then_ else force else_
  in
  let%bind () = dispatch Protocol.use_defense_bot () in
  let%bind () = dispatch Protocol.set_motors (1., 0.5) in
  let%bind () = dispatch Protocol.use_offense_bot () in
  let%bind () = dispatch Protocol.set_motors (0.95, 1.) in
  let rec loop () =
    let%bind () = dispatch Protocol.use_defense_bot () in
    let%bind () = dispatch Protocol.step () in
    let%bind () =
      maybe 0.001 (lazy (dispatch Protocol.shoot_laser ())) (lazy Deferred.unit)
    in
    let%bind l_input = dispatch Protocol.l_input () in
    let%bind r_input = dispatch Protocol.r_input () in
    let maybe_adjust x =
      let move_by = 0.05 in
      maybe
        0.05
        (lazy (x +. move_by))
        (lazy (maybe 0.05 (lazy (x -. move_by)) (lazy x)))
    in
    let l_input = maybe_adjust l_input in
    let r_input = maybe_adjust r_input in
    let%bind () = dispatch Protocol.set_motors (l_input, r_input) in
    loop ()
  in
  loop ()

let () =
  Command.group
    ~summary:"Test game driver"
    [ game_group "test" play_test; game_group "ctf" play_ctf ]
  |> Command.run
