open! Geo

type t =
  { shape : Shape.t
  ; mass : float
  ; ang_intertia : float
  ; pos : Vec.t
  ; v : Vec.t
  ; omega : float
  }
