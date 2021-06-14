open! Core_kernel
open! Async_kernel
open Virtuality2d
module Color = Geo_graph.Color
open! Geo
module Display = Geo_graph.Display

let frame =
  Int.of_float Ctf_consts.frame_width, Int.of_float Ctf_consts.frame_height

let dt_racket = 0.1
let dt_display = 0.02
let dt_sim = 0.002
let is_int f = Float.(Float.of_int (Int.of_float f) = f)
let () = assert (is_int (dt_racket /. dt_display))
let () = assert (is_int (dt_display /. dt_sim))
let speed_constant = 0.3

let init ~log_s =
  let display =
    Display.init
      ~log_s
      ~physical:frame
      ~logical:frame
      ~title:"Virtual Robotics Arena"
  in
  let world = World.empty in
  let world =
    List.fold Border.border ~init:world ~f:(fun world border_edge ->
        fst (World.add_body world border_edge))
  in
  let offense_robot_state = Offense_bot.create () in
  let defense_robot_state = Defense_bot.create () in
  let world, offense_body_id = World.add_body world Offense_bot.body in
  let world, boost_id = World.add_body world Offense_bot.boost in
  let world, offense_shield_id = World.add_body world Offense_bot.shield in
  let defense_body = Defense_bot.defense_bot () in
  let world, defense_body_id = World.add_body world defense_body in
  let world, flag_id = World.add_body world (Flag_logic.flag defense_body) in
  let world, flag_protector_id =
    World.add_body
      world
      (Flag_logic.flag_protector (World.get_body_exn world flag_id))
  in
  let%bind state =
    State.create
      world
      (Map.empty (module World.Id))
      display
      { bot = offense_robot_state; id = offense_body_id }
      { bot = defense_robot_state; id = defense_body_id }
      flag_id
      flag_protector_id
      boost_id
      offense_shield_id
  in
  state.world <- world;
  state.invisible <- Set.add state.invisible state.offense_shield;
  return state

let _status_s sexp =
  let data =
    String.concat
      ~sep:"\n"
      [ Time.to_string_abs_trimmed ~zone:Time.Zone.utc (Time.now ())
      ; Sexp.to_string_hum sexp
      ]
  in
  Out_channel.write_all "/tmp/status.sexp" ~data

(* Changing data: state.invisible state.offense_bot.bot.lives state.world *)
let draw_end_line (state : State.t) =
  Display.draw_image_wh
    state.display
    ~w:Ctf_consts.End_line.w
    ~h:Ctf_consts.frame_height
    state.end_line
    ~center:(Vec.create Ctf_consts.End_line.x 0.)
    ~angle:0.

let get_alpha lives total_lives = 255 * lives / total_lives

let draw_flags (state : State.t) =
  for flag_num = 0 to state.offense_bot.bot.num_flags - 1 do
    let alpha =
      if flag_num = state.offense_bot.bot.num_flags - 1
      then (
        let total_lives = Ctf_consts.Bots.Offense.deaths_per_flag in
        let lives =
          total_lives - (state.offense_bot.bot.times_killed % total_lives)
        in
        get_alpha lives total_lives)
      else 255
    in
    Display.draw_image_wh
      state.display
      ~w:Ctf_consts.Flag.width
      ~h:Ctf_consts.Flag.height
      (Map.find_exn state.images state.flag)
      ~center:
        (Vec.create
           Ctf_consts.Flag.display_x
           (Ctf_consts.Flag.max_y
           -. (Float.of_int flag_num *. Ctf_consts.Flag.display_y_diff)))
      ~angle:0.
      ~alpha
  done

let display_body
    (state : State.t)
    (display_data : State.Display_data.t)
    ~key:(id : World.Id.t)
    ~data:(robot : Body.t)
  =
  match Map.find state.images id with
  | None -> ()
  | Some image ->
    if not (Set.mem display_data.invisible id)
    then (
      let w = robot.shape.bounding_box.width in
      let h = robot.shape.bounding_box.height in
      let alpha =
        if robot.collision_group = Ctf_consts.Bots.Offense.coll_group
        then
          get_alpha
            display_data.offense_bot_lives
            Ctf_consts.Bots.Offense.start_lives
        else 255
      in
      Display.draw_image_wh
        state.display
        ~w
        ~h
        ~alpha
        image
        ~center:robot.pos
        ~angle:robot.angle)

let add_display_data (state : State.t) =
  let data =
    State.Display_data.create
      state.offense_bot.bot.lives
      state.world
      state.invisible
  in
  state.past_display_data <- data :: state.past_display_data

let display_data_max_length = Int.of_float (dt_racket /. dt_display)

let display (state : State.t) =
  (match List.nth state.past_display_data (display_data_max_length - 1) with
  | None -> ()
  | Some display_data ->
    Display.clear state.display (Color.rgb 240 240 240);
    draw_end_line state;
    draw_flags state;
    Map.iteri display_data.world.bodies ~f:(display_body state display_data));
  add_display_data state;
  state.past_display_data
    <- List.take state.past_display_data display_data_max_length

