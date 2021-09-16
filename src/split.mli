include module type of Split_intf

module Left : S with type ('l, 'r) t = 'l

module Right : S with type ('l, 'r) t = 'r
