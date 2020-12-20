open Common

let border =
  Border.generate_border
    ~energy_ret:0.3
    ~collision_group:Ctf_consts.Border.coll_group
    Ctf_consts.frame_width
    Ctf_consts.frame_height
