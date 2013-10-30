module  Parser : PARSER = 
struct

(* In this exercise, you implement a  parser for a
 simple context free grammar using exceptions. The grammar parses arithmetic
 expressions with +,*, and ()'s.  The n represents an integer and is a
 terminal symbol. Top-level start symbol for this grammar is E.  

E -> S;
S -> P + S | P   % P = plus sub-expressions
P -> A * P | A   % A = arithmetic expression, 
A -> n | (S)


Expressions wil be lexed into a list of tokens of type Token shown
 below. The parser's job is to translate this list into an abstract
 syntax tree, given by type Exp also shown below. 

*)

module L = Lexer

type exp = Sum of exp * exp | Prod of exp * exp | Int of int

(* Success exceptions *)
(* SumExpr (S, toklist') : 
    Indicates that we successfully parsed a list of tokens called toklist
   into an S-Expression S and a remaining list of tokens called toklist'
   toklist' is what remains from toklist after we peeled of all the tokens
   necessary to build the S-Expression S.
 *)

exception SumExpr of exp * L.token list

(* ProdExpr (S, toklist') : 
    Indicates that we successfully parsed a list of tokens called toklist
   into an P-Expression P and a remaining list of tokens called toklist'
   toklist' is what remains from toklist after we peeled of all the tokens
   necessary to build the P-Expression P.
 *)

exception ProdExpr of exp * L.token list
(* AtomicExpr (A, toklist') : 
    Indicates that we successfully parsed a list of tokens called toklist
   into an A-Expression A and a remaining list of tokens called toklist'
   toklist' is what remains from toklist after we peeled of all the tokens
   necessary to build the A-Expression A.
 *)

exception AtomicExpr of exp * L.token list

(* Indicating failure to parse a given list of tokens *)

 exception Error of string

(* Example: 
   parse [INT(9),PLUS,INT(8),TIMES,INT(7),SEMICOLON]
   ===> Sum(Int 9, Prod (Int 8, Int 7))

   Example of what the Lexer.lex outputs

# Lexer.lex "(2 + 3) * 4;";;
- : Lexer.token list =
[Lexer.LPAREN; Lexer.INT 2; Lexer.PLUS; Lexer.INT 3; Lexer.RPAREN;
 Lexer.TIMES; Lexer.INT 4; Lexer.SEMICOLON]
#

# Parser.parse "(2 + 3) * 4;";;
- : Parser.exp =
Parser.Prod (Parser.Sum (Parser.Int 2, Parser.Int 3), Parser.Int 4)
#

*)

 exception NotImplemented 

 let rec parseExp toklist = match toklist with
   | [] -> raise (Error "Expected Expression: Nothing to parse")
   | tlist ->  
    try parseSumExp tlist with 
      | NotImplemented -> raise NotImplemented
      | SumExpr (exp, [L.SEMICOLON]) -> exp
      | Error msg -> raise (Error msg)
      | _ -> raise (Error "Error: Expected Semicolon")

 and parseSumExp toklist = match toklist with
 | [] -> raise (Error "Expected Expression: Nothing to parse in parseSumExp")
 |toklist -> try parseProdExp toklist with 
             |ProdExpr(exp,tlist) -> if(List.hd tlist = L.PLUS) 
		                         Sum (exp,parseSumExp (List.tl tlist))
				     else raise (SumExpr (exp,tlist))	 
             |Error msg ->  raise (Error msg)		 

 and parseProdExp toklist = match toklist with
 | [] -> raise (Error "Expected Expression: Nothing to parse in parseProdExp")
 |toklist -> try parseAtom toklist with 
             |AtomicExpr(exp,tlist) -> if(List.hd tlist = L.TIMES) 
		                         Prod (exp,parseProdExp List.tl tlist)
				       else raise (ProdExpr (exp,tlist))	 
             |Error msg ->  raise (Error msg)
	      
 and parseAtom toklist =  match toklist with
 | [] -> raise (Error "Expected Expression: Nothing to parse in parseAtom") 
 | L.INT x::tl -> raise AtomicExpr(Int x,tl)
 | L.LPAREN::tl -> try parseSumExp(tl) 
                   with SumExpr(exp,tlist) -> if(List.hd tlist = L.RPAREN) raise AtomicExpr(exp, List.tl tlist)
 |_ -> raise (Error "Not Int x or LPAREN in parseAtom")


let parse string  = parseExp (L.lex string)

end


