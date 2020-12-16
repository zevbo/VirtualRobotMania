open Core

module type Test = sig
  val name : string
  val run : unit -> unit
end

let cmd (module M : Test) =
  ( M.name
  , Command.basic
      ~summary:M.name
      (let%map_open.Command () = return () in
       fun () -> M.run ()) )

let run (tests : (module Test) list) =
  Command.run
    (Command.group
       ~summary:"Tests of the physics simulator"
       (List.map ~f:cmd tests))

let () = run [ (module Simple); (module Long_rec); (module With_border) ]
