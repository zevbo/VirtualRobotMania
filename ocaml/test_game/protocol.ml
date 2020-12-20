open! Core
module Call = Csexp_rpc.Call

let step = Call.create "step" (module Unit) (module Unit)
let add_bot = Call.create "add-bot" (module Unit) (module Int)

let load_bot_image =
  let module Query = struct
    type t = int * string [@@deriving sexp]
  end
  in
  Call.create "load-bot-image" (module Query) (module Unit)
