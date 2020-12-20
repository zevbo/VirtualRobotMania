open! Core
open! Async
module Client = Csexp_rpc.Client
module Protocol = Robot_sim.Protocol

let log_s = Log.Global.error_s

let run_with_pipefile ~pipefile =
  log_s [%message "Connecting"];
  let%bind client = Client.connect_aggressively ~filename:pipefile in
  log_s [%message "Connected"];
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
  run_with_pipefile ~pipefile:filename

let with_existing_engine =
  Command.async
    ~summary:"Use an existing server, and specify the pipe file"
    (let%map_open.Command pipefile = anon ("pipefile" %: Filename.arg_type) in
     fun () -> run_with_pipefile ~pipefile)

let launch_engine =
  Command.async
    ~summary:"Launch a server automatically"
    (let%map_open.Command () = return () in
     fun () -> run ())

let () =
  Command.group
    ~summary:"For testing out the Engine API for Racket, but from OCaml"
    [ "with-existing-engine", with_existing_engine
    ; "launch-engine", launch_engine
    ]
  |> Command.run
