open Base

let best l f =
  List.max_elt l ~compare:(fun a b -> Float.compare (f a) (f b))
  |> Option.value_exn

let avg x y = (x +. y) /. 2.
let min_and_max l f g = avg (best l f) (best l (fun x -> -.g x))
