open! Core
open! Async
open! Import

let dispatch (type a b) (call : (a, b) Call.t) ~filename (query : a) =
  let%bind _, r, w = Tcp.connect (Tcp.Where_to_connect.of_file filename) in
  let (module Query) = call.query in
  Async_csexp.write w (List [ Atom call.name; Query.sexp_of_t query ]);
  let (module Resp) = call.response in
  let%bind result = Async_csexp.read ~context:call.name r Resp.t_of_sexp in
  let%map () = Deferred.all_unit [ Reader.close r; Writer.close w ] in
  result

let can_connect ~filename =
  match%bind
    try_with (fun () -> Tcp.connect (Tcp.Where_to_connect.of_file filename))
  with
  | Ok (_, r, w) ->
    let%map () = Deferred.all_unit [ Reader.close r; Writer.close w ] in
    true
  | Error _ -> return false
