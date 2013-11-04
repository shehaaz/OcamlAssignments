module TailRec  = 
struct
  exception TODO

  let rec aux_filter f l cont = match l with 
    | [] -> cont []
    |hd::tl -> 
      if (f hd) then aux_filter f tl (fun r -> cont(hd::r))
      else aux_filter f tl (fun r -> cont(r))    
    
  let rec filter f l = aux_filter f l (fun r -> r)


(*

TEST CASE:

filter (fun x -> if(x>5) then true else false) [2;4;6;8;10];;

How to call the original List.filter:

# List.filter (fun x -> if(x>5) then true else false) [2;4;6;8;10];;
- : int list = [6; 8; 10]

Normal_filter:

  let rec normal_filter f l = match l with 
    |[] -> []
    |hd::tl -> if (f hd) then hd::normal_filter f tl
               else normal_filter f tl;;

*)

(*
foldr : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
foldr f [a1; ...; an] b is f a1 (f a2 (... (f an b) ...)). 
*)

  let rec aux_foldr f l b cont = match l with 
    |[] -> cont b
    |hd::tl -> aux_foldr f tl b (fun r -> cont(f hd r))

  let foldr f l b = aux_foldr f l b (fun r -> r)

end;;



(*

TEST CASE:

# foldr (fun x y -> x+y) [1;2;3;4;5] 5;;
- : int = 20

# foldr (fun x y -> x+y) [1;2;3;4;5] 0;;
- : int = 15

How to call list.fold_right:

# List.fold_right (fun x y -> x+y) [1;2;3;4;5] 5;;
- : int = 20

Normal_fold_right:


let rec normal_fold_right f l b = match l with
  |[] -> b
  |hd::tl -> f hd (normal_fold_right f tl b);;


*)
