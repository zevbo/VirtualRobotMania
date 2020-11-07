open Geo
open! Base

type t

val init : w:int -> h:int -> title:string -> t

module Image : sig
  type display := t
  type t

  val of_bmp_file : display -> string -> t
  val destory : t -> unit
end

val draw_image : t -> Image.t -> Vec.t -> Angle.t
