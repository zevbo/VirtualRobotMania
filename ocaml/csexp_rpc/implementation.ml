open! Core_kernel
open! Async_kernel

type t =
  | T :
      { rpc : ('a, 'b) Call.t
      ; f : 'a -> 'b Deferred.t
      }
      -> t [@unboxed]

let create rpc f =
  let f x = return (f x) in
  T { rpc; f }

let create' rpc f = T { rpc; f }

module Group = struct
  type impl = t
  type t = impl Map.M(String).t

  let create (impls : impl list) =
    List.map impls ~f:(fun (T impl) -> impl.rpc.name, T impl)
    |> Map.of_alist_exn (module String)

  let handle_named_rpc (t : t) rpc_name query_body =
    match Map.find t rpc_name with
    | None -> raise_s [%message "Unrecognized RPC" (rpc_name : string)]
    | Some (T impl) ->
      let (module Query) = impl.rpc.query in
      (match Query.t_of_sexp query_body with
      | exception exn ->
        raise_s
          [%message
            "Failure parsing query sexp" (rpc_name : string) (exn : Exn.t)]
      | query ->
        let%bind response = impl.f query in
        (match response with
        | exception exn ->
          raise_s
            [%message "Implementation raised" (rpc_name : string) (exn : Exn.t)]
        | response ->
          let (module Resp) = impl.rpc.response in
          (match Resp.sexp_of_t response with
          | exception exn ->
            raise_s
              [%message
                "Failure creating response sexp"
                  (rpc_name : string)
                  (exn : Exn.t)]
          | sexp -> return sexp)))

  let handle_query (t : t) (sexp : Sexp.t) =
    let rpc_name, body =
      match sexp with
      | List [ Atom rpc_name; body ] -> rpc_name, body
      | _ ->
        raise_s [%message "Can't extract rpc-name from query" (sexp : Sexp.t)]
    in
    handle_named_rpc t rpc_name body
end
