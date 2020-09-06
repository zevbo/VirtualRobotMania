open Ctypes

(** This is the file where we expose the functions we want to allow to be called
    from Racket. *)

module Stubs (I : Cstubs_inverted.INTERNAL) = struct
  let () =
    I.internal "double_int" (int @-> returning int) Robot_sim.Simple.double_int
end
