open! Core
open! Async_kernel

type t =
  | T :
      { output : 'output
      ; write_bytes : 'output -> bytes -> unit
      ; close : 'output -> unit Deferred.t
      ; close_finished : 'output -> unit Deferred.t
      }
      -> t

let create output ~write_bytes ~close ~close_finished =
  T { output; write_bytes; close; close_finished }

let write_bytes (T t) bytes = t.write_bytes t.output bytes
let close (T t) = t.close t.output
let close_finished (T t) = t.close_finished t.output
