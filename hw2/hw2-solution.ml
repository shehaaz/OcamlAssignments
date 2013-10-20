(* -------------------------------------------------------------*)
(* QUESTION 1 :  Inductive Proof [15 points]                    *) 
(*

Induction Hypothesis: size' m acc = (size m) + acc

Case: m = Obj(w)
	size Obj(w) + acc = 1 + acc
	size' Obj(w) acc = 1 + acc
	size Obj(w) + acc = size' Obj(w) acc

Case: m = Wire(m1,m2)
	size(Wire(m1,m2)) + acc = size(m1) + size(m2) + 1 + acc
	size(m1) + size(m2) + 1 + acc = size' m1 (size(m2) + 1 + acc)  by IH
	size' m1 (size(m2) + 1 + acc) = size' m1 (size' m2 (1 + acc))  by IH
	size' m1 (size' m2 (1 + acc)) = size' Wire(m1,m2) acc
	size(Wire(m1,m2)) + acc = size' Wire(m1,m2) acc
	
When acc = 0, we have size m = size' m 0.
	
*)

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
if n = 1 then f
else let fn' = repeated (n-1) f in
       fun x -> f (fn' x)


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
List.map (fun n -> dist_black n x (marbelsTotal, marbelsDrawn))
  (tabulate (fun x -> x) 10)


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
let dist_matrix (total, drawn) resultList = 
  List.map (fun x -> dist_table (total, drawn) x)  resultList 

(* -----------------------------------------------------------------------------*)
(* Q 3.3: Test whether the matrix is empty                                      *)
(* -----------------------------------------------------------------------------*)
let emptyMatrix matrix = 
List.for_all (fun l -> l = []) matrix

(* -----------------------------------------------------------------------------*)
(* Q 3.4: Compute the combined distribution table                               *)
(* -----------------------------------------------------------------------------*)


let rec combined_dist_table matrix = 
  if emptyMatrix matrix then []
  else 
    let get_heads = List.map (fun (h::t) -> h) matrix  in
    let get_tails = List.map (fun (h::t) -> t) matrix  in
    let result    = List.fold_right (fun x r -> x *. r) get_heads 1.0 in
      result :: combined_dist_table get_tails


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
  tabulate (fun n -> String.get s n) ((String.length s) - 1)

(* string_implode : char list -> string *)
let string_implode l = 
  List.fold_right (fun c s -> Char.escaped c ^ s) l ""


(* -------------------------------------------------------------*)
(* QUESTION 4.2 : Insert a string into a trie  [15 points]      *) 
(* -------------------------------------------------------------*)

(* Insert a word in a trie *)
(* ins: char list * char trie -> char trie *)

let rec unroll  l = match l with 
  | []   -> [Empty]
  | x::t -> [Node(x, unroll t)]

(* Duplicate inserts are allowed *)
let rec ins l t = match l , t with 
  | []  ,  _        -> Empty::t
  | _   , []        -> unroll l
  | _   , Empty::cs -> Empty::(ins l cs)
  | h::l, Node (a,c)::cs -> 
    if h = a then 
      Node(h, ins l c)::cs
    else
      Node (a,c) :: ins (h::l) cs

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
let rec lkp char_list trie_list = match char_list , trie_list with
  | []   , []    -> false
  | []   , _     -> containsEmpty trie_list
  | h::r , []    -> false
  | h::r , Empty :: t_list ->  lkp  char_list t_list
  | h::r , Node (c, children) :: t_list -> 
  if h = c then lkp r  children
  else lkp  char_list t_list

let rec lookup s t = 
  let l = string_explode s in (* l = char list *)    
    lkp l t

(* -------------------------------------------------------------*)
(* QUESTION 4.4 : Find all string in a trie   [15 points]       *) 
(* -------------------------------------------------------------*)
(* Find all strings which share the prefix p *)
  
exception Error 

let rec toWords trie_list = match trie_list with
  | []              -> []
  | Empty :: t_list -> [] :: toWords t_list
  | Node(a, children) :: t_list -> 
      (List.map (fun l -> a::l) (toWords children)) @ toWords t_list

let rec findAll' char_list  trie_list = match char_list , trie_list with
  | []   , []              -> raise Error
  | []   , t :: t_list     -> toWords trie_list
  | h::r , []              -> raise Error
  | h::r , Empty :: t_list -> findAll' char_list t_list 
  | h::r , Node (c, children) :: t_list -> 
    if h = c then findAll' r children 
    else findAll' char_list t_list

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

let t = 
 [Node
     ('b',
      [Node ('r' , [Node ('e' , [Node ('e' , [Empty])])]) ;
       Node ('e' , [Node ('d' , [Empty]) ;
		    Node ('e' , [Empty ; Node ('f', [Empty; Node ('y', [Empty])]) ;
				 Node ('r',[Empty])]) ;
		    Node ('a' , [Node ('r', [Empty; Node ('d' , [Empty])])])])])]
















