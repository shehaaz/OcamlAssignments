#use "stream.ml";;
#use "series.ml";;
open Stream
open Series

take 20 hamming_series;;
(*
1 2 3 4 5 6 8 9 10 12 15 16 18 20 24 25 27 30 32 36 40 45 
48 50 54 60 64 72 75 80 81 90 96 100 108 120 125 128 135 
144 150 160 162 180 192 200 216 225 240 243 250 256 270 
288 300 320 324 360 375 384 400 405
*)

(*
This is how the TA showed to us, after we finished
let rec ham = {
  hd = 1;
  tl = Susp (fun () -> merge (merge ( map (fun r -> 2*r) ham) (map (fun r -> 3*r) ham)) (map (fun r->5*r) ham))}
*)
