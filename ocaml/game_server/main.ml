open! Core
open! Async
module Protocol = Test_game.Protocol
module Implementation = Csexp_rpc.Implementation

let command name gen_impl =
  let command =
    Command.async
      ~summary:(name ^ " game")
      (let%map_open.Command filename = anon ("pipe" %: Filename.arg_type) in
       fun () ->
         let%bind impl = gen_impl () in
         Csexp_rpc_unix.Unix_server.run impl ~filename)
  in
  name, command

let () =
  Command.group
    ~summary:"Game engine server"
    [ command "test" (fun () -> return Test_game.Implementation.group)
    ; command "ctf" (fun () ->
          Ctf.Implementation.group (module Geo_graph_tsdl.Display))
    ]
  |> Command.run
