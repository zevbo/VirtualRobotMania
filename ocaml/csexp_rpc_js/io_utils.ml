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

module Iobuf : sig
  type t

  val create : int -> t
  val fill : t -> string -> unit

  type consume_result =
    | Consumed
    | Not_enough_data

  val maybe_consume : t -> bytes -> consume_result
  val compact : t -> unit
end = struct
  type t =
    { bytes : Bytes.t
    ; mutable data_start : int
    ; mutable data_stop : int
    }

  let create size = { bytes = Bytes.create size; data_start = 0; data_stop = 0 }
  let consumable t = t.data_stop - t.data_start

  let fill t string =
    Bytes.From_string.blito ~src:string ~dst:t.bytes ~dst_pos:t.data_start ();
    t.data_stop <- t.data_stop + String.length string

  type consume_result =
    | Consumed
    | Not_enough_data

  let maybe_consume t dst =
    let dst_len = Bytes.length dst in
    if consumable t < dst_len
    then Not_enough_data
    else (
      Bytes.blito ~src:t.bytes ~dst ~src_pos:t.data_start ~src_len:dst_len ();
      t.data_start <- t.data_start + dst_len;
      Consumed)

  let compact t =
    Bytes.blito ~src:t.bytes ~dst:t.bytes ~src_pos:t.data_start ~dst_pos:0 ();
    let new_data_stop = t.data_stop - t.data_start in
    t.data_start <- 0;
    t.data_stop <- new_data_stop
end

let input_of_websocket ws closed =
  let module Buffer = Core_kernel.Buffer in
  let input_buf = Iobuf.create 10_000 in
  let input_arrived = Bvar.create () in
  Ev.listen
    Message.Ev.message
    (fun message ->
      print_s [%message "received message"];
      Bvar.broadcast input_arrived ();
      let message = Ev.as_type message in
      Iobuf.compact input_buf;
      Iobuf.fill input_buf (Jstr.to_string (Message.Ev.data message : Jstr.t)))
    (Websocket.as_target ws);
  let rec really_read () dst =
    print_s [%message "really read"];
    match Iobuf.maybe_consume input_buf dst with
    | Consumed -> return `Ok
    | Not_enough_data ->
      let%bind () = Bvar.wait input_arrived in
      really_read () dst
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
      print_s [%message "writing bytes"];
      Websocket.send_string ws (Jstr.of_string (Bytes.to_string bytes)))

let io_of_websocket ws =
  let closed = closed ws in
  input_of_websocket ws closed, output_of_websocket ws closed
