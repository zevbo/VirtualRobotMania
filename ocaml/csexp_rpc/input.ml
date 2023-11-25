open! Core
open! Async_kernel

type t =
  | T :
      { input : 'input
      ; really_read : 'input -> bytes -> [ `Eof of int | `Ok ] Deferred.t
      ; close : 'input -> unit Deferred.t
      ; close_finished : 'input -> unit Deferred.t
      }
      -> t

let create input ~really_read ~close ~close_finished =
  T { input; really_read; close; close_finished }

let really_read (T t) bytes = t.really_read t.input bytes
let close (T t) = t.close t.input
let close_finished (T t) = t.close_finished t.input
