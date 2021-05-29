open! Core_kernel
open! Async_kernel
open! Import

type t =
  { input : Input.t
  ; output : Output.t
  }

let create input output = { input; output }

let dispatch (t : t) (type a b) (call : (a, b) Call.t) (query : a) =
  let (module Query) = call.query in
  Async_csexp.write
    ~write:(Output.write_bytes t.output)
    (List [ Atom call.name; Query.sexp_of_t query ]);
  let (module Resp) = call.response in
  Async_csexp.read
    ~context:call.name
    ~really_read:(fun bytes -> Input.really_read t.input bytes)
    Resp.t_of_sexp

let close t = Deferred.all_unit [ Input.close t.input; Output.close t.output ]
