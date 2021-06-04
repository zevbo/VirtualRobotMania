open! Core_kernel
open! Async_kernel

let () =
  don't_wait_for
    (let%bind impl = Ctf.Implementation.group ~log_s:print_s in
     Csexp_rpc_js.Js_server.run impl)
