(* HOMEWORK 1 : COMP 302 Fall 2013 
  
   PLEASE NOTE:  

   * All code files must be submitted electronically
     BEFORE class on 19 Sep, 2013

  *  The submitted file name must be hw1.ml 

  *  Your program must type-check and run usig 
     OCaml of at least OCaml 3.11.2

  * Remove all "raise NotImplemented" with your solutions
*)

exception NotImplemented

(* ------------------------------------------------------------*)
(* QUESTION 2 : WARM-UP                                        *)
(* ------------------------------------------------------------*)
(* Q2.1: Average                                               *)
(* ------------------------------------------------------------*)
(* average: float list -> float

 The function takes a list of integers and returns
 their average as a floating point number
*)
let plus = fun x y -> x +. y;;
let average list =
   List.fold_left plus 0. list /. float (List.length list);;

(* -------------------------------------------------------------*)
(* Q2.2:  Standard Deviation                                    *) 
(* -------------------------------------------------------------*)

(* stDev: float list -> float

 The function takes a list of integers and returns their
 the standard deviation as a real number
*)


let square x = x *. x 

let diffSq (list,avg) = 
  let rec f (list,avg,acc) = match list with 
  | [] -> acc
  | head::tail -> f (tail,avg,(acc +. square(head -. avg)))
in f (list,avg,0.);; 


let stDev list = 
  match list with
  | [] -> 0.
  | head::tail -> sqrt(diffSq (list,average list) /. float(List.length list));;



(* ------------------------------------------------------------*)
(* QUESTION 3                                                  *)
(* ------------------------------------------------------------*)

(* Partial sums :

   Given a list of integers, compute the partial sums 
   i.e. the sums of all the prefixes

   psum: int list -> int list

*)
let remLast list = 
  List.rev(List.tl((List.rev list)));;

let sumList list =
  List.fold_left (fun x y -> x + y) 0 list;;

let rec psum list =
  match list with
  | [] -> []
  | head::[] -> [head]
  | head::tail ->  List.append (psum (remLast list)) [sumList list];;


(* Some test cases 
# psum [1;1;1;1;1];;
- : int list = [1; 2; 3; 4; 5]

# psum [1;2;3;4];;
- : int list = [1; 3; 6; 10]

# psum [];;
- : int list = []

# psum [9];
- : int list = [9]

*)


(* ------------------------------------------------------------*)
(* QUESTION 4 : Mobile                                         *) 
(* ------------------------------------------------------------*)

type mobile = Object of int | Wire of mobile * mobile

(* 
An object is represented by its weight (= an integer) and 
a wire is represented by the two mobiles attached to its ends 
*)


(* ------------------------------------------------------------*)
(* Q4.1: Weight                                                *)
(* ------------------------------------------------------------*)
(* val weight: mobile -> int
       weight(m) = total weight of the mobile m *)

let rec weight m = match m with
| Object o -> o
| Wire(l,r) -> weight(l) + weight(r);;

(*
Tests:

# let m1:mobile = Object 8;;
val m1 : mobile = Object 8

# weight m1;;
- : int = 8

# let m2:mobile = Wire(Object 8, Wire(Wire(Object 2, Object 2), Object 4));;
val m2 : mobile = Wire (Object 8, Wire (Wire (Object 2, Object 2), Object 4))

# weight m2;;
- : int = 16

*)

(* ------------------------------------------------------------*)
(* Q4.2: Balance                                               *)
(* ------------------------------------------------------------*)
(* val balanced : mobile -> bool 
   balanced (m) ==> true, if weight of m's left end = weight of m's
                          right end; and each of the sub-parts are also 
			  balanced.
                   false otherwise

  Note: it is not simply enough to check that two
  children have the same weight == it still could mean
  that a sub-tree is unbalanced.

*)
let rec balanced m = match m with
  |Object o -> true
  |Wire(l,r) -> if weight l = weight r then balanced l & balanced r 
                else false;; 

(*

# let m1:mobile = Object 8;;
val m1 : mobile = Object 8

# balanced m1;;
- : bool = true

# let m2:mobile = Wire(Object 8, Wire(Wire(Object 2, Object 2), Object 4));;
val m2 : mobile = Wire (Object 8, Wire (Wire (Object 2, Object 2), Object 4))

# balanced m2;;
- : bool = true

# let m3:mobile = Wire(Object 7, Wire(Wire(Object 2, Object 2), Object 4));;
val m3 : mobile = Wire (Object 7, Wire (Wire (Object 2, Object 2), Object 4))

# balanced m3;;
- : bool = false

#  let m4:mobile = Wire(Object 8, Wire(Wire(Object 1, Object 2), Object 4));;
val m4 : mobile = Wire (Object 8, Wire (Wire (Object 1, Object 2), Object 4))

# balanced m4;;
- : bool = false

*)


