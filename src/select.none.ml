module type S = sig
  type 'a t
end

module type SWITCH = sig
  type ('r, 'w) t
end

module R = struct end

module W = struct end

module Switch_r = struct end

module Switch_w = struct end
