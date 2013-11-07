module Series= 
struct

  open Stream 

(* stream of ones *)
  let rec ones = {hd = 1 ; tl = Susp (fun () -> ones)} ;;

(* series of natural numbers starting from n *)
let rec numsFrom n = 
  {hd = n ; 
   tl = Susp (fun () -> numsFrom (n+1))}

(* series of natural numbers starting from 0 *)
  let nats = numsFrom 0 

(* ------------------------------------------------------- *)
(* Let "fibs()" represent the infinite sequence of Fibonacci numbers. Then,
   schematically, we can write:

      fibs() = 0 1 add(fibs(), tl(fibs()))

   It is almost what we can write in OCaml using observations.

Construct a stream of the fibonacci numbers -

ROUGHLY
  a      b        Fib stream
  0...   1...     0, ...
  1...   1...     0, 1 ...
  1...   2...     0, 1, 1, ...
  2...   3...     0, 1, 1, 2, ....
  3...   5...     0, 1, 1, 2, 3, ...
  5...   8...     0, 1, 1, 2, 3, 5, ...
  8...  13...     0, 1, 1, 2, 3, 5, 8 ...

*)

let rec fibs = 
{hd = 0 ; 
  tl = Susp (fun () -> fibs') }
 and fibs' = 
{hd = 1 ;
 tl = Susp (fun () -> add fibs fibs')
}

let fibonacci_series = fibs 

(* Hamming series *) 
let rec sequenceOfPowers n k= {
  hd = 1; 
  tl = Susp (fun () -> {hd = n; tl = Susp (fun () -> force (sequenceOfPowers (n*k) k).tl)})}

let rec multiplySequences seq1 seq2 = {
  hd = seq1.hd*seq2.hd;
  tl = Susp (fun () -> merge (multiplySequences seq1 (force (seq2.tl))) (multiplySequences (force (seq1.tl)) seq2))}
let rec hamming_series = 
  multiplySequences (sequenceOfPowers 5 5) (multiplySequences (sequenceOfPowers 2 2) (sequenceOfPowers 3 3))
end;;
