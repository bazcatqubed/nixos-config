# A little math utility for common operations. Don't expect any high-level
# mathematical operations nor godly optimizations expected from a typical math
# library, it's just basic high school type of shit in all aspects.
{ pkgs, lib }:

rec {
  /* Returns the absolute value of the given number.

     Type: abs :: Int -> Int

     Example:
       abs -4
       => 4

       abs (1 / 5)
       => 0.2
  */
  abs = number:
    if number < 0 then -(number) else number;

  /* Exponentiates the given base with the exponent.

     Type: pow :: Int -> Int -> Int

     Example:
       pow 2 3
       => 8

       pow 6 4
       => 1296
  */
  pow = base: exponent:
    # I'll just make this as a tail recursive function instead.
    let
      absValue = abs exponent;
      iter = product: counter: max-count:
        if counter > max-count
        then product
        else iter (product * base) (counter + 1) max-count;
      value = iter 1 1 absValue;
    in
    if exponent < 0 then (1 / value) else value;

  /* Given a number, make it grow by given amount of percentage.
     A value of 100 should make the number doubled.

     Type: grow :: Number -> Number -> Number

     Example:
       grow 4 50.0
       => 2

       grow 55.5 100
       => 111
  */
  grow = number: value:
    number + (percentage number value);

  /* Given a number, make it smaller by given amount of percentage.
     A value of 100 should zero the number.

     Type: shrink :: Number -> Number -> Number

     Example:
       shrink 4 50.0
       => 2

       shrink 55.5 100
       => 0
  */
  shrink = number: value:
    number - (percentage number value);

  /* Given a number, return its value by the given percentage.

     Type: percentage :: Number -> Number -> Number

     Example:
       percentage 4 100.0
       => 4

       percentage 5 200.0
       => 10
  */
  percentage = number: value:
    number / (100.0 / value);

  /* Given a number, round up (or down) its number to the nearest integer.

     Type: round :: Number -> Number

     Example:
       round 3.5
       => 4

       round 2.3
       => 2

       round 2.7
       => 3
  */
  round = number:
    let
      number' = builtins.floor number;
      difference = number - number';
    in
    if difference >= 0.5 then (number' + 1) else number';
}
