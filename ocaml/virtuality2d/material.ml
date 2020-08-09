type t =
  | Simple of
      { drag_c : float
      ; fric_c : float
      ; energy_ret : float
      }

type collision_data =
  { drag_c : float
  ; fric_c : float
  ; energy_ret : float
  }

let collision_data t1 t2 =
  match t1, t2 with
  | ( Simple { drag_c = drag_c1; fric_c = fric_c1; energy_ret = energy_ret1 }
    , Simple { drag_c = drag_c2; fric_c = fric_c2; energy_ret = energy_ret2 } )
    ->
    { drag_c = sqrt (drag_c1 *. drag_c2)
    ; fric_c = sqrt (fric_c1 *. fric_c2)
    ; energy_ret = sqrt (energy_ret1 *. energy_ret2)
    }

let drag_c_of t1 t2 = (collision_data t1 t2).drag_c
let fric_c_of t1 t2 = (collision_data t1 t2).fric_c
