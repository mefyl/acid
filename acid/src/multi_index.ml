open Base
include Multi_index_intf

module Make_multi_index (Types : sig
  module Elements : Comparator.S

  type indexes

  module Indexes : sig
    val add : Elements.t -> indexes Hlist.t -> indexes Hlist.t
    val empty : indexes Hlist.t
    val remove : Elements.t -> indexes Hlist.t -> indexes Hlist.t
  end
end) =
struct
  module MI = struct
    type value = Types.Elements.t
    type indexes = Types.indexes

    module Indexes = Types.Indexes

    type t = {
      elements : (value, Types.Elements.comparator_witness) Set.t;
      indexes : Types.indexes Hlist.t;
    }

    let add value { elements; indexes } =
      {
        elements = Set.add elements value;
        indexes = Types.Indexes.add value indexes;
      }

    let all { elements; _ } = Set.to_sequence elements

    let empty =
      {
        elements = Set.empty (module Types.Elements);
        indexes = Types.Indexes.empty;
      }

    let remove value ({ elements; indexes } as t) =
      if Set.mem elements value then
        {
          elements = Set.remove elements value;
          indexes = Types.Indexes.remove value indexes;
        }
      else t
  end

  include MI

  module Bind = struct
    module Multi_index = MI

    type index = Types.indexes Hlist.t

    let get { indexes; _ } = indexes
  end
end

(** Indexes *)
module Index = struct
  module One (Index : INDEX) = struct
    type t = Index.t * unit
    type value = Index.value

    module First (Binder : BINDER with type index = t Hlist.t) = struct
      module Multi_index = Binder.Multi_index

      type index = Index.t

      let get t =
        let Hlist.[ index ] = Binder.get t in
        index
    end

    module Make_multi_index (Value : Comparator.S with type t = Index.value) =
    struct
      module Value = Value
      module Index_first = Index

      include Make_multi_index (struct
        module Elements = Value

        module Indexes = struct
          let add value Hlist.[ index ] = Hlist.[ Index_first.add value index ]
          let empty = Hlist.[ Index_first.empty ]

          let remove value Hlist.[ index ] =
            Hlist.[ Index_first.remove value index ]
        end

        type nonrec indexes = t
      end)
    end

    module Make (Value : Comparator.S with type t = Index.value) = struct
      module Multi_index = Make_multi_index (Value)
      include Multi_index

      module First = struct
        module Multi_index = Multi_index

        type index = Index.t

        let get { indexes = Hlist.[ index ]; _ } = index
      end
    end
  end

  module Add
      (Index : INDEX)
      (Indexes_tail : INDEXES with type value = Index.value) =
  struct
    type t = Index.t * Indexes_tail.t
    type value = Index.value

    module Head (Binder : BINDER with type index = t Hlist.t) = struct
      module Multi_index = Binder.Multi_index

      type index = Index.t

      let get t =
        let Hlist.(head :: _) = Binder.get t in
        head
    end

    module Tail (Binder : BINDER with type index = t Hlist.t) = struct
      module Multi_index = Binder.Multi_index

      type index = Indexes_tail.t Hlist.t

      let get t =
        let Hlist.(_ :: tail) = Binder.get t in
        tail
    end

    module Make (Value : Comparator.S with type t = value) = struct
      module Value = Value
      module Index_head = Index

      module Multi_index = Make_multi_index (struct
        module Elements = Value

        module Indexes = struct
          module Tail = Indexes_tail.Make (Value)

          let add value Hlist.(index :: indexes) =
            Hlist.(Index_head.add value index :: Tail.Indexes.add value indexes)

          let empty = Hlist.(Index_head.empty :: Tail.Indexes.empty)

          let remove value Hlist.(index :: indexes) =
            Hlist.(
              Index_head.remove value index :: Tail.Indexes.remove value indexes)
        end

        type indexes = Index.t * Indexes_tail.t
      end)

      include Multi_index

      module Bind = struct
        module Multi_index = Multi_index

        type index = indexes Hlist.t

        let get { indexes; _ } = indexes
      end

      module Head = struct
        module Multi_index = Multi_index

        type index = Index.t

        let get { indexes = Hlist.(index :: _); _ } = index
      end

      module Tail = struct
        module Multi_index = Multi_index

        type index = Indexes_tail.t Hlist.t

        let get { indexes = Hlist.(_ :: indexes); _ } = indexes
      end
    end
  end

  module Two (First : INDEX) (Second : INDEX with type value = First.value) =
  struct
    module One = One (Second)
    include Add (First) (One)

    module Make (Value : Comparator.S with type t = value) = struct
      include Make (Value)
      module First = Head
      module Second = One.First (Tail)
    end

    module First (Binder : BINDER with type index = t Hlist.t) = Head (Binder)

    module Second (Binder : BINDER with type index = t Hlist.t) =
      One.First (Tail (Binder))
  end

  module Three
      (First : INDEX)
      (Second : INDEX with type value = First.value)
      (Third : INDEX with type value = First.value) =
  struct
    module Two = Two (Second) (Third)
    include Add (First) (Two)

    module Make (Value : Comparator.S with type t = value) = struct
      include Make (Value)
      module First = Head
      module Second = Two.First (Tail)
      module Third = Two.Second (Tail)
    end

    module First (Binder : BINDER with type index = t Hlist.t) = Head (Binder)

    module Second (Binder : BINDER with type index = t Hlist.t) =
      Two.First (Tail (Binder))

    module Third (Binder : BINDER with type index = t Hlist.t) =
      Two.Second (Tail (Binder))
  end

  module Four
      (First : INDEX)
      (Second : INDEX with type value = First.value)
      (Third : INDEX with type value = First.value)
      (Fourth : INDEX with type value = First.value) =
  struct
    module Three = Three (Second) (Third) (Fourth)
    include Add (First) (Three)

    module Make (Value : Comparator.S with type t = value) = struct
      include Make (Value)
      module First = Head
      module Second = Three.First (Tail)
      module Third = Three.Second (Tail)
      module Fourth = Three.Third (Tail)
    end

    module First (Binder : BINDER with type index = t Hlist.t) = Head (Binder)

    module Second (Binder : BINDER with type index = t Hlist.t) =
      Three.First (Tail (Binder))

    module Third (Binder : BINDER with type index = t Hlist.t) =
      Three.Second (Tail (Binder))

    module Fourth (Binder : BINDER with type index = t Hlist.t) =
      Three.Third (Tail (Binder))
  end
