open Base

module type S = sig
  module First : sig
    include Comparable.S
    include Printable.S with type t := t
  end

  module Second : sig
    include Comparable.S
    include Printable.S with type t := t
  end

  type t

  include Comparable.S with type t := t
  include Printable.S with type t := t
end
