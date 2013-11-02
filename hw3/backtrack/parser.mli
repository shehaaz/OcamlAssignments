(*
Name: Ataias Pereira Reis & ID: 260590875
Name: Ahmad Saif & ID: 260329527

"We certify that both partners contributed equally to the work
submitted here and that it represents solely our own efforts"*)

module type PARSER = 
sig

  type exp = Sum of exp * exp | Prod of exp * exp | Int of int

  exception Error of string

  val parse : string -> exp

end 
