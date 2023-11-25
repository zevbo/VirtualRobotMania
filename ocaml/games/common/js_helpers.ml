open Async_kernel
open Brr

let load_image url =
  let img = El.img ~at:[ At.src (Jstr.of_string url) ] () in
  let loaded = Ivar.create () in
  let on_load _ = Ivar.fill loaded () in
  let%bind listener =
    let listener = Ev.listen Ev.load on_load (El.as_target img) in
    let%map () = Ivar.read loaded in
    listener
  in
  Ev.unlisten listener;
  return img
