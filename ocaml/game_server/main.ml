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

let find_root () =
  Shexp_process.run "git" [ "rev-parse"; "--show-toplevel" ]
  |> Shexp_process.capture_unit [ Stdout ]
  |> Shexp_process.eval
  |> String.strip

let () =
  Command.group
    ~summary:"Game engine server"
    [ command "test" (fun () -> return Test_game.Implementation.group)
    ; command "ctf" (fun () ->
          let root = find_root () in
          return
            (Ctf.Implementation.group ~root (module Geo_graph_tsdl.Display)))
    ]
  |> Command.run
