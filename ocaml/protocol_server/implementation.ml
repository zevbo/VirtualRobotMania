open! Core

type t =
  | T :
      { rpc : ('a, 'b) Call.t
      ; f : 'a -> 'b
      }
      -> t [@unboxed]

let create rpc f = T { rpc; f }

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
        (match impl.f query with
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
          | sexp -> sexp)))

  let handle_query (t : t) (sexp : Sexp.t) =
    let rpc_name, body =
      match sexp with
      | Atom rpc_name -> rpc_name, Sexp.unit
      | List (Atom rpc_name :: args) -> rpc_name, Sexp.List args
      | _ ->
        raise_s [%message "Can't extract rpc-name from query" (sexp : Sexp.t)]
    in
    handle_named_rpc t rpc_name body
end
