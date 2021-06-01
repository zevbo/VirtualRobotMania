open Async_kernel
open Brr

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
