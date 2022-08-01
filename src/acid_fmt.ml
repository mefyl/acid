open Base
include Fmt

let nth f i =
  let () = int f i in
  if i = 11 || i = 12 || i = 13 then string f "th"
  else if i % 10 = 1 then string f "st"
  else if i % 10 = 2 then string f "nd"
  else if i % 10 = 3 then string f "rd"
  else string f "th"
