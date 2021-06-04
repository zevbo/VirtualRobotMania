open Core_kernel

type t =
  { r : int
  ; g : int
  ; b : int
  ; a : int
  }
[@@deriving sexp]

let rgb r g b = { r; g; b; a = 255 }
let rgba r g b a = { r; g; b; a }
let to_rgb_tuple { r; g; b; a = _ } = r, g, b
let to_rgba_tuple { r; g; b; a } = r, g, b, a
let alpha t a = { t with a }

(* Colors! *)

let white = rgb 255 255 255
let black = rgb 0 0 0
let red = rgb 255 0 0
let green = rgb 0 255 0
let blue = rgb 0 0 255

let to_js_string { r; g; b; a } =
  if a = 255
  then Printf.sprintf "#%02X%02X%02X" r g b
  else Printf.sprintf "#%02X%02X%02X%02X" r g b a

let%expect_test "" =
  let show c = print_endline ("\"" ^ to_js_string c ^ "\"") in
  show (rgb 0 0 0);
  show (rgb 255 0 127);
  show (rgba 255 255 0 255);
  show (rgba 255 0 255 127);
  [%expect {|
    "#000000"
    "#FF007F"
    "#FFFF00"
    "#FF00FF7F" |}]
