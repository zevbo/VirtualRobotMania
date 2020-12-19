open Ctypes

(** This is the file where we expose the functions we want to allow to be called
    from Racket. *)

module Stubs (I : Cstubs_inverted.INTERNAL) = struct
  let () =
    I.internal "double_int" (int @-> returning int) Robot_sim.Simple.double_int;
    I.internal "add_bot" (void @-> returning int) Robot_sim.Game.add_bot;
    I.internal "step" (void @-> returning void) Robot_sim.Game.step

  (* I.internal "load_bot_image" (int @-> string @-> returning void)
     Robot_sim.Game.load_bot_image *)
end
