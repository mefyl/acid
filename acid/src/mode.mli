include module type of Mode_intf

module R : sig
  include S with type 'a t = 'a and type ('r, _) Switch.t = 'r
  include module type of Select_jsoo.R
end

module W : sig
  include S with type 'a t = 'a option and type (_, 'w) Switch.t = 'w
  include module type of Select_jsoo.W
end
