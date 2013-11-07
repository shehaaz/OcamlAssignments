module type STREAM = 
sig
  exception TODO
  type 'a susp = Susp of (unit -> 'a)
  val delay : (unit -> 'a) -> 'a susp 
  val force : 'a susp -> 'a 

  type 'a str = { hd : 'a; tl : 'a str susp; }

  val take  : int -> 'a str -> 'a list 
  val map   : ('a -> 'b) -> 'a str -> 'b str 
  val filter: ('a -> bool) -> 'a str -> 'a str 
  val add   : int str -> int str -> int str 
  val merge : 'a str -> 'a str -> 'a str 
end;;

module Stream : STREAM = 
struct

  exception TODO

  (* Suspended computation : we can suspend computation
     by wrapping it in a closure. *)
  type 'a susp = Susp of (unit -> 'a)

  (* delay *)
  let delay f = Susp f

  (* force: *)
  let force (Susp f) = f ()

  type 'a str = {hd: 'a  ; tl : ('a str) susp} 

 
  let rec map f s = 
    { hd = f (s.hd) ; 
      tl = Susp (fun () -> map f (force s.tl))
    }

  (* Inspect a stream up to n elements *)
  let rec take n s = match n with 
    | 0 -> []
    | n -> s.hd :: take (n-1) (force s.tl)


  let rec filter p s = 
    let h,t = find_hd p s in 
    {hd = h;
     tl = Susp (fun () -> filter p (force t))
    }
  and find_hd p s = 
    if  p (s.hd) then (s.hd, s.tl)
    else find_hd p (force s.tl)
      
(* Note: find_hd is NOT productive! Hence, filter is not productive.
*)

  let rec add s1 s2 = 
    {hd = s1.hd + s2.hd ; 
     tl = Susp (fun () -> add (force s1.tl) (force s2.tl)) 
    }

      
  let rec merge s1 s2 = 
    let smallerHead = if s1.hd > s2.hd then s2.hd else s1.hd in
    let p r = smallerHead < r in
    { hd = smallerHead;
      tl = Susp (fun () -> merge (filter p s1) (filter p s2))
    } 


  end ;;

let rec numsFrom n k=
{ hd = n; tl = Susp (fun () -> numsFrom (n+k) k)}

let stream1 = numsFrom 0 1;;
let stream2 = numsFrom 1 2;;
take 5 stream1;;
take 5 stream2;;
take 10 (merge stream1 stream2);;
