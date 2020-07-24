type 'a fn = 'a

module CI = Cstubs_internals

type 'a f = 'a CI.fn =
 | Returns  : 'a CI.typ   -> 'a f
 | Function : 'a CI.typ * 'b f  -> ('a -> 'b) f
type 'a name = 
| Fn_double : (int -> int) name

external register_value : 'a name -> 'a fn -> unit =
  "robot_sim_register"

let internal : type a b.
               ?runtime_lock:bool -> string -> (a -> b) Ctypes.fn -> (a -> b) -> unit =
fun ?runtime_lock name fn f -> match fn, name with
| Function (CI.Primitive CI.Int, Returns (CI.Primitive CI.Int)), "double" -> register_value Fn_double (f)
| _ -> failwith ("Linking mismatch on name: " ^ name)

let enum _ _ = () and structure _ = () and union _ = () and typedef _ _ = ()
