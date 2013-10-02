(* HOMEWORK 2 : COMP 302 Fall 2013 
  
   NOTE:  

   All code files must be submitted electronically
   before class on Oct 3.

  The submitted file name must be hw2.ml 

  Your program must type-check using OCaml.

*)

exception NotImplemented

(* -------------------------------------------------------------*)
(* QUESTION 2 :  Warm-up [10 points]                            *) 
(* -------------------------------------------------------------*)
(* Given a function $f$ from reals to reals and a positive integer
 $n$ where $n > 0$), we want to define {\tt{repeated}} as a function
 that returns $f$  composed with itself $n$ times.  

 Stage your function properly such that it generates code which will
 apply the function $f$ to a given input $n$ times.  

*)

(* repeated: int -> ('a -> 'a) -> 'a -> 'a *)

let rec repeated n f = 
if(n>0) then
   fun x -> 
     let rec tail(n,acc) = match n with
       |0 -> acc
       |y -> tail(y-1,f acc)
     in tail(n-1,f x)
else fun x -> f 0;;

(*
Test cases:

#let t8 = repeated 3 (fun x -> x*2);;
# t8 2;;
- : int = 16

#let square x = x*x;;
# let sqr = repeated 2 square;;
val sqr : int -> int = <fun>
# sqr 2;;
- : int = 16
# sqr 3;;
- : int = 81

*)

(* -----------------------------------------------------------------------------*)
(* QUESTION 3: Maximum Likelihood                                               *)
(* -----------------------------------------------------------------------------*)

let  fact n = 
  let rec factorial n = if n = 0 then 1 
    else  n * factorial (n-1)
  in
  if n <= 0 then 1 else factorial n

let binom (n, k) = 
  if n < k then 0.0
  else float (fact n) /. (float (fact k) *. float (fact (n - k)))

let simple_dist n = (n *. (n -. 1.0) *. (10.0 -. n)) /. 240.0

(* X = BlackMarbelsDrawn *)
let dist_black n x (marbelsTotal, marbelsDrawn) = 
  (binom (n, x) *. binom (marbelsTotal - n, marbelsDrawn - x)) 
  /. (binom (marbelsTotal, marbelsDrawn))

(* -----------------------------------------------------------------------------*)
(* Q3.1 : Compute the distribution table.                                       *)
(* -----------------------------------------------------------------------------*)
let rec tabulate f n = 
  let rec tab n acc = 
    if n = 0 then (f 0)::acc
    else tab (n-1) ((f n)::acc)
  in
  tab n []


let dist_table (marbelsTotal, marbelsDrawn) x =
 tabulate (fun n->(dist_black n x (marbelsTotal, marbelsDrawn))) marbelsTotal;;

(* -----------------------------------------------------------------------------*)
(* Compute the maximum of the dist_table. The maximum corresponds to the number *)
(* of black marbels which is most likely to be in an urn *)


let max_in_list l = 
  let rec max_in_list' pos l = match l with 
    | [h]  -> (pos, h)
    | h::t -> 
      let (q, mx) = max_in_list' (pos+1) t in 
	if h < mx then (q,mx)
	else (pos, h) 
  in 
  let (pos, _) = max_in_list' 0 l in 
  pos

(* -----------------------------------------------------------------------------*)
(* Q 3.2: Compute the distribution matrix                                       *)
(* -----------------------------------------------------------------------------*)
let rec dist_matrix (total, drawn) resultList = 
  let aRow h = dist_table (total, drawn) h in
    match resultList with
    | [] -> []
    | h::t -> if t!=[] then [aRow h] @ (dist_matrix (total, drawn) t)
            else [aRow h];;


(* -----------------------------------------------------------------------------*)
(* Q 3.3: Test whether the matrix is empty                                      *)
(* -----------------------------------------------------------------------------*)

let emptyMatrix matrix = let flattenM = List.flatten matrix in
  if List.length flattenM = 0 then true else false;;

(* -----------------------------------------------------------------------------*)
(* Q 3.4: Compute the combined distribution table                               *)
(* -----------------------------------------------------------------------------*)


let combined_dist_table matrix = 
  let sum2lists list1 list2 = 
    if list2 != [] then List.map2 (fun x -> fun y -> x *. y) list1 list2 
    else list1 in
      let rec sumManyLists matrix = match matrix with
      | [] -> []
      | h::t -> sum2lists h (sumManyLists t) in
    sumManyLists matrix;;

(* -----------------------------------------------------------------------------*)
(* Maximum Likelihood                                                           *)
let max_likelihood (total, drawn)  resultList = 
  max_in_list 
   (combined_dist_table  (dist_matrix (total, drawn) resultList))


(*

Example: 

Combined distribution table for Total = 10, Drawn = 3, 
and ResultList = [2,0]

[0. ; 0. ; 0.0311111111111111102 ; 
 0.0510416666666666657; 0.0499999999999999958;
 0.0347222222222222238; 0.0166666666666666664; 0.004375; 
 0.; 0.; 0.]

The maximum in this list is at position 3 (if the first element of the list is at position 0). Hence, it is most likely that there are 3 black marbels in the urn. 

*)

(* -------------------------------------------------------------*)
(* QUESTION 4 :  Tries                                          *) 
(* -------------------------------------------------------------*)

(* Dictonary *)
(* Implement a trie to look up strings in  a dictionary *)

(* A trie is an n-ary tree *)

