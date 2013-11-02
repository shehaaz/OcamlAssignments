(*
Name: Ataias Pereira Reis & ID: 260590875
Name: Ahmad Saif & ID: 260329527

"We certify that both partners contributed equally to the work
submitted here and that it represents solely our own efforts"*)

module type FIBO =
sig
  (* on input n, computes the nth Fibonacci number *)
  val fib : int -> Big_int.big_int
end

module Fibo : FIBO = 
struct
  let rec fib n = match n with
    | 0 -> Big_int.big_int_of_int 0  
    | 1 -> Big_int.big_int_of_int 1 
    | _ -> Big_int.add_big_int (fib(n-2)) (fib(n-1))
end

(*
Show the value
Big_int.string_of_big_int (Fibo.fib(5));;
*)
