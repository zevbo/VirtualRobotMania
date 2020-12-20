open! Core
open! Async
open! Import

let dispatch (type a b) (call : (a, b) Call.t) ~filename (query : a) =
  let%bind _, r, w = Tcp.connect (Tcp.Where_to_connect.of_file filename) in
  let (module Query) = call.query in
  Writer.write_bytes w (Csexp.encode (Query.sexp_of_t query));
  let length = Bytes.create 2 in
  match%bind Reader.really_read r length with
  | `Eof bytes_read ->
    raise_s [%message "EOF while reading length" (bytes_read : int)]
  | `Ok ->
    let length = Csexp.decode_length length in
    let body = Bytes.create length in
    (match%bind Reader.really_read r body with
    | `Eof bytes_read ->
      raise_s
        [%message "EOF while reading body" (length : int) (bytes_read : int)]
    | `Ok ->
      (match Csexp.parse_string (Bytes.to_string body) with
      | Error (loc, error) ->
        raise_s
          [%message
            "Error parsing csexp" (body : bytes) (loc : int) (error : string)]
      | Ok sexp ->
        let (module Resp) = call.response in
        return (Resp.t_of_sexp sexp)))
