(*
Name: Ataias Pereira Reis & ID: 260590875
Name: Ahmad Saif & ID: 260329527

"We certify that both partners contributed equally to the work
submitted here and that it represents solely our own efforts"*)

module Change = 
struct

exception TODO

let rec change coins amt sc fc = 
if amt = 0 then sc []
else
    match coins with
	| [] -> fc()
	| hd::tl -> 
		if (hd > amt) then  change tl amt sc fc
		else 
                    try
		    change (hd::tl) (amt-hd) (fun r -> sc(hd::r)) fc
                    with _ -> change (tl) (amt) sc fc;;  (* I used wild_card to catch the unknown exn *)

(* if you write the function change directly, you do not
   need to implement change'. It is only if you want to
   develop the program incrementally, first only dealing with 
   the success continuation and leaving the backtracking to
   the exception handler *)

exception NoChange

(* SUCCESS Continuation *)
let rec change' coins amt sc = raise TODO 


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


TEST CASE:

   # Change.give_change [3;2] 17;;
   Return coins: 3, 3, 3, 3, 3, 2
   # give_change [2;3] 1;;
   Sorry, I cannot give change
   - : unit = ()



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




Change using EXCEPTIONS:

   exception ChangeException;;

   let rec change_exp coins amt = 
   if amt = 0 then []
   else
	match coins with
	| [] -> raise ChangeException
	| hd::tl -> 
		if hd > amt then change_exp tl amt
		else 
			try
			  hd :: change_exp (hd::tl) (amt-hd)
			with ChangeException ->
			  change_exp (tl) (amt);;


*)
