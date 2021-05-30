open! Core
open! Async
module Protocol = Test_game.Protocol
module Implementation = Csexp_rpc.Implementation

let command ~log_s name gen_impl =
  let command =
    Command.async
      ~summary:(name ^ " game")
      (let%map_open.Command filename = anon ("pipe" %: Filename.arg_type) in
       fun () ->
         let%bind impl = gen_impl () in
         Csexp_rpc_unix.Unix_server.run impl ~filename ~log_s)
  in
  name, command

let root () =
  Shexp_process.run "git" [ "rev-parse"; "--show-toplevel" ]
  |> Shexp_process.capture_unit [ Stdout ]
  |> Shexp_process.eval
  |> String.strip

let () =
  let log_s = Async.Log.Global.info_s in
  let command = command ~log_s in
  Command.group
    ~summary:"Game engine server"
    [ command "test" (fun () -> return Test_game.Implementation.group)
    ; command "ctf" (fun () ->
          let group =
            Ctf.Implementation.group ~log_s (module Geo_graph_tsdl.Display)
          in
          let%map username = Unix.getlogin () in
          Log.Global.set_output
            [ Log.Output.file
                `Sexp_hum
                ~filename:(sprintf "/tmp/game-engine-%s.log" username)
            ];
          group)
    ]
  |> Command.run
