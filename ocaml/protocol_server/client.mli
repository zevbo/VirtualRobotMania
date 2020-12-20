open! Core
open! Async

val dispatch : ('a, 'b) Call.t -> filename:string -> 'a -> 'b Deferred.t
