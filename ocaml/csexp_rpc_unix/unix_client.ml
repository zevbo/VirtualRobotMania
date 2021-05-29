open! Core
open! Async
open! Import

let connect ~filename =
  let%map _, r, w = Tcp.connect (Tcp.Where_to_connect.of_file filename) in
  let input = Io_utils.input_of_reader r in
  let output = Io_utils.output_of_writer w in
  Client.create input output

let rec connect_aggressively ~filename =
  match%bind try_with (fun () -> connect ~filename) with
  | Error _ ->
    let%bind () = Clock.after (Time.Span.of_ms 20.) in
    connect_aggressively ~filename
  | Ok t -> return t
