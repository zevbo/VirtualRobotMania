open! Core_kernel
open Geo

module type S = sig
  type t

  (** Starts up the display, with the provided physical (i.e., screen) and
      logical dimentions. *)
  val init : physical:int * int -> logical:int * int -> title:string -> t

  module Image : sig
    type display := t
    type t

    val pixel : display -> Color.t -> t
    val destroy : t -> unit
    val size : t -> int * int

    (* TODO: replace these with more portable interfaces *)

    val of_bmp_file : display -> string -> t
    val of_file : display -> filename:string -> t Async_kernel.Deferred.t

    val of_contents
      :  display
      -> contents:string
      -> format:string
           (** The extension that indicates the format of the data, e.g., "jpg"
               or "gif" *)
      -> t Async_kernel.Deferred.t
  end

  (** Take whatever has been drawn, and present that to the user *)
  val present : t -> unit

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

  (** destroy the renderer and the window, and quit SDL *)
  val shutdown : t -> unit

  (** Exit the display if someone has asked you to. *)
  val maybe_exit : t -> unit

  val delay_ms : int -> unit
end
