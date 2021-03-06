(* 

Team: 

  Ahmad Shehaaz Saif: 260329527
  Ataias Pereira Reis: 260590875
  
"We certify that both partners contributed equally to the work
submitted here and that it represents solely our own efforts."

  HOMEWORK 2 : COMP 302 Fall 2013 
  We are using one late day.

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

exception EmptyListError
let max_in_list l = 
  let rec max_in_list' pos l = match l with 
    | [] -> raise EmptyListError
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

(* Dictionary *)
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

(*returnCharFirstElement
takes a trie list of several elements as
[Node('a', y); Node('b', z); ...]
and also a char and an empty list to initialize the accumulator.
It returns a trie list also, but with the char given as the first element,
if it exists.
*)
let rec returnCharFirstElement trieList char acc = match trieList with
      |[] -> acc
      |Empty::tl -> returnCharFirstElement tl char (Empty::acc)
      |Node(x,y)::tl -> if x = char then Node(x,y)::(returnCharFirstElement tl char acc) 
	                      else returnCharFirstElement tl char (Node(x,y)::acc);;

(*
checkExists
Given a char list [Node('a', y); Node('b', z); ...] and a char, check if char exists
and one of the outer nodes, this is: checks 'a', 'b' and ... but do not check inner nodes as
y and z.
*)
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
let rec lkp char_list trie_list = match (char_list,trie_list) with
|([], e) -> if(containsEmpty e) then true else false 
|(_,[]) | (_,[Empty]) -> false 
| (charList, Empty::nodeTl) -> lkp charList nodeTl
| (charHd::charTl,Node (x, y)::nodeTl)-> 
              if(not(checkExists charHd ([Node (x, y)]))) then (false || lkp char_list nodeTl)
              else (true && (lkp charTl y));;

let rec lookup s t = 
  if(String.length s < 1) then false 
  else
    let l = string_explode s in (* l = char list *)    
    lkp l t

(* -------------------------------------------------------------*)
(* QUESTION 4.4 : Find all string in a trie   [15 points]       *) 
(* -------------------------------------------------------------*)
(* Find all strings which share the prefix p *)
  
(*
BUG: If the Next letter in the prefix is shared by more than two words is Fails
*)
exception Error 
exception ErrorDifferentFirstLetter
exception ErrorEmptyList
(*
mapToListOfConstantNumber
Takes a list and maps it to a list of same length with a constant value
It is meant to be used with n as an integer value. It is important to be used
in the findAllWords' function, to help creating the stack of levels.
*)
let mapToListOfConstantNumbers list n = List.map (fun x -> n) list;;

(*
Takes a list of chars and a number, the number should be less or equal the length
of the list, and it returns a list with the first n chars of the original list
letFirstNChars ['a'; 'b'; 'c';] 2 -> ['a'; 'b';]
*)
let rec letFirstNChars charList n = match (charList, n) with
  | ([], _) -> [] 
  | (hd::tl, n) -> if n > 0 then hd::(letFirstNChars tl (n-1)) else [];;

(*
Returns a char list list in which each inner list is a word of the trie list given
For this function, there must me one common letter for all the words.
*)

let rec findAllWords' trieList stack charStack acc levelStack = match (trieList, stack) with
  |([Node(x,y)], _) -> 
      let newCharStack = (charStack @ [x]) in
      let newTrieList = [List.hd y] in
      let newStack = ((List.tl y) @ stack) in
      let levelNumber = List.length newCharStack in
      let newLevelStack = if newStack != stack then (mapToListOfConstantNumbers (List.tl y) (levelNumber)) @ levelStack 
      else (mapToListOfConstantNumbers (List.tl y) 1) @ levelStack in
      findAllWords' newTrieList newStack newCharStack acc newLevelStack
  |([Empty], []) -> charStack::acc
  |([Empty], st::tl) -> findAllWords' [st] tl (letFirstNChars charStack (List.hd levelStack)) (charStack::acc) (List.tl levelStack)
  |(trieHd::trieTl, _) -> raise ErrorDifferentFirstLetter
  |([], _) -> raise ErrorEmptyList

(*Calls findAllWords' with the initial values for arguments*)
let findAllWords trieList =  findAllWords' trieList [] [] [] [];;

(*When a trie list of several Node elements is given, it applies to each the function
findAllWords
Example:
let t2 =  [Node ('e', [Node ('y', [Empty])]);
       Node ('k', [Node ('e', [Node ('y', [Empty])])])];;
findAllWords would raise an error
It is called in findAll'
*)
let rec separateWords trie_list = match trie_list with 
  |[] -> []
  |Node (x, y)::nodeTl -> (findAllWords [Node (x, y)]) @ separateWords nodeTl
  |Empty::nodeTl -> (findAllWords [Empty]) @ separateWords nodeTl;;

(*Same thing as lookup, but sends the resulting trie list to separateWords*)
let rec findAll' char_list  trie_list = match (char_list,trie_list) with
|([], t) -> separateWords t
|(_,[]) | (_,[Empty]) -> raise Error  
|(charList, Empty::nodeTl) ->  findAll' charList nodeTl
|(charHd::charTl,Node (x, y)::nodeTl)-> 
              if(not(checkExists charHd ([Node (x, y)]))) then (findAll' char_list nodeTl)
              else (findAll' charTl y);;


let findAll prefix trie_list = 
  begin try
    let char_list     = string_explode prefix  in 
    let postfix_list  = findAll' char_list trie_list in 
    let postfix_words = List.map (fun p -> string_implode p) postfix_list in
      List.map (fun w -> prefix^w) postfix_words
  with
     Error -> print_string "No word with this prefix found\n" ; []
  end;;


(* -------------------------------------------------------------*)
(* TEST CASE                                                    *) 
(* -------------------------------------------------------------*)
(*

let t = 
 [Node
     ('b',
      [Node ('r' , [Node ('e' , [Node ('e' , [Empty])])]) ;
       Node ('e' , [Node ('d' , [Empty]) ;
		    Node ('e' , [Empty ; Node ('f', [Empty; Node ('y', [Empty])]) ;
				 Node ('r',[Empty])]) ;
		    Node ('a' , [Node ('r', [Empty; Node ('d' , [Empty])])])])])]

*)
