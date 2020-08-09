type t = Simple of { drag_c : float; fric_c : float }

type collision_data = { drag_c : float; fric_c : float }

let collision_data t1 t2 =
  match (t1, t2) with
  | ( Simple { drag_c = drag_c1; fric_c = fric_c1 },
      Simple { drag_c = drag_c2; fric_c = fric_c2 } ) ->
      { drag_c = sqrt (drag_c1 *. drag_c2); fric_c = sqrt (fric_c1 *. fric_c2) }

let drag_c_of t1 t2 = (collision_data t1 t2).drag_c

let fric_c_of t1 t2 = (collision_data t1 t2).fric_c
