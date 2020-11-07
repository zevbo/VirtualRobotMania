type t

(** Use 8-bit integers *)
val rgb : int -> int -> int -> t

val to_tuple : t -> int * int * int
