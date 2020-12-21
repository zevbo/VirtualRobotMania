open! Core
open! Async
open! Import

let run impl_group ~filename =
  let () =
    Log.Global.set_output
      [ Log.Output.file `Sexp_hum ~filename:"/tmp/game-engine.log" ]
  in
  log_s [%message "Starting server" (filename : string)];
  let%bind () =
    match%bind Sys.file_exists_exn filename with
    | true -> Unix.unlink filename
    | false -> Deferred.unit
  in
  let%bind server =
    Tcp.Server.create
      ~on_handler_error:
        (`Call
          (fun _ exn ->
            log_s [%message "Handler raised. Exiting." (exn : Exn.t)];
            don't_wait_for (exit 0)))
      (Tcp.Where_to_listen.of_file filename)
      (fun addr r w ->
        log_s [%message "Connection opened" (addr : Socket.Address.Unix.t)];
        let rec loop () =
          if Reader.is_closed r
          then return ()
          else (
            let%bind sexp =
              let context = "server " ^ Socket.Address.Unix.to_string addr in
              Async_csexp.read ~context r Fn.id
            in
            log_s [%message "received query" (sexp : Sexp.t)];
            let%bind response =
              Implementation.Group.handle_query impl_group sexp
            in
            Async_csexp.write w response;
            log_s [%message "wrote resp" (response : Sexp.t)];
            loop ())
        in
        Deferred.any_unit [ Reader.close_finished r; loop () ])
  in
  Tcp.Server.close_finished server
