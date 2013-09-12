(*let average l = 
match l with 
  |[] -> 0
  | _::_ -> (sumlist l) / List.length l;;


let rec sumlist l =
match l with
  |[] -> 0
  | x::xs -> x + sumlist(xs);;*)

let plus = fun x y -> x +. y;;
let average list =
   List.fold_left plus 0. list /. float (List.length list);;

(*List.fold_left ( +. ) 0. l /. float (List.length l);;*)



(*let average lst = 
  	match lst with 
  		[] -> []
  	| head :: tail -> List.fold_left (fun acc x -> acc + x) 0 lst

let length = List.length list;;
let float_length = float_of_int length;;*)

(*let rec sort lst = 
  	match lst with 
  		[] -> []
  	| head :: tail -> insert head (sort tail)
  	and insert elt lst = 
  		match lst with 
  			[] -> [elt]
  		| head :: tail -> if elt <= head then elt :: lst else head :: insert elt tail;*)
