open! Core_kernel

type t

val create : unit -> t
val step : t -> unit
val add_bot : t -> int
val load_bot_image : t -> int -> string -> unit
