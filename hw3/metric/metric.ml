(* Using modules for working with different metrics *)

module type METRIC = 
sig 
  type t 
  val unit : t 
  val plus : t -> t -> t 
  val prod : t -> t -> t 
  val toString : t -> string
  val toFloat  : t -> float
  val fromFloat : float -> t
end;;

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.1 *)
(* Define a module Float which provides an implementation of 
   the signature METRIC; 

   We then want use the module Float to create different representations
   for Meter, KM, Feet, Miles, Celsius, and Fahrenheit, Hour 
*)
module Float=
struct
  type t = float
  let unit = 1.0
  let plus x y = x +. y
  let prod x y = x *. y
  let toString x = string_of_float x
  let toFloat x = x
  let fromFloat x = x
end

module Meter = (Float : METRIC);;
module KM = (Float : METRIC);;
module Feet = (Float : METRIC);;
module Miles = (Float : METRIC);;
module Celsius = (Float : METRIC);;
module Fahrenheit = (Float : METRIC);;
module Hour = (Float : METRIC);;

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)



(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.2 *)
(* Define a functor Speed which implements the module type SPEED. We 
   want to be able to compute the speed km per hour as well as 
   miles per hour. 

   The functor Speed must therefore be parameterized.
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

module type SPEED = 
sig
  type s
  type distance 
  val speed :  distance -> Hour.t -> s 
  val average : s list -> s 
end;;

module Speed (M : METRIC) : SPEED with type distance = M.t=
struct
  type s = float
  type distance = M.t
  exception EmptyList
  let speed d t = let spd = (M.toFloat d) /. (Hour.toFloat t) in 
      let _ = print_string(string_of_float(spd) ^ "\n") (*Print result...*)
      in spd
  let average slist = 
    if slist = [] then raise EmptyList
    else let rec sumL list acc= match list with
      | [] -> acc
      | h::t -> let (x,y) = acc in sumL t (x+.h, y +. 1.0)
    in let (sum, n) = sumL slist (0.0, 0.0)
    in sum /. n
end

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.3 *)
(* Show how to use the functor Speed to obtain an implementations
   for computing miles per hour in the module MilesPerHour and
   and implementation computing kilometers per hour in the module
   KMPerHour
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
module MilesPerHour = Speed (Miles)
module KMPerHour = Speed (KM)
MilesPerHour.speed (Miles.fromFloat 2.0) (Hour.fromFloat 1.0);;
KMPerHour.speed (KM.fromFloat 2.0) (Hour.fromFloat 1.0);;

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.4 *)
(* It is useful to convert between different metrics.

   Define a module type CONVERSION which specifies the following
   conversion functions:
   - feet2meter          meter = feet * 0.3048
   - fahrenheit2celsius  celsius = (fahrenheit - 32) / 1.8
   - miles2KM            km = miles * 1.60934
   - MilesPerHour2KMPerHour 

   Then implement a module which provides these conversion functions.
*)
module type CONVERSION = 
sig
  type feet
  type meter
  type fahrenheit
  type celsius
  type miles
  type km
  type hour
  type milesPerHour
  type kmPerHour
  val feet2meter : feet -> meter
  val fahrenheit2celsius : fahrenheit -> celsius
  val miles2KM : miles -> km
  val milesPerHour2KMPerHour : milesPerHour -> kmPerHour
end

module Conversion : CONVERSION with 
  type feet = Feet.t and 
  type meter = Meter.t and
  type fahrenheit = Fahrenheit.t and
  type celsius = Celsius.t and
  type miles = Miles.t and
  type km = KM.t and
  type hour = Hour.t and
  type milesPerHour = MilesPerHour.s and
  type kmPerHour = KMPerHour.s =
struct
  type feet = Feet.t
  type meter = Meter.t
  type fahrenheit = Fahrenheit.t
  type celsius = Celsius.t
  type miles = Miles.t
  type km = KM.t
  type hour = Hour.t
  type milesPerHour = MilesPerHour.s
  type kmPerHour = KMPerHour.s
  let feet2meter (ft:feet) = Meter.fromFloat ((Feet.toFloat ft) *. 0.3048)
  let fahrenheit2celsius (fah:fahrenheit) = Celsius.fromFloat (((Fahrenheit.toFloat fah) -. 32.0) /. 1.8)
  let miles2KM (mil:miles) = KM.fromFloat ((Miles.toFloat mil) *. 1.60934)
  (*
This function is not working the way it should!
I don't know how to implement it as the signature SPEED doesn't provide a way to convert
from a speed value to a float
The example is just here so that it typechecks
*)
  let milesPerHour2KMPerHour (mph:milesPerHour) = KMPerHour.speed (KM.fromFloat 2.0) (Hour.fromFloat 1.0);;
end
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

