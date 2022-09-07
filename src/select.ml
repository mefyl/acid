module List_nonempty = struct
  type 'a t = ( :: ) : 'a * 'a list -> 'a t
end
