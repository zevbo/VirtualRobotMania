open! Core_kernel
open! Async_kernel
open! Import
module Websocket = Brr_io.Websocket
open! Brr

let websocket () =
  let host = Window.location G.window |> Uri.host |> Jstr.to_string in
  let addr = Jstr.of_string ("ws://" ^ host ^ ":8080/ws") in
  Websocket.create addr

let run impl_group =
  let ws = websocket () in
  let input, output = Io_utils.io_of_websocket ws in
  Csexp_rpc.Server.run impl_group ~context:"csexp" input output ~log_s:print_s
