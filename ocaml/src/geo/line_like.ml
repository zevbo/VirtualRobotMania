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

let param_of ?(epsilon = General.epsilon) t pt = 
    if on_line t pt ~epsilon then 
        Some (unsafe_param_of t pt )
    else 
        None

exception Bad_line_like_parameter of string
let create_w_points pt dir_vec flip_points = 
    let ll_contianer = {pt; dir_vec; flips= []} in
    let param_of_flip flip_pt =
        match param_of ll_contianer flip_pt with
        | Some t -> t 
        | None -> raise (Bad_line_like_parameter "attempted to initialize line like with flip_pt not on line")
    in
    let flips = List.map flip_points ~f:param_of_flip in
    {pt; dir_vec; flips} 
let flip_points_of t = List.map t.flips ~f:(param_to_point t)