open Common
open Virtuality2d
open Geo

let border () =
  Border.generate_border
    ~energy_ret:0.3
    ~collision_group:Body_consts.Border.coll_group
    Ctf_consts.frame_width
    Ctf_consts.frame_height

let offense_bot () =
  Body.create
    ~pos:(Vec.create (-.Body_consts.Bots.x_mag) 0.)
    ~m:Body_consts.Bots.mass
    ~angle:Body_consts.Bots.start_angle
    ~collision_group:Body_consts.Bots.Offense.coll_group
    Body_consts.Bots.shape

let defense_bot () =
  Body.create
    ~pos:(Vec.create Body_consts.Bots.x_mag 0.)
    ~m:Body_consts.Bots.mass
    ~angle:(Float.pi -. Body_consts.Bots.start_angle)
    ~collision_group:Body_consts.Bots.Defense.coll_group
    Body_consts.Bots.shape

let laser (bot : Body.t) =
  let half_length = Vec.create (Body_consts.Bots.width /. 2.) 0. in
  let pos = Vec.add bot.pos half_length in
  let angle = bot.angle in
  let m = 0.01 in
  Body.create
    ~pos
    ~m
    ~angle
    ~max_omega:0.
    ~collision_group:Body_consts.Laser.coll_group
    Body_consts.Laser.shape
