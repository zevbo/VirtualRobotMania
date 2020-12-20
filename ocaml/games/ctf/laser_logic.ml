open Virtuality2d
open Geo

let laser (bot : Body.t) =
  let half_length = Vec.create (Ctf_consts.Bots.width /. 2.) 0. in
  let pos = Vec.add bot.pos (Vec.rotate half_length bot.angle) in
  let angle = bot.angle in
  let v = Vec.scale (Vec.unit_vec angle) Ctf_consts.Laser.v in
  let m = 0.01 in
  Body.create
    ~pos
    ~m
    ~v
    ~angle
    ~max_omega:0.
    ~collision_group:Ctf_consts.Laser.coll_group
    ~black_list:Ctf_consts.Laser.black_list
    Ctf_consts.Laser.shape

let gen_updater () =
  let updater (laser : Body.t) _world =
    { laser with
      v = Vec.scale (Vec.to_unit laser.v) Ctf_consts.Laser.v
    ; angle = Vec.angle_of laser.v
    }
  in
  updater
