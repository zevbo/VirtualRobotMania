open! Core_kernel
open! Async_kernel

let () =
  don't_wait_for
    (let%bind impl =
       Ctf.Implementation.group ~log_s:print_s (module Geo_graph_js.Display)
     in
     Csexp_rpc_js.Js_server.run impl)
