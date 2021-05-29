open! Core_kernel
open! Async_kernel
open! Import

val read
  :  context:string
  -> really_read:(bytes -> [< `Eof of int | `Ok ] Deferred.t)
  -> (Sexp.t -> 'a)
  -> 'a Deferred.t

val write : write:(bytes -> 'a) -> Sexp.t -> 'a
