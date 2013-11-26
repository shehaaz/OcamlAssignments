type context  (* Context of typing assumptions; example: x : int, p : bool *)
val empty : context
  
val infer : context -> Minml.exp -> Type.tp
(**)
val assoc : 'a -> ('a * 'b) list -> 'b
val lookup : context -> Minml.name -> Type.tp
val extend : context -> (Minml.name * Type.tp) -> context (*Extend a context, adds an element to it*)
val primopType : Minml.primop -> Type.tp
(**)
exception TypeError of string
