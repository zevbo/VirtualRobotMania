open! Core_kernel

type t =
  { contents : string
  ; format : string
  }
[@@deriving sexp]
