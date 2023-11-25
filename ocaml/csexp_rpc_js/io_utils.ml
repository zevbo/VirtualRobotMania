open! Core
open! Async_kernel
open! Import
open! Brr
module Websocket = Brr_io.Websocket
module Message = Brr_io.Message

let closed ws =
  Deferred.create (fun closed ->
    let listener =
      Ev.listen
        Websocket.Ev.close
        (fun _ -> Ivar.fill closed ())
        (Websocket.as_target ws)
    in
    ignore listener)

let def fut =
  Deferred.create (fun ivar -> Fut.await fut (fun x -> Ivar.fill ivar x))

module Iobuf : sig
  type t

  val create : int -> t
  val fill : t -> Blob.t -> unit Deferred.t

  type consume_result =
    | Consumed
    | Not_enough_data
  [@@deriving sexp]

  val maybe_consume : t -> bytes -> consume_result
  val compact : t -> unit
end = struct
  type t =
    { bytes : (Bytes.t[@sexp.opaque])
    ; mutable data_start : int
    ; mutable data_stop : int
    }
  [@@deriving sexp]

  let create size = { bytes = Bytes.create size; data_start = 0; data_stop = 0 }
  let consumable t = t.data_stop - t.data_start

  let fill t blob =
    match%bind def (Blob.text blob) with
    | Error err ->
      raise_s
        [%message
          "error fetching text from blob"
            ~_:(Jstr.to_string (Jv.Error.message err) : string)]
    | Ok text ->
      let string = Jstr.to_string text in
      Bytes.From_string.blito ~src:string ~dst:t.bytes ~dst_pos:t.data_start ();
      t.data_stop <- t.data_stop + String.length string;
      return ()

  type consume_result =
    | Consumed
    | Not_enough_data
  [@@deriving sexp]

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
  let module Buffer = Core.Buffer in
  let input_buf = Iobuf.create 10_000 in
  let input_arrived = Bvar.create () in
  let seq = Sequencer.create () in
  let _listener =
    Ev.listen
      Message.Ev.message
      (fun message ->
        don't_wait_for
          (Throttle.enqueue seq (fun () ->
             let message = Ev.as_type message in
             Iobuf.compact input_buf;
             let%bind () =
               Iobuf.fill input_buf (Message.Ev.data message : Blob.t)
             in
             Bvar.broadcast input_arrived ();
             return ())))
      (Websocket.as_target ws)
  in
  let rec really_read () dst =
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
      (* Bug here: converting the bytes to a string because the int at the start
         cannot always be converted to a string *)
      Websocket.send_string ws (Jstr.of_string (Bytes.to_string bytes)))

let io_of_websocket ws =
  let closed = closed ws in
  input_of_websocket ws closed, output_of_websocket ws closed
