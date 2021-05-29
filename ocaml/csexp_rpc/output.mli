open! Core_kernel
open! Async_kernel

type t

val create
  :  'output
  -> write_bytes:('output -> bytes -> unit)
  -> close:('output -> unit Deferred.t)
  -> close_finished:('output -> unit Deferred.t)
  -> t

val write_bytes : t -> bytes -> unit
val close : t -> unit Deferred.t
val close_finished : t -> unit Deferred.t
