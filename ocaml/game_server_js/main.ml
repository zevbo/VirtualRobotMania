open! Core_kernel
open! Async_kernel
open Brr
module Canvas = Brr_canvas.Canvas
module C2d = Brr_canvas.C2d

let () =
  let w = 500
  and h = 500 in
  let canvas = Brr_canvas.Canvas.create ~d:G.document ~w:500 ~h:500 [] in
  El.set_children (Document.body G.document) [ Canvas.to_el canvas ];
  let c2d = C2d.create canvas in
  let draw_lines lines =
    let path = C2d.Path.create () in
    List.iter lines ~f:(fun (x, y) -> C2d.Path.line_to path ~x ~y);
    C2d.stroke c2d path
  in
  Async_js.init ();
  let rec loop n =
    C2d.clear_rect c2d ~x:0. ~y:0. ~w:(Float.of_int w) ~h:(Float.of_int h);
    let size = 200. *. (1. +. Float.sin (Float.of_int n /. 15.)) in
    draw_lines [ 0., 0.; 0., size; size, size; size, 0.; 0., 0. ];
    draw_lines [ 0., 0.; size, size ];
    draw_lines [ 0., size; size, 0. ];
    let%bind () = Async_js.sleep 0.01 in
    loop (n + 1)
  in
  don't_wait_for (loop 0)
