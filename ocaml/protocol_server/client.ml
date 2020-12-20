open! Core
open! Async
open! Import

let dispatch (type a b) (call : (a, b) Call.t) ~filename (query : a) =
  let%bind _, _r, w = Tcp.connect (Tcp.Where_to_connect.of_file filename) in
  let (module Query) = call.query in
  Writer.write_bytes w (Csexp.encode (Query.sexp_of_t query));
  return ()