type 'a trie = Node of 'a * ('a trie) list | Empty

(* -------------------------------------------------------------*)
(* QUESTION 4.1 : string manipulation  [10 points]              *) 
(* -------------------------------------------------------------*)

(* string_explode : string -> char list *)
let string_explode s = 
  tabulate (fun n -> String.get s n) (String.length s - 1);;


(* string_implode : char list -> string *)
let rec string_implode l = match l with
  |[] -> ""
  |hd::tl -> Char.escaped hd ^ string_implode tl;;
       

(* -------------------------------------------------------------*)
(* QUESTION 4.2 : Insert a string into a trie  [15 points]      *) 
(* -------------------------------------------------------------*)


let rec returnCharFirstElement trieList char acc = match trieList with
      |[] -> acc
      |Empty::tl -> returnCharFirstElement tl char (Empty::acc)
      |Node(x,y)::tl -> if x = char then Node(x,y)::(returnCharFirstElement tl char acc) 
	                      else returnCharFirstElement tl char (Node(x,y)::acc);;

let rec checkExists char list = match list with 
  |[] |Empty::_ -> false
  |Node(x,_)::tl -> if(x = char) then true else checkExists char tl;;


(* 
Do a function that takes a 'a list and returns a 'a trie list
And append that trie in "ins"
# getTrie;;
- : 'a list -> 'a trie = <fun>
*)

let rec getTrie l = match l with
| [] -> Empty
| hd::tl -> Node (hd, [getTrie tl]);;


(* Insert a word in a trie *)
(* ins: char list * (char trie) list -> (char trie) list *)

(* Duplicate inserts are allowed *)

let rec ins charList trieList = match (charList, trieList) with 
  |([], _)|(_,[]) | (_,[Empty]) -> trieList @ [getTrie charList]
  |(charHead::charTail), Empty::trieTail -> Empty::(ins charTail trieTail)
  |(charHead::charTail,Node (x, y)::nodeTail) -> 
    if(checkExists charHead ([Node (x, y)])) then
                    if (checkExists (List.hd charTail) y) then 
                      let orderedSubTree = returnCharFirstElement y (List.hd charTail) [] 
                      in [Node (x, (ins charTail [(List.hd orderedSubTree)]) @ (List.tl orderedSubTree))]
	            else [Node (x,(getTrie charTail)::y)]
    else [Node (x, y)] @ ins charList nodeTail;;

 
 
(*

TEST EXAMPLES:

let t_hello = 
[Node ('h', [Node('e', [Node ('l', [Node ('l', [Node ('o', [Empty])])])])])];;

let t = insert "help" t_hello;;

let t = insert "hollow" t;;

let t = insert "helicopter" t;;

let t = insert "monkey" t;;

let t = insert "money" t;;

*)



(* insert : string -> (char trie) list -> (char trie) list *)
let  insert s t = 
  let l = string_explode s in  (* turns a string into a char list *)    
  ins l t


(* -------------------------------------------------------------*)
(* QUESTION 4.3 : Lookup a string in a trie   [15 points]       *) 
(* -------------------------------------------------------------*)

let rec containsEmpty l = match l with
  | Empty::l -> true
  | _    ::l -> containsEmpty l
  | []       -> false

(* lkp : char list * (char trie) list -> bool *)
let rec lkp char_list trie_list = raise NotImplemented

let rec lookup s t = 
  let l = string_explode s in (* l = char list *)    
    lkp l t

(* -------------------------------------------------------------*)
(* QUESTION 4.4 : Find all string in a trie   [15 points]       *) 
(* -------------------------------------------------------------*)
(* Find all strings which share the prefix p *)
  
exception Error 

let rec findAll' char_list  trie_list = raise NotImplemented

let findAll prefix trie_list = 
  begin try
    let char_list     = string_explode prefix  in 
    let postfix_list  = findAll' char_list trie_list in 
    let postfix_words = List.map (fun p -> string_implode p) postfix_list in
      List.map (fun w -> prefix^w) postfix_words
  with
     Error -> print_string "No word with this prefix found\n" ; []
  end


(* -------------------------------------------------------------*)
(* TEST CASE                                                    *) 
(* -------------------------------------------------------------*)
(*

(*
Examples
let t1 = [Node('h', [Node('e', [Node('y', [Empty])])])];;
let t2 = [Node('h', [Node('e', [Node('y', [Empty]); Node('l', [Node('l', [Empty])])])])];;
*)

let t1 = Node('c',[Empty]);;

let t = 
 [Node
     ('b',
      [Node ('r' , [Node ('e' , [Node ('e' , [Empty])])]) ;
       Node ('e' , [Node ('d' , [Empty]) ;
		    Node ('e' , [Empty ; Node ('f', [Empty; Node ('y', [Empty])]) ;
				 Node ('r',[Empty])]) ;
		    Node ('a' , [Node ('r', [Empty; Node ('d' , [Empty])])])])])]


let t2 = Node('b', [Node('e',[Node('e',[Empty])])]);;

let t3 = Node('b', [Node('e',[Node('e',[Empty]),[Node('r',[Empty])]])]);;

let t1 = [Node('h', [Node('e', [Node('y', [Empty])])])];;
let t2 = [Node('h', [Node('e', [Node('y', [Empty]); Node('l', [Node('l', [Empty])])])])];;



let t = [Node ('b', [Node ('r' , [Node ('e' , [Node ('e' , [Empty])])]); [Node('e',[Node('d',[Empty])])];
])];;

*)