end

module Ordered (Value : Comparator.S) = struct
  type t = (Value.t, Value.comparator_witness) Set.t
  type value = Value.t

  let add value set = Set.add set value
  let all set = Set.to_sequence set
  let empty = Set.empty (module Value)
  let is_empty = Set.is_empty

  let update old value set =
    let set = Set.remove set old in
    Set.add set value

  let remove value map = Set.remove map value

  module Bind (Binder : BINDER with type index = t) = struct
    let mem value map = Set.mem (Binder.get map) value
  end
end

module Ordered_by_unique (Value : ORDERED_BY) = struct
  type t = (Value.t, Value.value, Value.comparator_witness) Map.t
  type value = Value.value

  let add value map = Map.set map ~key:(Value.get value) ~data:value
  let all map = Map.to_sequence map |> Sequence.map ~f:snd
  let empty = Map.empty (module Value)
  let is_empty = Map.is_empty

  let update old value map =
    let map = Map.remove map (Value.get old) in
    Map.set map ~key:(Value.get value) ~data:value

  let remove value map = Map.remove map (Value.get value)

  module Bind
      (Binder : BINDER with type Multi_index.value = value and type index = t) =
  struct
    let find value map = Map.find (Binder.get map) value
    let mem value map = Map.mem (Binder.get map) value

    let remove value map =
      match Map.find (Binder.get map) value with
      | None -> map
      | Some value -> Binder.Multi_index.remove value map
  end
end

module Ordered_by
    (Value : ORDERED_BY)
    (Next : INDEX with type value = Value.value) =
struct
  type t = (Value.t, Next.t, Value.comparator_witness) Map.t
  type value = Value.value

  let add value map =
    Map.change map (Value.get value) ~f:(function
      | None -> Some (Next.add value Next.empty)
      | Some index -> Some (Next.add value index))

  let all map =
    Map.to_sequence map
    |> Sequence.map ~f:(fun (_, data) -> Next.all data)
    |> Sequence.concat

  let empty = Map.empty (module Value)
  let is_empty = Map.is_empty

  let update old value map =
    Map.change map (Value.get value) ~f:(function
      | None -> Some (Next.add value Next.empty)
      | Some index -> Some (Next.update old value index))

  let remove value map =
    Map.change map (Value.get value) ~f:(function
      | None -> None
      | Some index ->
        let index = Next.remove value index in
        if Next.is_empty index then None else Some index)

  module Bind
      (Binder : BINDER with type Multi_index.value = value and type index = t) =
  struct
    let mem value map = Map.mem (Binder.get map) value
    let find value map = Map.find (Binder.get map) value

    let remove value map =
      match Map.find (Binder.get map) value with
      | None -> map
      | Some index ->
        Next.all index
        |> Sequence.fold ~init:map ~f:(fun map elt ->
               Binder.Multi_index.remove elt map)
  end
end
