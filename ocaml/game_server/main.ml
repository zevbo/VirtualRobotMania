open! Core
open! Async
module Game_state = Test_game.Game_state
module Protocol = Test_game.Protocol
module Implementation = Csexp_rpc.Implementation

let impls =
  let state = Lazy.from_fun Game_state.create in
  let impl = Implementation.create in
  let impl' = Implementation.create' in
  Csexp_rpc.Implementation.Group.create
    [ impl Protocol.step (fun () -> Game_state.step (force state))
    ; impl Protocol.add_bot (fun () -> Game_state.add_bot (force state))
    ; impl' Protocol.load_bot_image (fun (id, path) ->
          Game_state.load_bot_image (force state) id path)
    ]

let () =
  Command.async
    ~summary:"Game engine server"
    (let%map_open.Command filename = anon ("pipe" %: Filename.arg_type) in
     fun () -> Csexp_rpc.Server.run impls ~filename)
  |> Command.run
