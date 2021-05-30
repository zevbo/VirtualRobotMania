open! Core_kernel
open! Async_kernel
open Brr
module Canvas = Brr_canvas.Canvas
module C2d = Brr_canvas.C2d
module Matrix4 = Brr_canvas.Matrix4

let pelosi =
  "https://cdn.britannica.com/s:250x250,c:crop/93/204193-050-16E326DA/Nancy-Pelosi-2018.jpg"

let def fut =
  Deferred.create (fun ivar -> Fut.await fut (fun x -> Ivar.fill ivar x))

let load_image url =
  let img = El.img ~at:[ At.src (Jstr.of_string url) ] () in
  let loaded = Ivar.create () in
  let on_load _ = Ivar.fill loaded () in
  let%bind () =
    Ev.listen Ev.load on_load (El.as_target img);
    Ivar.read loaded
  in
  Ev.unlisten Ev.load on_load (El.as_target img);
  return img

let () =
  don't_wait_for
    (let w = 500 in
     let h = 500 in
     let canvas = Brr_canvas.Canvas.create ~d:G.document ~w:500 ~h:500 [] in
     El.set_children (Document.body G.document) [ Canvas.to_el canvas ];
     let c2d = C2d.create canvas in
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
