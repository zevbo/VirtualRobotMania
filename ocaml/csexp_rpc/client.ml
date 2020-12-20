open! Core
open! Async
open! Import

type t =
  { r : Reader.t
  ; w : Writer.t
  }

let connect ~filename =
  let%map _, r, w = Tcp.connect (Tcp.Where_to_connect.of_file filename) in
  { r; w }

let rec connect_aggressively ~filename =
  match%bind try_with (fun () -> connect ~filename) with
  | Error _ ->
    let%bind () = Clock.after (Time.Span.of_ms 20.) in
    connect_aggressively ~filename
  | Ok t -> return t

let dispatch t (type a b) (call : (a, b) Call.t) (query : a) =
  let (module Query) = call.query in
  Async_csexp.write t.w (List [ Atom call.name; Query.sexp_of_t query ]);
  let (module Resp) = call.response in
  Async_csexp.read ~context:call.name t.r Resp.t_of_sexp

let close t = Deferred.all_unit [ Reader.close t.r; Writer.close t.w ]
