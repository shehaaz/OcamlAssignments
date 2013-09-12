type bnum = E | Zero of bnum | One of bnum

let rec intToBin b = match b with
  |_ when b<=0 -> E
  |x -> if (x mod 2 = 1) then One (intToBin (x/2))
        else Zero (intToBin (x/2));;
