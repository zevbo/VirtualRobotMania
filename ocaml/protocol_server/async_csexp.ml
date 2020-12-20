open! Core
open! Async
open! Import

let read ~context r of_sexp =
  let length = Bytes.create 2 in
  match%bind Reader.really_read r length with
  | `Eof bytes_read ->
    raise_s
      [%message
        "EOF while reading length" (context : string) (bytes_read : int)]
  | `Ok ->
    let length = Csexp.decode_length length in
    let body = Bytes.create length in
    (match%bind Reader.really_read r body with
    | `Eof bytes_read ->
      raise_s
        [%message
          "EOF while reading body"
            (context : string)
            (length : int)
            (bytes_read : int)]
    | `Ok ->
      (match Csexp.parse_string (Bytes.to_string body) with
      | Error (loc, error) ->
        raise_s
          [%message
            "Error parsing csexp"
              (context : string)
              (body : bytes)
              (loc : int)
              (error : string)]
      | Ok sexp ->
        (match of_sexp sexp with
        | exception exn ->
          raise_s
            [%message
              "Error interpreting s-expression"
                (context : string)
                (sexp : Sexp.t)
                (exn : Exn.t)]
        | value -> return value)))

let write w sexp = Writer.write_bytes w (Csexp.encode sexp)
