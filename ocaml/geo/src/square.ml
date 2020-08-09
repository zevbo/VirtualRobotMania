open! Vec
open! Base

type t = {width: float; height: float; center: Vec.t}

let contains t pt =
  General.imp_equals pt.x t.center.x ~epsilon:(t.width /. 2.) &&
  General.imp_equals pt.y t.center.y ~epsilon:(t.height /. 2.)

let get_corners t = 
  let w = t.width /. 2. in 
  let h = t.height /. 2. in
  let relative_corners =  [Vec.create w h; Vec.create w (-. h); Vec.create (-. w) h; Vec.create (-. w) (-. h)] in
  List.map relative_corners  ~f:(fun corner -> Vec.add corner t.center)