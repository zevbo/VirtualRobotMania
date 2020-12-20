open! Core

(** Represnts a call that can be executed over the network, with an input and
    output type *)

type 'a sexpable := (module Sexpable with type t = 'a)

type ('a, 'b) t =
  { name : string
  ; query : 'a sexpable
  ; response : 'b sexpable
  }

val create : string -> 'a sexpable -> 'b sexpable -> ('a, 'b) t
