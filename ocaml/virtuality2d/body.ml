open! Geo

type t =
  { shape : Shape.t
  ; mass : float
  ; ang_intertia : float
  ; pos : Vec.t
  ; v : Vec.t
  ; omega : float
  }

let collide t1 t2 =
  (* Not sure how to handle when there are multiple intersections. For the moment, just choosing the first one *)
  let intersections = Shape.intersections t1.shape t2.shape in
  if (List.length intersections) > 0 then 
    let intersection = List.nth intersections 0 in 
