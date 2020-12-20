open! Core
open! Async
open! Import

let server impl_group ~filename =
  let%bind () =
    match%bind Sys.file_exists_exn filename with
    | true -> Unix.unlink filename
    | false -> Deferred.unit
  in
  let%bind server =
    Tcp.Server.create
      ~on_handler_error:`Raise
      (Tcp.Where_to_listen.of_file filename)
      (fun addr r w ->
        (* Two byte length, followed by s-expression *)
        let length = Bytes.create 2 in
        match%bind Reader.really_read r length with
        | `Eof _ ->
          raise_s
            [%message "Eof while reading size" (addr : Socket.Address.Unix.t)]
        | `Ok ->
          let length = Csexp.decode_length length in
          let body = Bytes.create length in
          (match%bind Reader.really_read r body with
          | `Eof _ ->
            raise_s
              [%message
                "Eof while reading body"
                  (addr : Socket.Address.Unix.t)
                  (length : int)]
          | `Ok ->
            (match Csexp.parse_string (Bytes.to_string body) with
            | Error (loc, error) ->
              raise_s
                [%message
                  "Error parsing csexp"
                    (body : Bytes.t)
                    (loc : int)
                    (error : string)]
            | Ok sexp ->
              let response =
                Implementation.Group.handle_query impl_group sexp
              in
              let response = Csexp.to_string response in
              let length = String.length response in
              (* Are these right? *)
              let b0 = length land 0xFF in
              let b1 = (length lsr 8) land 0xFF in
              Writer.write_byte w b0;
              Writer.write_byte w b1;
              Deferred.unit)))
  in
  Tcp.Server.close_finished server
