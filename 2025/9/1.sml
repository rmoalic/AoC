val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

type coordinate = {X: FixedInt.int, Y: FixedInt.int}
exception ParseError;
exception Fail;

fun rate_pairs_area (a: coordinate, b: coordinate) =
    FixedInt.* (
        FixedInt.+ (FixedInt.abs (#X a - #X b), 1),
        FixedInt.+ (FixedInt.abs (#Y a - #Y b), 1))

fun make_pairs (l: 'a list): ('a * 'a) list =
    case l of
        [] => []
      | [_] => []
      | (hd :: tl) => let
          val pairs_hd = map (fn x => (hd, x)) tl
          val pairs_tl = make_pairs tl
      in
          pairs_hd @ pairs_tl
      end

fun makeRatePairList (l: 'a list) (f: (('a * 'a) -> FixedInt.int)): (('a * 'a) * FixedInt.int) list = let
    val pairs = make_pairs (l)
    val rate = map f pairs
in
    ListPair.zip (pairs, rate)
end

fun parseInputLine line: coordinate = let
    val snums = String.tokens (fn x => x = #",") line
    val nums = map (valOf o FixedInt.fromString) snums
in
    if List.length nums = 2
    then {
        X = List.nth (nums, 0),
        Y = List.nth (nums, 1)
    }
    else raise ParseError
end

fun parseInputFile file = let
    val inStream = TextIO.openIn file
    fun readLines stream  =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => if String.size line < 2
                         then []
                         else parseInputLine (stripLast line) :: readLines stream
in
    readLines inStream  before TextIO.closeIn inStream
end

val data = parseInputFile inputFile;

val d = map rate_pairs_area (make_pairs data)
val tes1 = rate_pairs_area ({X=2, Y=5}, {X=9, Y=7})  = 24
val tes2 = rate_pairs_area ({X=7, Y=3}, {X=2, Y=3})  = 6
val tes3 = rate_pairs_area ({X=2, Y=5}, {X=11, Y=1}) = 50

val part1 = List.foldl (fn (x, acc) => if FixedInt.> (x, acc) then x else acc) 0 d
val _ = print ("solution part 1: " ^ (FixedInt.toString (part1)) ^ "\n");

(*
val part2 = FixedInt.* (Int.toLarge(#X d2_a), Int.toLarge(#X d2_b))
val _ = print ("solution part 2: " ^ (FixedInt.toString (part2)) ^ "\n");
*)
