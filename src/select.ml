module List_nonempty = struct
  type 'a t = ( :: ) : 'a * 'a list -> 'a t
end

module Map = struct
  module M (K : Base.Comparator.S) = struct
    include Base.Map
    include M (K)
  end
end
