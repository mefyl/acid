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

module List_nonempty = struct
  type 'a t = ( :: ) : 'a * 'a list -> 'a t
end

module Map = struct
  module M (K : Base.Comparator.S) = struct
    include Base.Map
    include M (K)

    let empty = Base.Map.empty (module K)
  end
end
