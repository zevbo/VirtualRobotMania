open! Core
open Geo

type t

(** Starts up the display, with the provided physical (i.e., screen) and logical
    dimentions. *)
val init
  :  physical:int * int
  -> logical:int * int
  -> title:string
  -> log_s:(Sexp.t -> unit)
  -> t

module Image : sig
  type display := t
  type t

  val pixel : display -> Color.t -> t
  val size : t -> int * int

  (** This provides a logical name (with file extension, e.g. "flag.bmp") that
      will be loaded by the engine. Each instance of the engine can have its own
      way of implementing this. e.g., a JavaScript implementation may load the
      corresponding URL from the hosting server, whereas a native one might look
      in a standard directory for the image in question. *)
  val of_name : display -> string -> t Async_kernel.Deferred.t
end

(** {2 Drawing operations}

    Note that these operations do not immediately show up until someone calls
    {!present}. *)

val clear : t -> Color.t -> unit

val draw_image
  :  t
  -> ?scale:float
  -> ?alpha:int
  -> Image.t
  -> center:Vec.t
  -> angle:float
  -> unit

val draw_image_wh
  :  t
  -> w:float
  -> h:float
  -> ?alpha:int
  -> Image.t
  -> center:Vec.t
  -> angle:float
  -> unit

val draw_line : t -> width:float -> Vec.t -> Vec.t -> Color.t -> unit
