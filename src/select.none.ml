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

module List_nonempty = struct
  type 'a t = ( :: ) : 'a * 'a list -> 'a t
end
