open! Base
open! Stdio

exception Exit

let () =
  Graphics.open_graph "";
  Graphics.resize_window 600 600;
  Graphics.set_window_title "Testing, 1,2,3";
  Graphics.auto_synchronize false;
  try
    for i = 0 to 1000 do
      Graphics.clear_graph ();
      if Graphics.key_pressed () then raise Exit;
      Unix.sleepf 0.01;
      let offset = Float.of_int i /. 0.1 |> Float.to_int in
      printf "offset: %d\n%!" offset;
      Graphics.fill_poly [| 0 + offset, 0 + offset; 100, 400; 400, 100 |];
      Graphics.synchronize ()
    done
  with
  | Exit -> ()
