open! Core
open! Async
module Game_state = Robot_sim.Game_state
module Protocol = Robot_sim.Protocol
module Implementation = Protocol_server.Implementation

let impls =
  let state = Lazy.from_fun Game_state.create in
  let impl = Implementation.create in
  Protocol_server.Implementation.Group.create
    [ impl Protocol.step (fun () -> Game_state.step (force state))
    ; impl Protocol.add_bot (fun () -> Game_state.add_bot (force state))
    ; impl Protocol.load_bot_image (fun (id, path) ->
          Game_state.load_bot_image (force state) id path)
    ]

let () =
  Command.async
    ~summary:"Game engine server"
    (let%map_open.Command filename = anon ("pipe" %: Filename.arg_type) in
     fun () -> Protocol_server.Server.server impls ~filename)
  |> Command.run
