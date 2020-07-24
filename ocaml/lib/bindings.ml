open Ctypes

module Stubs (I : Cstubs_inverted.INTERNAL) = struct
  let () = I.internal "double_int" (int @-> returning int) Robot_sim.Simple.double_int
end