let display_step (state : State.t) =
  for i = 1 to Int.of_float (dt_display /. dt_sim) do
    Advance.run state ~dt:(dt_sim *. speed_constant) i;
    state.ts <- state.ts +. dt_sim
  done;
  display state;
  let%map () =
    match state.last_step_end with
    | None -> return ()
    | Some last_step_end ->
      let now = Time.now () in
      let elapsed_ms = Time.Span.to_ms (Time.diff now last_step_end) in
      let target_delay_ms = 1000. *. dt_display in
      let time_left_ms = Float.max 0. (target_delay_ms -. elapsed_ms) in
      Clock_ns.after (Time_ns.Span.of_ms time_left_ms)
  in
  state.last_step_end <- Some (Time.now ())

let step (state : State.t) () =
  let rec helper ticks =
    if ticks = 0
    then Deferred.return ()
    else (
      let%bind () = display_step state in
      helper (ticks - 1))
  in
  let%bind () = state.display_wait in
  state.display_wait <- helper (Int.of_float (dt_racket /. dt_display));
  Deferred.return ()

let max_input = 1.
let min_input = -0.8

let set_motors (state : State.t) ((bot_name : Bot_name.t), (l_input, r_input)) =
  let make_valid input =
    if Float.(input > max_input)
    then max_input
    else if Float.(input < min_input)
    then min_input
    else input
  in
  match bot_name with
  | Offense ->
    Offense_bot.set_l_input state.offense_bot.bot (make_valid l_input);
    Offense_bot.set_r_input state.offense_bot.bot (make_valid r_input)
  | Defense ->
    Defense_bot.set_l_input state.defense_bot.bot (make_valid l_input);
    Defense_bot.set_r_input state.defense_bot.bot (make_valid r_input)

let l_input (state : State.t) ((bot_name : Bot_name.t), ()) =
  match bot_name with
  | Offense -> state.offense_bot.bot.l_input
  | Defense -> state.defense_bot.bot.l_input

let r_input (state : State.t) ((bot_name : Bot_name.t), ()) =
  match bot_name with
  | Offense -> state.offense_bot.bot.r_input
  | Defense -> state.defense_bot.bot.r_input

let usable (state : State.t) last_ts cooldown =
  Float.(last_ts +. cooldown < state.ts)

let load_laser (state : State.t) ((bot_name : Bot_name.t), ()) =
  match bot_name with
  | Offense -> ()
  | Defense ->
    let is_loaded = Option.is_some state.defense_bot.bot.loaded_laser in
    if (not is_loaded)
       && usable
            state
            state.defense_bot.bot.last_fire_ts
            Ctf_consts.Laser.cooldown
    then (
      let laser_body =
        Laser_logic.laser ~bot:(State.get_defense_bot_body state)
      in
      let laser_state = State.Laser.create state.ts in
      let world, laser_id = World.add_body state.world laser_body in
      state.world <- world;
      state.images
        <- Map.set state.images ~key:laser_id ~data:(List.nth_exn state.laser 0);
      state.lasers <- Map.set state.lasers ~key:laser_id ~data:laser_state;
      state.defense_bot.bot.loaded_laser <- Some laser_id)

let shoot_laser state ((bot_name : Bot_name.t), ()) =
  if usable state state.defense_bot.bot.last_fire_ts Ctf_consts.Laser.cooldown
  then (
    match state.defense_bot.bot.loaded_laser with
    | Some id ->
      Defense_bot.set_last_fire_ts state.defense_bot.bot state.ts;
      Laser_logic.shoot_laser state id
    | None -> load_laser state ((bot_name : Bot_name.t), ()))

let restock_laser (state : State.t) ((_bot_name : Bot_name.t), ()) =
  match state.defense_bot.bot.loaded_laser with
  | Some id -> Laser_logic.restock_laser state id
  | None -> ()

let body_of (state : State.t) (bot_name : Bot_name.t) =
  let id =
    match bot_name with
    | Offense -> state.offense_bot.id
    | Defense -> state.defense_bot.id
  in
  Map.find_exn state.world.bodies id

let opp_of (state : State.t) (bot_name : Bot_name.t) =
  body_of
    state
    (match bot_name with
    | Offense -> Defense
    | Defense -> Offense)

let angle_and_dist_to state bot_name other_pos =
  let bot = body_of state bot_name in
  ( Vec.normalize_angle (Vec.angle_between bot.pos other_pos -. bot.angle)
  , Vec.mag (Vec.sub other_pos bot.pos) )

let dist_to state bot_name other_pos =
  snd (angle_and_dist_to state bot_name other_pos)

let angle_to state bot_name other_pos =
  fst (angle_and_dist_to state bot_name other_pos)

let angle_to_opp state (bot_name, ()) =
  angle_to state bot_name (opp_of state bot_name).pos

let dist_to_opp state (bot_name, ()) =
  dist_to state bot_name (opp_of state bot_name).pos

let angle_to_flag state ((bot_name : Bot_name.t), ()) =
  angle_to state bot_name (Map.find_exn state.world.bodies state.flag).pos