(* ------------------------------------------------------------*)
(* Q4.3: Reflection                                            *)
(* ------------------------------------------------------------*)
(* We can reflect a mobile about its verical axis: for an
 object, the reflection is just itself; for a wire, we swap the
 positions of the two mobiles hanging off its end. Reflection
 is applied recursively on the subparts. *)

(*   val reflect: mobile -> mobile 
   reflect(m) => a mobile that is the complete reflection of m
*)

let rec reflect m = match m with 
  |Object o -> m
  |Wire(l,r) -> Wire(reflect r, reflect l);;

(*

# let m1:mobile = Object 8;;
val m1 : mobile = Object 8

# reflect m1;;
- : mobile = Object 8


# let m2:mobile = Wire(Object 8, Object 5);;
val m2 : mobile = Wire (Object 8, Object 5)

# reflect m2;;
- : mobile = Wire (Object 5, Object 8)


# let m3:mobile = Wire(Object 8, Wire(Wire(Object 2, Object 2), Object 4));;
val m3 : mobile = Wire (Object 8, Wire (Wire (Object 2, Object 2), Object 4))

# reflect m3;;
- : mobile = Wire (Wire (Object 4, Wire (Object 2, Object 2)), Object 8)
*)

(* ------------------------------------------------------------*)
(* Q4.4 Weight of the Mobile                                   *)
(* ------------------------------------------------------------*)
(* We modify the representation of the mobile slightly and keep the
 weight information at the wire. The weight at the wire is the sum of
 the weight of each mobiles attached to it. 
*)
 
type rmobile = RObj of int | RWire of rmobile * int * rmobile

(* val rweight: rmobile -> int 
  constant time function which computes the total weight of an rmobile
  *)
let rec rweight m = match m with
  |RObj o -> o
  |RWire(_,w,_) -> w;;


(* ------------------------------------------------------------*)
(* QUESTION 5                                                  *)
(* ------------------------------------------------------------*)

(* Binary numbers *)
type bnum = E | Zero of bnum | One of bnum

(* Binary numbers are represented in REVERSE ORDER

   for example : 

    110 =  zero (one (one e)) =  6                 (no leading zero)
   0110 =  zero (one (one (zero e))) = 6           (one leading zero)
  00110 =  zero (zero (one (one (zero e)))) = 6    (two leading zero)
   0101 =  one (zero (one (zero e))) = 5           (no leading zero)

*)

(* ------------------------------------------------------------*)
(* QUESTION 5.1                                                *)
(* ------------------------------------------------------------*)

(* Write a function which converts an integer n (n >= 0)
   into a binary number with no leading zeros.
   
   intToBin : int -> bnum *)

let intToBin b =
  if(b=0) then Zero E
  else
  let rec f b = match b with
         |_ when b=0 -> E
         |x -> if (x mod 2 = 1) then One (f (x/2))
                else Zero (f (x/2))
  in f b;;

(* Some test cases

   - intToBin(5); // 101
   val it = one (zero (one e)) : bnum

   - intToBin(6);
   val it = zero (one (one e)) : bnum

   - intToBin(8);
   val it = zero (zero (zero (one e))) : bnum

   - intToBin(7);
   val it = one (one (one e)) : bnum
  
*)

(* ------------------------------------------------------------*)
(* QUESTION 5.2                                                *)
(* ------------------------------------------------------------*)

(* Write a function which converts a binary number possibly with
   leading zeros into an integer n where n >= 0.

   binToInt : bnum -> int *)

let power(n,k) = 
  let rec f (n,k,acc) = match k with 
    |0 -> acc
    |_ -> f(n,k-1,n*acc)
in f (n,k,1);;

  
let rec binToInt (b) = 
  let rec f(b,m) = match (b,m) with
    |(One x, _) -> power(2,m) + f(x,m+1)
    |(Zero z, _) -> f(z,m+1)
    |(E, _) -> 0
in 
  f(b,0);;

 

(* Some test cases :


# binToInt (One (Zero (One (Zero E))));;
- : int = 5
# binToInt (One (Zero (One (Zero (Zero E)))));;
- : int = 5
# binToInt (Zero (One (One E)));;
- : int = 6
# binToInt (Zero (One (One (Zero E))));;
- : int = 6
#  
*)


