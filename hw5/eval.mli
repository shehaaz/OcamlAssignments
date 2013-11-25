exception Stuck of string

  (*Those between comments are just to test those functions, after you can erase them from here*)
  val union : 'a list * 'a list -> 'a list
  val unionList : 'a list list -> 'a list
  (* ----------------------------------------------------------------------------------------- *)
  val freeVariables : Minml.exp -> string list

  val unusedVariables : Minml.exp -> string list

  val subst : Minml.exp * Minml.name -> Minml.exp -> Minml.exp
    
  (* big-step evaluation; raises Stuck if evaluation is not possible *)
  val eval : Minml.exp -> Minml.exp

  (* small-step evaluation; raises Stuck if evaluation is not possible *)
  val smallstep : Minml.exp -> Minml.exp
 
  val verbose : int ref   (* 0 for no debugging printing, 1 for printing in eval, 2 for eval and subst *)
