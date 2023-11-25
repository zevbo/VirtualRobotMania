open! Core
open! Async_kernel
open Geo
module Color = Geo_graph.Color
module Display = Geo_graph.Display

let pelosi =
  "https://cdn.britannica.com/s:250x250,c:crop/93/204193-050-16E326DA/Nancy-Pelosi-2018.jpg"

let rec pairs l =
  match l with
  | [] | [ _ ] -> []
  | x :: y :: rest -> (x, y) :: pairs (y :: rest)

let v = Vec.create

let nth_color n =
  let open Float.O in
  let to_byte x = Float.iround_down_exn ((x + 1.) / 2. * 256.) in
  Color.rgb
    (to_byte (Float.sin (Float.of_int n / 25.)))
    (to_byte (Float.sin (Float.of_int n / 27.)))
    (to_byte (Float.sin (Float.of_int n / 24.)))

let () =
  don't_wait_for
    (print_s [%message "starting up"];
     let display =
       Display.init
         ~physical:(1000, 500)
         ~logical:(1000, 500)
         ~title:"This is my title"
         ~log_s:print_s
     in
     let%bind pelosi = Display.Image.of_name display pelosi in
     let red = Display.Image.pixel display Color.red in
     let blue = Display.Image.pixel display Color.blue in
     let rec loop n =
       let start_cycle = Time_ns.now () in
       let angle = Float.of_int n *. Float.pi /. 50. in
       let size = 100. *. (1. +. Float.sin (Float.of_int n /. 25.)) in
       let scale = Float.O.((1. + Float.sin (Float.of_int n /. 100.)) /. 2.) in
       Display.clear display (Color.rgb 100 100 150);
       Display.draw_image
         display
         pelosi
         ~angle:(-.angle)
         ~scale
         ~center:(v size (size /. 2.));
       Display.draw_image
         display
         pelosi
         ~alpha:100
         ~angle:(angle *. 2.)
         ~center:(v (-.size) (size /. 2.));
       Display.draw_image_wh
         display
         red
         ~alpha:150
         ~w:50.
         ~h:20.
         ~center:(v size (-.size))
         ~angle;
       Display.draw_image
         display
         blue
         ~alpha:150
         ~scale:50.
         ~center:(Vec.add (v 100. 100.) (v size (-.size)))
         ~angle;
       List.iter
         (let x = 450. in
          let y = 200. in
          pairs [ v (-.x) (-.y); v x (-.y); v x y; v (-.x) y; v (-.x) (-.y) ])
         ~f:(fun (v1, v2) ->
           Display.draw_line display ~width:5. v1 v2 (nth_color n));
       let%bind () =
         Clock_ns.at (Time_ns.add start_cycle (Time_ns.Span.of_ms 16.))
       in
       loop (n + 1)
     in
     loop 0)

(* UNUSED BELOW HERE *)

open Brr
module Canvas = Brr_canvas.Canvas
module C2d = Brr_canvas.C2d

let load_image url =
  let img = El.img ~at:[ At.src (Jstr.of_string url) ] () in
  let loaded = Ivar.create () in
  let on_load _ = Ivar.fill loaded () in
  let listener = Ev.listen Ev.load on_load (El.as_target img) in
  let%bind () = Ivar.read loaded in
  Ev.unlisten listener;
  return img

let _run () =
  don't_wait_for
    (let w = 500 in
     let h = 500 in
     let canvas = Brr_canvas.Canvas.create ~d:G.document ~w:500 ~h:500 [] in
     El.set_children (Document.body G.document) [ Canvas.to_el canvas ];
     let c2d = C2d.get_context canvas in
     let draw_lines lines =
       let path = C2d.Path.create () in
       List.iter lines ~f:(fun (x, y) -> C2d.Path.line_to path ~x ~y);
       C2d.stroke c2d path
     in
     Async_js.init ();
     let%bind img = load_image pelosi in
     let img_src = C2d.image_src_of_el img in
     let img_w = El.prop El.Prop.width img |> Float.of_int in
     let img_h = El.prop El.Prop.height img |> Float.of_int in
     print_s [%message "image loaded" (img_w : float) (img_h : float)];
     let rec loop n =
       C2d.clear_rect c2d ~x:0. ~y:0. ~w:(Float.of_int w) ~h:(Float.of_int h);
       let size = 200. *. (1. +. Float.sin (Float.of_int n /. 15.)) in
       let theta = Float.of_int n *. Float.pi /. 100. in
       C2d.translate c2d ~x:size ~y:(size /. 2.);
       C2d.rotate c2d theta;
       C2d.draw_image c2d img_src ~x:(-.(img_w /. 2.)) ~y:(-.(img_h /. 2.));
       C2d.reset_transform c2d;
       draw_lines [ 0., 0.; 0., size; size, size; size, 0.; 0., 0. ];
       draw_lines [ 0., 0.; size, size ];
       draw_lines [ 0., size; size, 0. ];
       let%bind () = Async_js.sleep 0.01 in
       loop (n + 1)
     in
     loop 0)
