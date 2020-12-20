type t

val white : t
val black : t
val red : t
val green : t
val blue : t

(** Use 8-bit integers *)
val rgb : int -> int -> int -> t

val to_tuple : t -> int * int * int
