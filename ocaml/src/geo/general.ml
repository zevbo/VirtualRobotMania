let epsilon = 0.00001
let imp_equals ?(epsilon_ = epsilon) n1 n2 = Float.((Float.abs (n1 -. n2)) < epsilon_)