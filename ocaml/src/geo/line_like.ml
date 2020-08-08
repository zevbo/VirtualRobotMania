open! Vec
open! Base
open! General


type t = {pt: Vec.t; dir_vec: Vec.t; flips: float list;}
let create pt dir_vec flips = {pt; dir_vec; flips} 
    
(* param_of_unsafe returns a float c, such that pt + c * dir_vec = to the given point if that point is on the line *)
(* will not error out if the point is not on the line *)
let unsafe_param_of t pt = (Vec.dist t.pt pt) /. (Vec.magSq t.dir_vec)
let param_to_point t param = Vec.add t.pt (Vec.scale t.dir_vec param)
let flips_before t param = 
    (List.length (List.filter t.flips ~f:(fun n -> Float.(n < param))))
let start_on t = (flips_before t 0.) % 2 = 0
let is_param_on t param = Bool.equal ((flips_before t param) % 2 = 0) (start_on t)
let on_line ?(epsilon = General.epsilon) t pt =
    let param = unsafe_param_of t pt in
    let expected_pt = param_to_point t param in
    let is_t_on = is_param_on t param in
    is_t_on && (Vec.equals pt expected_pt ~epsilon)
let flip_points_of t = List.map t.flips ~f:(param_to_point t)
