open! Core_kernel
open! Async_kernel
open! Import
open! Brr
module Websocket = Brr_io.Websocket
module Message = Brr_io.Message

let closed ws =
  Deferred.create (fun closed ->
      Ev.listen
        Websocket.Ev.close
        (fun _ -> Ivar.fill closed ())
        (Websocket.as_target ws))

let input_of_websocket ws closed =
  let module Buffer = Core_kernel.Buffer in
  let input_buf = Iobuf.create ~len:10_000 in
  let input_arrived = Bvar.create () in
  Ev.listen
    Message.Ev.message
    (fun message ->
      Bvar.broadcast input_arrived ();
      let message = Ev.as_type message in
      Iobuf.compact input_buf;
      Iobuf.Fill.stringo
        input_buf
        (Jstr.to_string (Message.Ev.data message : Jstr.t)))
    (Websocket.as_target ws);
  let rec really_read () bytes =
    if Iobuf.length input_buf < Bytes.length bytes
    then (
      let%bind () = Bvar.wait input_arrived in
      really_read () bytes)
    else (
      Iobuf.Consume.To_bytes.blito
        ~src:(Iobuf.read_only input_buf)
        ~dst:bytes
        ();
      return `Ok)
  in
  Input.create
    ()
    ~really_read
    ~close:(fun () ->
      Websocket.close ws;
      closed)
    ~close_finished:(fun () -> closed)

let output_of_websocket ws closed =
  Output.create
    ()
    ~close:(fun () ->
      Websocket.close ws;
      closed)
    ~close_finished:(fun () -> closed)
    ~write_bytes:(fun () bytes ->
      Websocket.send_string ws (Jstr.of_string (Bytes.to_string bytes)))

let io_of_websocket ws =
  let closed = closed ws in
  input_of_websocket ws closed, output_of_websocket ws closed
