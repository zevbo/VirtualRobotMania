module Input := Csexp_rpc.Input
module Output := Csexp_rpc.Output
module Websocket := Brr_io.Websocket

val io_of_websocket : Websocket.t -> Input.t * Output.t
