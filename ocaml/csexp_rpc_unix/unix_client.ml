open! Core
open! Async
open! Import

open struct
  open Csexp_rpc
  module Input = Input
  module Output = Output
end

let connect ~filename =
  let%map _, r, w = Tcp.connect (Tcp.Where_to_connect.of_file filename) in
  let input =
    Input.create
      r
      ~really_read:(fun r bytes -> Reader.really_read r bytes)
      ~close:Reader.close
      ~close_finished:Reader.close_finished
  in
  let output =
    Output.create
      w
      ~write_bytes:Writer.write_bytes
      ~close:Writer.close
      ~close_finished:Writer.close_finished
  in
  Client.create input output

let rec connect_aggressively ~filename =
  match%bind try_with (fun () -> connect ~filename) with
  | Error _ ->
    let%bind () = Clock.after (Time.Span.of_ms 20.) in
    connect_aggressively ~filename
  | Ok t -> return t
