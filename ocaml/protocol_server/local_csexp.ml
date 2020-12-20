open! Core
module Csexp = Csexp.Make (Sexp)

let%expect_test _ =
  print_endline (Csexp.to_string (Sexp.of_string "(a b (c d e))"));
  [%expect {| (1:a1:b(1:c1:d1:e)) |}];
  (* Carriage returns make it through *)
  print_endline (Csexp.to_string (Atom "foo\nbar"));
  [%expect {|
    7:foo
    bar |}];
  let of_csexp string =
    match Csexp.parse_string string with
    | Error _ -> assert false
    | Ok sexp -> print_endline (Sexp.to_string_hum sexp)
  in
  of_csexp "(3:123(5:hello8:whatever)(5:never))";
  [%expect {| (123 (hello whatever) (never)) |}];
  of_csexp "(3:123(5:hello20:whatever with spaces)(5:never))";
  [%expect {| (123 (hello "whatever with spaces") (never)) |}];
  of_csexp "(4:#123(5:hello22:whatever (with) spaces)(5:never))";
  [%expect {| (#123 (hello "whatever (with) spaces") (never)) |}]

let encode sexp =
  let sexp_string = Csexp.to_string sexp in
  let length = String.length sexp_string in
  let bytes = Bytes.create (length + 2) in
  Bytes.set bytes 0 (Char.of_int_exn (length land 0xFF));
  Bytes.set bytes 1 (Char.of_int_exn ((length lsr 8) land 0xFF));
  Bytes.From_string.blito ~src:sexp_string ~dst:bytes ~dst_pos:2 ();
  bytes

let decode_length bytes =
  let b0 = Bytes.get bytes 0 |> Char.to_int in
  let b1 = Bytes.get bytes 1 |> Char.to_int in
  (b0 lsl 8) + b1

include Csexp
