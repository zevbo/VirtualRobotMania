open! Geo

type t =
  { ls : Line_like.segment Line_like.t
  ; material : Material.t
  }
[@@deriving sexp_of]

val create : Line_like.segment Line_like.t -> Material.t -> t
