open! Core
open! Async

val dispatch : ('a, 'b) Call.t -> filename:string -> 'a -> 'b Deferred.t
val can_connect : filename:string -> bool Deferred.t
