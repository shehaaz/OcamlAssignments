(*
Name: Ataias Pereira Reis & ID: 260590875
Name: Ahmad Saif & ID: 260329527

"We certify that both partners contributed equally to the work
submitted here and that it represents solely our own efforts"*)


(* unify: typ * typ -> unit 

   unify(T1, T2) = () 
   
   succeeds if T1 and T2 are unifiable, fails otherwise.

   Side Effect: Type variables in T1 and T2 will have been
    updated, s.t. if T1 and T2 are unifiable AFTER unification
    they will denote the "same" type.
*)

open Type
module M = Minml

exception Error of string
exception Unimplemented

let freshVar () = TVar (ref None)

let rec occurs s t = match s, t with
  | _, Int -> false
  | _, Bool -> false
  | _, Arrow (t1, t2) ->
      (occurs s t1) || (occurs s t2)
  | _, Product ts ->
      List.exists (occurs s) ts
  | _, TVar r ->
   match !r with
    | None -> (s == r)
    | Some t' -> (s == r) || (occurs s t')
(* Question 4. *)
let rec unify s t = match s, t with
  |Bool,Bool -> ()
  |Int,Int -> ()
  | TVar(s0), TVar(t0) -> if s0 = t0 then () else (if !s0 = None then s0 := !t0 else (if !t0 = None then t0 := !s0 else raise (Error "TVar not compatible")))
  | Arrow(s1, s2), Arrow(t1, t2) -> unify s1 t1; unify s2 t2
  | y, TVar(x) 
  | TVar(x), y -> if occurs x y then raise (Error "Variable occurs inside the other") else (if !x = None then x := (Some y) else (if !x = (Some y) then () else raise (Error "Doesn't match")))
  | Product(hd1::tl1), Product(hd2::tl2) -> unify hd1 hd2; if tl1 != [] && tl2 != [] then unify (Product(tl1)) (Product(tl2)) else (if tl1!=tl2 then raise (Error "Problem with tuples.") else ())
  | _, _ -> raise (Error "Does not match a valid case in unify!")

let unifiable (t, t') = 
  try
    let _ = unify t t' in true
  with Error s -> false
