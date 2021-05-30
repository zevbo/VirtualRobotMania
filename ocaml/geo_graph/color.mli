type t

val white : t
val black : t
val red : t
val green : t
val blue : t

(** Use 8-bit integers *)
val rgb : int -> int -> int -> t

(** Includes an alpha channel *)
val rgba : int -> int -> int -> int -> t

val alpha : t -> int -> t
val to_rgb_tuple : t -> int * int * int
val to_rgba_tuple : t -> int * int * int * int
val to_js_string : t -> string
