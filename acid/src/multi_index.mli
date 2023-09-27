open Base
include module type of Multi_index_intf

(** Set of indexes.

    Helpers are provided for sets of up to 4 indexes. Past this number, the
    [Add] functor can be chained to reach an arbitrary amount of indexes. *)
module Index : sig
  (** A set of indexes consisting of one index. *)
  module One (Index : INDEX) : sig
    include INDEXES with type value = Index.value

    module Make (Value : Comparator.S with type t = Index.value) : sig
      include module type of Make (Value)

      (** Binder to the first index. *)
      module First :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Index.t
    end

    (** Binder from the index set to the first index. *)
    module First (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Index.t
  end

  (** A set of indexes consisting of two indexes. *)
  module Two
      (First : INDEX)
      (Second : INDEX with type value = First.value) : sig
    include INDEXES with type value = First.value

    module Make (Value : Comparator.S with type t = First.value) : sig
      include module type of Make (Value)

      (** Binder to the first index. *)
      module First :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = First.t

      (** Binder to the second index. *)
      module Second :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Second.t
    end

    (** Binder from the index set to the first index. *)
    module First (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = First.t

    (** Binder from the index set to the second index. *)
    module Second (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Second.t
  end

  (** A set of indexes consisting of three indexes. *)
  module Three
      (First : INDEX)
      (Second : INDEX with type value = First.value)
      (Third : INDEX with type value = First.value) : sig
    include INDEXES with type value = First.value

    module Make (Value : Comparator.S with type t = First.value) : sig
      include module type of Make (Value)

      (** Binder to the first index. *)
      module First :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = First.t

      (** Binder to the second index. *)
      module Second :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Second.t

      (** Binder to the third index. *)
      module Third :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Third.t
    end

    (** Binder from the index set to the first index. *)
    module First (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = First.t

    (** Binder from the index set to the second index. *)
    module Second (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Second.t

    (** Binder from the index set to the third index. *)
    module Third (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Third.t
  end

  (** A set of indexes consisting of four indexes. *)
  module Four
      (First : INDEX)
      (Second : INDEX with type value = First.value)
      (Third : INDEX with type value = First.value)
      (Fourth : INDEX with type value = First.value) : sig
    include INDEXES with type value = First.value

    module Make (Value : Comparator.S with type t = First.value) : sig
      include module type of Make (Value)

      (** Binder to the first index. *)
      module First :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = First.t

      (** Binder to the second index. *)
      module Second :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Second.t

      (** Binder to the third index. *)
      module Third :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Third.t

      (** Binder to the fourth index. *)
      module Fourth :
        BINDER
          with type Multi_index.t = t
           and type Multi_index.value = value
           and type index = Fourth.t
    end

    (** Binder from the index set to the first index. *)
    module First (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = First.t

    (** Binder from the index set to the second index. *)
    module Second (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Second.t

    (** Binder from the index set to the third index. *)
    module Third (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Third.t

    (** Binder from the index set to the fourth index. *)
    module Fourth (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Fourth.t
  end

  (** A set of indexes adding an index to an other set. *)
  module Add
      (Index : INDEX)
      (Tail : INDEXES with type value = Index.value) : sig
    include INDEXES with type t = Index.t -> Tail.t and type value = Index.value

    module Make (Value : Comparator.S with type t = value) : sig
      (** Binder to the added index. *)
      module Head :
        BINDER with module Multi_index = Make(Value) and type index = Index.t

      (** Binder to the rest of the indexes. *)
      module Tail :
        BINDER
          with module Multi_index = Head.Multi_index
           and type index = Tail.t Hlist.t

      include module type of Head.Multi_index
    end

    (** Binder from the index set to the added index. *)
    module Head (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Index.t

    (** Binder from the index set to the rest of the indexes. *)
    module Tail (Binder : BINDER with type index = t Hlist.t) :
      BINDER
        with module Multi_index = Binder.Multi_index
         and type index = Tail.t Hlist.t
  end
end

(** An index that sort values with the given criteria. *)
module Ordered (Value : Comparator.S) : sig
  include
    INDEX
      with type t = (Value.t, Value.comparator_witness) Set.t
       and type value = Value.t

  module Bind (Binder : BINDER with type index = t) : sig
    val mem : Value.t -> Binder.Multi_index.t -> bool
  end
end

(** An index that sort values by a bijective property. *)
module Ordered_by_unique (Value : ORDERED_BY) : sig
  include INDEX with type value = Value.value

  module Bind
      (Binder : BINDER with type Multi_index.value = value and type index = t) : sig
    val change :
      Value.t ->
      Binder.Multi_index.t ->
      f:(Value.value option -> Value.value option) ->
      Binder.Multi_index.t

    val find : Value.t -> Binder.Multi_index.t -> Value.value option
    val mem : Value.t -> Binder.Multi_index.t -> bool
    val remove : Value.t -> Binder.Multi_index.t -> Binder.Multi_index.t

    val update :
      Value.t ->
      Binder.Multi_index.t ->
      f:(Value.value -> Value.value option) ->
      Binder.Multi_index.t
  end
end

(** An index that sort values by an injective property.

    Values mapped to the same property are further indexed by the [Next] index. *)
module Ordered_by
    (Value : ORDERED_BY)
    (Next : INDEX with type value = Value.value) : sig
  include INDEX with type value = Value.value

  module Bind
      (Binder : BINDER with type Multi_index.value = value and type index = t) : sig
    val find : Value.t -> Binder.Multi_index.t -> Next.t option
    val mem : Value.t -> Binder.Multi_index.t -> bool
    val remove : Value.t -> Binder.Multi_index.t -> Binder.Multi_index.t

    val update :
      Value.t ->
      Binder.Multi_index.t ->
      f:(Value.value -> Value.value option) ->
      Binder.Multi_index.t
  end
end
