open Common

let border =
  Border.generate_border
    ~energy_ret:Ctf_consts.Border.energy_ret
    ~collision_group:Ctf_consts.Border.coll_group
    Ctf_consts.frame_width
    Ctf_consts.frame_height
