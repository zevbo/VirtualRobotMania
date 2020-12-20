open! Core
open! Async
open! Import

let dispatch (type a b) (call : (a, b) Call.t) ~filename (query : a) =
  let%bind _, r, w = Tcp.connect (Tcp.Where_to_connect.of_file filename) in
  let (module Query) = call.query in
  Async_csexp.write w (List [ Atom call.name; Query.sexp_of_t query ]);
  let (module Resp) = call.response in
  Async_csexp.read ~context:call.name r Resp.t_of_sexp