let dist_to_flag state ((bot_name : Bot_name.t), ()) =
  dist_to state bot_name (Map.find_exn state.world.bodies state.flag).pos

let get_angle state ((bot_name : Bot_name.t), ()) =
  Vec.normalize_angle (body_of state bot_name).angle

let get_opp_angle state ((bot_name : Bot_name.t), ()) =
  Vec.normalize_angle (opp_of state bot_name).angle

let ts_to_ticks ts = Int.of_float (ts *. speed_constant *. dt_sim)

let just_fired (state : State.t) ((_bot_name : Bot_name.t), ()) =
  Float.O.(not (state.defense_bot.bot.last_fire_ts = 0.))
  && Float.O.(state.ts <= state.defense_bot.bot.last_fire_ts + dt_racket)

let laser_cooldown_left (state : State.t) ((_bot_name : Bot_name.t), ()) =
  ts_to_ticks
    (Float.max
       0.
       (state.defense_bot.bot.last_fire_ts
       +. Ctf_consts.Laser.cooldown
       -. state.ts))

let just_boosted (state : State.t) ((_bot_name : Bot_name.t), ()) =
  Float.O.(state.ts = state.offense_bot.bot.last_boost)

let boost_cooldown_left (state : State.t) ((_bot_name : Bot_name.t), ()) =
  ts_to_ticks
    (Float.max
       0.
       (state.offense_bot.bot.last_boost
       +. Ctf_consts.Bots.Offense.boost_cooldown
       -. state.ts))

let looking_dist (state : State.t) ((bot_name : Bot_name.t), angle) =
  let body = body_of state bot_name in
  let looking_ray =
    Line_like.ray_of_point_angle body.pos (angle +. body.angle)
  in
  let all_bodies = List.map (Map.to_alist state.world.bodies) ~f:snd in
  let all_edges =
    List.fold all_bodies ~init:[] ~f:(fun edges body ->
        List.append (Body.get_edges_w_global_pos body) edges)
  in
  let dist = Vec.dist_sq body.pos in
  let intersection_distances =
    List.filter_map all_edges ~f:(fun edge ->
        Option.map (Line_like.intersection looking_ray edge.ls) ~f:dist)
  in
  match List.min_elt intersection_distances ~compare:Float.compare with
  | Some min_dist -> min_dist -. (Ctf_consts.Bots.width /. 2.)
  | None -> -1.

let boost (state : State.t) ((bot_name : Bot_name.t), ()) =
  assert (1 > 0);
  match bot_name with
  | Defense -> ()
  | Offense ->
    if usable
         state
         state.offense_bot.bot.last_boost
         Ctf_consts.Bots.Offense.boost_cooldown
    then state.offense_bot.bot.last_boost <- state.ts

let enhance_border (state : State.t) () =
  state.last_wall_enhance <- state.ts;
  state.world
    <- Border.set_border_black_list
         state.world
         Ctf_consts.Border.enhanced_black_list

let setup_shield (state : State.t) () =
  state.offense_bot.bot.last_shield <- state.ts;
  state.invisible <- Set.remove state.invisible state.offense_shield;
  let shield = World.get_body_exn state.world state.offense_shield in
  let shield =
    Body.set_black_list shield Ctf_consts.Bots.Offense.Shield.on_black_list
  in
  state.world <- World.set_body state.world state.offense_shield shield

let num_flags (state : State.t) () = state.offense_bot.bot.num_flags

let just_returned_flag (state : State.t) () =
  Float.O.(state.offense_bot.bot.last_flag_return = state.ts)

let just_killed (state : State.t) () =
  Float.O.(
    state.offense_bot.bot.last_kill +. dt_racket +. (dt_sim /. 2.) >= state.ts)

let offense_has_flag (state : State.t) (_, _) = state.offense_bot.bot.has_flag

let next_laser_power (state : State.t) ((_bot_name : Bot_name.t), ()) =
  match state.defense_bot.bot.loaded_laser with
  | None -> 0
  | Some laser_id ->
    let laser = Map.find_exn state.lasers laser_id in
    Laser_logic.current_power state laser.loaded_ts

let lives_left (state : State.t) ((_bot_name : Bot_name.t), ()) =
  state.offense_bot.bot.lives

let get_simple_data state bot_name_unit =
  let app f = f state bot_name_unit in
  Simple_data.
    { offense_has_flag = app offense_has_flag
    ; angle_to_opp = app angle_to_opp
    ; dist_to_opp = app dist_to_opp
    ; angle_to_flag = app angle_to_flag
    ; dist_to_flag = app dist_to_flag
    ; get_angle = app get_angle
    ; get_opp_angle = app get_opp_angle
    ; just_fired = app just_fired
    ; laser_cooldown_left = app laser_cooldown_left
    ; boost_cooldown_left = app boost_cooldown_left
    ; next_laser_power = app next_laser_power
    ; lives_left = app lives_left
    ; l_input = app l_input
    ; r_input = app r_input
    }
