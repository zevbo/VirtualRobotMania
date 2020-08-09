open! Vec

type t = {width: float; height: float; center: Vec.t}

let contains t pt =
  General.imp_equals pt.x t.center.x ~epsilon_:(t.width /. 2.) &&
  General.imp_equals pt.y t.center.y ~epsilon_:(t.height /. 2.)
