open! Core

type 'a sexpable = (module Sexpable with type t = 'a)

type ('a, 'b) t =
  { name : string
  ; query : 'a sexpable
  ; response : 'b sexpable
  }

let create name query response = { name; query; response }
