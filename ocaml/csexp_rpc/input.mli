open! Core
open! Async_kernel

type t

val create
  :  'input
  -> really_read:('input -> bytes -> [ `Eof of int | `Ok ] Deferred.t)
  -> close:('input -> unit Deferred.t)
  -> close_finished:('input -> unit Deferred.t)
  -> t

val really_read : t -> bytes -> [ `Eof of int | `Ok ] Deferred.t
val close : t -> unit Deferred.t
val close_finished : t -> unit Deferred.t
