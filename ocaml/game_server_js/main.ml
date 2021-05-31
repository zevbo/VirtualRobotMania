open! Core_kernel
open! Async_kernel

let () =
  don't_wait_for
    (Csexp_rpc_js.Js_server.run
       (Ctf.Implementation.group ~log_s:print_s (module Geo_graph_js.Display)))
