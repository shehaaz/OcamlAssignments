(*
Name: Ataias Pereira Reis & ID: 260590875
Name: Ahmad Saif & ID: 260329527

"We certify that both partners contributed equally to the work
submitted here and that it represents solely our own efforts"*)

module Pascal = 
struct
    open Stream;;
    open Series;;
(* ------------------------------------------------------- *)
(* Computing partial sums lazily over a stream of nats     *)

let rec psums s =
  let rec psums' s cont = {
    hd = cont (s.hd);
    tl = Susp (fun () -> psums' (force s.tl) (fun r -> cont (s.hd + r)))} in
  psums' s (fun r -> r);;


(*----------------------------------------------------------------------------*)
(* Pascal's triangle 

We want to produce a stream consisting of streams. 
The first element of the stream is (1 1 1 1 ...), i.e the stream of ones.
The i-th element of the stream is obtained by computing the partial sum
over the (i-1) element of the stream.

 (1 1  1  1 ...) ; 
 (1 2  3  4 ...) ; 
 (1 3  6 10 ...); 
 (1 4 10 20 35; 
 ...

The first element corresponds to the first diagonal in Pascal's triangle;
the second element to the second diagonal, etc.
 
*)
let rec pascal  = {
  hd = ones;
  tl = Susp (fun () -> (map psums pascal))
};;
(*
Testing:
take 5 ((force (pascal.tl)).hd);;
take 5 ((force (force (pascal.tl))).hd);;
take 5 ((force ((force (pascal.tl)).tl)).hd);;
*)

let rec getNth n s = if n = 1 then s.hd else getNth (n-1) (force s.tl);;
(*getNth 2 (((force ((force (pascal.tl)).tl)).hd));;*)

let rec row k (s: (int str) str) = if k = 1 then s.hd else row (k-1) (force s.tl);;

let rec getRow (s : (int str) str) nr acc =
  if nr = 0 then acc
  else getRow (force s.tl) (nr-1) ((getNth nr (row 1 s))::acc);;

let rec triangle (s : (int str) str) = 
  let rec triangle' (s : (int str) str) n = {
    hd = getRow s n [];
    tl = Susp (fun () -> (triangle' s (n+1)))}
  in triangle' s 1;;


(*----------------------------------------------------------------------------*)
(* To illustrate the result ... *) 
let rec map_tolist n f s = if n = 0 then  []
  else (f s.hd) :: map_tolist (n-1) f (force s.tl);;
(*
# map_tolist 5 (fun r->r) (triangle pascal);;
- : int list list = [[1]; [1; 1]; [1; 2; 1]; [1; 3; 3; 1]; [1; 4; 6; 4; 1]]
# take 5 (triangle pascal);;
- : int list list = [[1]; [1; 1]; [1; 2; 1]; [1; 3; 3; 1]; [1; 4; 6; 4; 1]]
*)
(*----------------------------------------------------------------------------*)

end;;
