open! Core_kernel
open! Async_kernel
open! Import

let run impl_group ~context input output ~log_s =
  let rec loop () =
    if Deferred.is_determined (Input.close_finished input)
    then return ()
    else (
      let%bind sexp =
        Async_csexp.read
          ~context
          ~really_read:(fun bytes -> Input.really_read input bytes)
          Fn.id
      in
      log_s [%message "received query" (sexp : Sexp.t)];
      let%bind response = Implementation.Group.handle_query impl_group sexp in
      Async_csexp.write ~write:(Output.write_bytes output) response;
      log_s [%message "wrote resp" (response : Sexp.t)];
      loop ())
  in
  Deferred.any_unit
    [ Input.close_finished input; Output.close_finished output; loop () ]
