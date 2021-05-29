open! Core
open! Async
open! Import

let run impl_group ~filename ~log_s =
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
            log_s [%message "Handler raised. Exiting." (exn : Exn.t)]))
      (Tcp.Where_to_listen.of_file filename)
      (fun addr r w ->
        log_s [%message "Connection opened" (addr : Socket.Address.Unix.t)];
        let%bind () =
          Server.run
            impl_group
            ~context:("server " ^ Socket.Address.Unix.to_string addr)
            (Io_utils.input_of_reader r)
            (Io_utils.output_of_writer w)
            ~log_s
        in
        let%bind () = Log.Global.flushed () in
        exit 0)
  in
  Tcp.Server.close_finished server
