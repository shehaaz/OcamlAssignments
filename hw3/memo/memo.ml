(*
Question 3 - Poormemoizes
This function is much slower because even though it memoizes, it is not
done for recursive functions. Functions that depend on the values of the same function
are not considered. For exemplo, if we call fib(50) and we already have computed fib(49) and fib(48), it 
won't make use of these values, but compute fib(50) in the usual way.
If it already computed fib(50), then it will return the value fast, but then fib(51) will be really slow.
If just makes a reference to the last function, and keeps it.
*)

module type POORMEMOIZER =
sig
  (* used to store the mapping *)
  type key

  (* given a function, returns a poorly memoized version of that function *)
  val memo :  (key -> 'a) -> (key -> 'a)
end;;


module PoorMemoizer (D:DICT) : (POORMEMOIZER with type key = D.Key.t) =
struct

  type key = D.Key.t

  let memo f =
    let hist : 'a D.dict ref = ref D.empty in 
    let rec f_memoed x = match  D.lookup (!hist) x with
      | Some b -> b
      | None ->
          let res = f x in 
	    (hist := D.insert (!hist) (x,res);
             res)
      in
        f_memoed

end;;

module PoorAutoMemoFibo : FIBO =
struct
  module PM = PoorMemoizer (ID)
  let fib = PM.memo Fibo.fib
end


module PMF = PoorAutoMemoFibo
