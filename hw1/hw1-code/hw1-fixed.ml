(*
   Purpose: dble the number n
            assumes n >= 0

   Examples:
   dble 0 ==> 0
   dble 3 ==> 6

 
*)

(*
Should be "match n with"
synthax error the arrows were wrong
added parameter n of type int
made the function recursive by added let rec
*)
let rec dble (n : int) = match n with 
  | 0 -> 0
  | _ -> 2 + (dble (n - 1))


(*
   Purpose: compute n! = n * (n-1) * (n-2) * ... * 1
            assumes n >= 0

   Examples:
   fact 0 ==> 1
   fact 5 ==> 120

   fact : int -> int
*)

(*
Added the line before the pattern matchs
made 1.0 an int
changed factorial to fact
*)
let rec fact (n : int)  = match n with 
  |0 -> 1
  |_ -> n * (fact (n - 1))


