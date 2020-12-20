open! Core
open! Async
module Protocol = Test_game.Protocol
module Implementation = Csexp_rpc.Implementation

let command name impl =
  let command =
    Command.async
      ~summary:(name ^ " game")
      (let%map_open.Command filename = anon ("pipe" %: Filename.arg_type) in
       fun () -> Csexp_rpc.Server.run impl ~filename)
  in
  name, command

let () =
  Command.group
    ~summary:"Game engine server"
    [ command "test" Test_game.Implementation.group
    ; command "ctf" Ctf.Implementation.group
    ]
  |> Command.run
