(*
Name: Ataias Pereira Reis & ID: 260590875
Name: Ahmad Saif & ID: 260329527

"We certify that both partners contributed equally to the work
submitted here and that it represents solely our own efforts"*)
(* Task 3.1 *)

module MemoedFibo (D : DICT with type Key.t = int) : FIBO =
struct
  let dictionary = ref D.empty
  let _ = dictionary := D.insert (!dictionary) (0, Big_int.big_int_of_int 0)
  let _ = dictionary := D.insert (!dictionary) (1, Big_int.big_int_of_int 1)

  let rec fib n =
    let x = D.lookup (!dictionary) n in 
        match x with 
        | None -> let f = Big_int.add_big_int (fib (n-2)) (fib (n-1)) in let _ = (dictionary := D.insert (!dictionary) (n, f)) in f
	| Some x -> x
end

module MF = MemoedFibo (ID)
(*ID is the module to deal with the dictionary*)

(* Task 3.3 *)
module type MEMOIZER =
sig
  (* used to store the mapping *)
  type key 

  (* given a function, returns a  memoized version of that function. *)
  val memo : ((key -> 'a) -> (key -> 'a)) -> (key -> 'a)
end

module Memoize (D: DICT) : (MEMOIZER with type key = D.Key.t) =
struct

  type key = D.Key.t

  exception NotImplemented 
  
  let rec memo f = 
    let dic = ref D.empty in
    let rec memoi = (fun k -> let x = D.lookup (!dic) k in match x with 
    |None -> let v = f memoi k in let _ = (dic := D.insert (!dic) (k, v)) in v
    |Some y -> y) in memoi

end


module AutoMemoedFibo : FIBO =
struct

  module IntMemo = Memoize (ID) 

  let rec fib (f:IntMemo.key -> Big_int.big_int) (n:IntMemo.key) = match n with    
    | 0  -> Big_int.big_int_of_int 0 
    | 1  -> Big_int.big_int_of_int 1
    | n  -> Big_int.add_big_int  (f (n - 1))  (f (n - 2))

  let fib = IntMemo.memo fib
end

module AMF = (AutoMemoedFibo : FIBO)

