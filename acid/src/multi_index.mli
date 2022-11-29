open Base
include module type of Multi_index_intf

module Index : sig
  module One (Index : INDEX) : sig
    include INDEXES with type value = Index.value

    module First (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Index.t

    module Make (Value : Comparator.S with type t = Index.value) : sig
      include module type of Make (Value)

      module First :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Index.t
    end
  end

  module Two (First : INDEX) (Second : INDEX with type value = First.value) : sig
    include INDEXES with type value = First.value

    module Make (Value : Comparator.S with type t = First.value) : sig
      include module type of Make (Value)

      module First :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = First.t

      module Second :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Second.t
    end

    module First (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = First.t

    module Second (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Second.t
  end

  module Three
      (First : INDEX)
      (Second : INDEX with type value = First.value)
      (Third : INDEX with type value = First.value) : sig
    include INDEXES with type value = First.value

    module Make (Value : Comparator.S with type t = First.value) : sig
      include module type of Make (Value)

      module First :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = First.t

      module Second :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Second.t

      module Third :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Third.t
    end

    module First (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = First.t

    module Second (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Second.t

    module Third (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Third.t
  end

  module Four
      (First : INDEX)
      (Second : INDEX with type value = First.value)
      (Third : INDEX with type value = First.value)
      (Fourth : INDEX with type value = First.value) : sig
    include INDEXES with type value = First.value

    module Make (Value : Comparator.S with type t = First.value) : sig
      include module type of Make (Value)

      module First :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = First.t

      module Second :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Second.t

      module Third :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Third.t

      module Fourth :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Fourth.t
    end

    module First (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = First.t

    module Second (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Second.t

    module Third (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Third.t

    module Fourth (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Fourth.t
  end

  module Add (Index : INDEX) (Tail : INDEXES with type value = Index.value) : sig
    include INDEXES with type t = Index.t * Tail.t and type value = Index.value

    module Make (Value : Comparator.S with type t = value) : sig
      module Head :
        BINDER with module Multi_index = Make(Value) and type index = Index.t

      module Tail :
        BINDER
          with module Multi_index = Head.Multi_index
           and type index = Tail.t Hlist.t

      include module type of Head.Multi_index
    end

    module Head (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Index.t

    module Tail (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Tail.t Hlist.t
  end
end

module Ordered (Value : Comparator.S) : sig
  include
    INDEX
      with type t = (Value.t, Value.comparator_witness) Set.t
       and type value = Value.t

  module Bind (Binder : BINDER with type index = t) : sig
    val mem : Value.t -> Binder.Multi_index.t -> bool
  end
end

module Ordered_by_unique (Value : ORDERED_BY) : sig
  include INDEX with type value = Value.value

  module Bind
      (Binder : BINDER with type Multi_index.value = value and type index = t) : sig
    val find : Value.t -> Binder.Multi_index.t -> Value.value option
    val mem : Value.t -> Binder.Multi_index.t -> bool
    val remove : Value.t -> Binder.Multi_index.t -> Binder.Multi_index.t
  end
end

module Ordered_by
    (Value : ORDERED_BY)
    (Next : INDEX with type value = Value.value) : sig
  include INDEX with type value = Value.value

  module Bind
      (Binder : BINDER with type Multi_index.value = value and type index = t) : sig
    val find : Value.t -> Binder.Multi_index.t -> Next.t option
    val mem : Value.t -> Binder.Multi_index.t -> bool
    val remove : Value.t -> Binder.Multi_index.t -> Binder.Multi_index.t
  end
end
