open! Core
open! Async
module Implementation = Csexp_rpc.Implementation

let group =
  let state = Lazy.from_fun Game_state.create in
  let impl = Implementation.create in
  let impl' = Implementation.create' in
  Csexp_rpc.Implementation.Group.create
    [ impl Protocol.step (fun () -> Game_state.step (force state))
    ; impl Protocol.add_bot (fun () -> Game_state.add_bot (force state))
    ; impl' Protocol.load_bot_image (fun (id, path) ->
          Game_state.load_bot_image (force state) id path)
    ]
