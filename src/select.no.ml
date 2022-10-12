module Either = struct end

module type MODE = sig
  type 'a t
end

module type SWITCH = sig
  type ('r, 'w) t
end

module R = struct end
module W = struct end
module Switch_r = struct end
module Switch_w = struct end

module type SPLIT = sig
  type ('l, 'r) t
end

module Split = struct end
module Int = struct end
module String = struct end
module List_nonempty = Select.List_nonempty

module Map = struct
  module type KEY = Base.Comparator.S

  module M (K : KEY) = struct end
end
