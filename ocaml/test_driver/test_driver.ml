open! Core
open! Async
module Client = Protocol_server.Client
module Protocol = Robot_sim.Protocol

let log_s = Log.Global.error_s

let rec wait_for_file filename =
  let%bind exists = Sys.file_exists_exn filename in
  if exists
  then return ()
  else (
    let%bind () = Clock.after (Time.Span.of_ms 10.) in
    wait_for_file filename)

let run ~pipefile =
  (* let filename = Filename.temp_file "game" ".pipe" in printf "starting\n";
     log_s [%message "tmpfile for pipe" (filename : string)]; let _exec_finished
     = Async.Process.run_exn ~prog:"dune" ~args:[ "exec"; "--";
     "game_server/main.exe"; filename ] () in log_s [%message "waiting for
     file"]; let%bind () = wait_for_file filename in log_s [%message "file
     loaded"]; *)
  let dispatch = Client.dispatch ~filename:pipefile in
  let module Game = Robot_sim.Game in
  let%bind () =
    log_s [%message "starting dispatch"];
    Deferred.Sequence.iter (Sequence.range 0 20) ~f:(fun _ ->
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

let () =
  Command.async
    ~summary:"Test out API we plan to expose to Racket"
    (let%map_open.Command pipefile = anon ("pipefile" %: Filename.arg_type) in
     fun () -> run ~pipefile)
  |> Command.run
