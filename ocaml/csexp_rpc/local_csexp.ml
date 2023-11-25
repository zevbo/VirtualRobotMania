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

let length_digits = 4

let encode sexp =
  let sexp_string = Csexp.to_string sexp in
  let length = String.length sexp_string in
  let trimmed_length_str = Int.to_string length in
  assert (String.length trimmed_length_str <= length_digits);
  let length_str =
    String.concat
      [ String.make (length_digits - String.length trimmed_length_str) '0'
      ; trimmed_length_str
      ]
  in
  let full_str = String.concat [ length_str; sexp_string ] in
  let bytes = Bytes.create (length + length_digits) in
  Bytes.From_string.blito ~src:full_str ~dst:bytes ~dst_pos:0 ();
  bytes

let decode_length bytes =
  let b0 = Bytes.get bytes 0 |> Char.to_int in
  let b1 = Bytes.get bytes 1 |> Char.to_int in
  (b0 lsl 8) + b1

let%expect_test "encode and decode match" =
  let round_trip sexp =
    let encoded = encode sexp in
    let length = Bytes.create 2 in
    Bytes.blito ~src:encoded ~dst:length ~src_len:2 ();
    let length = decode_length length in
    let csexp = Bytes.subo ~pos:2 ~len:length encoded in
    let parsed_sexp =
      match Csexp.parse_string (Bytes.to_string csexp) with
      | Ok x -> x
      | Error _ ->
        raise_s
          [%message "Failed to parse string" (csexp : Bytes.t) (length : int)]
    in
    [%test_eq: Sexp.t] sexp parsed_sexp
  in
  round_trip
    (Sexp.List [ Atom "foo\nbar"; List [ Atom "A"; Atom "b"; Atom "see!" ] ])

include Csexp
