open! Core
open! Async
module Client = Protocol_server.Client
module Protocol = Robot_sim.Protocol

let log_s = Log.Global.error_s

let rec wait_for_connection filename =
  if%bind Client.can_connect ~filename
  then return ()
  else (
    let%bind () = Clock.after (Time.Span.of_ms 10.) in
    wait_for_connection filename)

let run_with_pipefile ~pipefile =
  let dispatch = Client.dispatch ~filename:pipefile in
  let module Game = Robot_sim.Game in
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

let run () =
  let filename = Filename.temp_file "game" ".pipe" in
  printf "starting\n";
  log_s [%message "tmpfile for pipe" (filename : string)];
  let _exec_finished =
    Async.Process.run_exn
      ~prog:"dune"
      ~args:[ "exec"; "--"; "game_server/main.exe"; filename ]
      ()
  in
  log_s [%message "waiting for connection"];
  let%bind () = wait_for_connection filename in
  log_s [%message "connection is up"];
  run_with_pipefile ~pipefile:filename

let with_existing_engine =
  Command.async
    ~summary:"Use an existing server, and specify the pipe file"
    (let%map_open.Command pipefile = anon ("pipefile" %: Filename.arg_type) in
     fun () -> run_with_pipefile ~pipefile)

let _launch_engine =
  Command.async
    ~summary:"Launch a server automatically"
    (let%map_open.Command () = return () in
     fun () -> run ())

let () = Ctf_tester.run ()

(*Command.group ~summary:"For testing out the Engine API for Racket, but from
  OCaml" [ "with-existing-engine", with_existing_engine ; "launch-engine",
  launch_engine ] |> Command.run*)
