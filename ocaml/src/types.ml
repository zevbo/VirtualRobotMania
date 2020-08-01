open! Base

module type S = sig
  module Point : sig
    type t =
      { x : float
      ; y : float
      }
  end

  module type Line_like_general = sig
    type t
    type line

    val on_line : t -> Point.t -> bool
    val get_bounds : t -> Point.t list
    val to_line : t -> line
  end

  module Line : sig
    type t =
      { p1 : Point.t
      ; p2 : Point.t
      }

    include Line_like_general with type t := t and type line := t

    val on_line : t -> Point.t -> bool
    val point_dist : t -> Point.t -> float
  end

  module type Line_like = Line_like_general with type line := Line.t

  module Geo : sig
    val colinear : Point.t -> Point.t -> Point.t -> bool
  end

  module Line_segment : Line_like
  module Ray : Line_like
end

module F (M : S) = struct
  open M

  module All_bounds (L1 : Line_like) (L2 : Line_like) = struct
    let f a b =
      let a_bounds = L1.get_bounds a in
      let b_bounds = L2.get_bounds b in
      a_bounds @ b_bounds
  end

  module Line_like_polymorphic : sig
    type 'a t

    val create : (module Line_like with type t = 'a) -> 'a -> 'a t
    val get_bounds : 'a t -> Point.t list
    val on_line : 'a t -> Point.t -> bool
    val line : 'a t -> 'a
  end = struct
    type 'a t =
      { line : 'a
      ; m : (module Line_like with type t = 'a)
      }

    let create (type a) (m : (module Line_like with type t = a)) (line : a) =
      { line; m }

    let get_bounds (type a) { m = (module M : Line_like with type t = a); line }
      =
      M.get_bounds line

    let on_line (type a) { m = (module M : Line_like with type t = a); line } =
      M.on_line line

    let line t = t.line
  end

  module Line_like_packed : sig
    type t

    val create : (module Line_like with type t = 'a) -> 'a -> t
    val on_line : t -> Point.t -> bool
    val get_bounds : t -> Point.t list
  end = struct
    type t =
      | T :
          { line : 'a
          ; m : (module Line_like with type t = 'a)
          }
          -> t

    let create m line = T { m; line }
    let on_line (T { m = (module M); line }) = M.on_line line
    let get_bounds (T { m = (module M); line }) = M.get_bounds line
  end

  let all_bounds_1
      (type a b)
      (module A : Line_like with type t = a)
      (module B : Line_like with type t = b)
      (a : a)
      (b : b)
    =
    let a_bounds = A.get_bounds a in
    let b_bounds = B.get_bounds b in
    a_bounds @ b_bounds

  let all_bounds_2 a b =
    Line_like_polymorphic.get_bounds a @ Line_like_polymorphic.get_bounds b

  let use_1 a b =
    let x = all_bounds_1 (module Ray) (module Line_segment) a b in
    let y =
      all_bounds_2
        (Line_like_polymorphic.create (module Ray) a)
        (Line_like_polymorphic.create (module Line_segment) b)
    in
    x @ y
end
