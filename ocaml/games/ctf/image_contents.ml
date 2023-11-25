open! Core

type t =
  { contents : string
  ; format : string
  }
[@@deriving sexp]
