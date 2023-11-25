open! Core
include Csexp.S with type sexp := Sexp.t

val encode : Sexp.t -> bytes
val decode_length : bytes -> int
