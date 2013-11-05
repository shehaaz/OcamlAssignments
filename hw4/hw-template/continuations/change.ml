module Change = 
struct

exception TODO

let rec change coins amt sc fc = raise TODO

(* if you write the function change directly, you do not
   need to implement change'. It is only if you want to
   develop the program incrementally, first only dealing with 
   the success continuation and leaving the backtracking to
   the exception handler *)

exception NoChange

(* SUCCESS Continuation *)
let rec change' coins amt sc  = 
if amt = 0 then sc []
else
    match coins with
	| [] -> sc []
	| hd::tl -> 
		if (hd > amt) then  change' tl amt sc
		else 
		    change' (hd::tl) (amt-hd) (fun r -> sc(hd::r));;

let listToString l = match l with 
  | [] -> ""
  | l -> 
    let rec toString l = match l with 
      | [h]  -> string_of_int h
      | h::t -> string_of_int h ^ ", " ^ toString t
    in
      toString l

let give_change coins amt =
  begin try 
    let c = change coins amt (fun r -> r) (fun () -> raise NoChange) in
      print_string ("Return coins: " ^ listToString c ^ "\n")
    with NoChange -> print_string ("Sorry, I cannot give change\n")
  end 


end;;

(* 

Change using Continuations: ONLY SUCCESS CONTINUATION

let rec aux_change_cont coins amt cont = 
if amt = 0 then cont []
else
	match coins with
	| [] -> cont []
	| hd::tl -> 
		if (hd > amt) then aux_change_cont tl amt cont
		else 
		  aux_change_cont (hd::tl) (amt-hd) (fun r -> cont(hd::r));;
			

let rec change_cont coins amt =  aux_change_cont coins amt (fun r -> r);;


*)
