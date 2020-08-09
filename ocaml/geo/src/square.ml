open! Vec

type t = {width: float; height: float; center: Vec.t}

let contains t pt =
  General.imp_equals pt.x t.center.x ~epsilon:(t.width /. 2.) &&
  General.imp_equals pt.y t.center.y ~epsilon:(t.height /. 2.)
