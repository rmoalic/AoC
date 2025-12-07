val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

type range = LargeInt.int * LargeInt.int;
exception ParseError;

fun inRange value (r:range) = LargeInt.>= (value, (#1 r)) andalso LargeInt.<= (value, (#2 r))

fun fpart1 (ranges, ingredients) = let
    val is_fresh = (map
                        (fn x => List.exists (inRange x) ranges)
                        ingredients)
    (*val _ = print (String.concat (map
                       (fn (i,f) => "{" ^ (LargeInt.toString i) ^ " : " ^ (Bool.toString f) ^ "}\n")
                       (ListPair.zip (ingredients, is_fresh))))*)
in
    List.foldl
    (fn (a, acc) => if a then acc + 1 else acc)
    0
    is_fresh
end

fun qsort func = let
    fun sort [] = []
      | sort (lhd :: ltl) = sort (List.filter (fn x => func (x, lhd)) ltl)
                            @ [lhd]
                            @ sort (List.filter (fn x => not (func(x, lhd))) ltl)
in
    sort
end

fun min (a, b) = if LargeInt.< (a, b) then a else b
fun max (a, b) = if LargeInt.> (a, b) then a else b

fun simplifyRanges ranges = let
    fun mergeRange (a: range) (b: range) =
        if #1 b <= #2 a andalso #1 a <= #2 b
        then SOME (min (#1 a, #1 b), max (#2 a, #2 b))
        else NONE
    fun cmpRange (a: range, b: range) = #1 a > #1 b
    val sortedRanges = qsort cmpRange ranges

    fun merge ([]: range list) (acc: range list) : range list= acc
      | merge (x :: xs) [] = merge xs [x]
      | merge (x :: xs) (h :: t) =
          case mergeRange h x of
              SOME (m) => merge xs (m :: t)
            | NONE => merge xs (x :: h :: t)
in
    merge sortedRanges []
end

fun rangeSize (range: range) = (#2 range - #1 range) + 1

fun parseInputLine1 line: range = let
    val v = map (valOf o LargeInt.fromString) (String.tokens (fn x => x = #"-") line)
in
    (hd v, List.nth (v, 1))
end

fun parseInputLine2 line = (valOf o LargeInt.fromString) line

fun parseInputFile file = let
    val inStream = TextIO.openIn file
    fun readLines1 stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => let val s = stripLast line
                         in
                             if String.size s = 0
                             then []
                             else parseInputLine1 s :: readLines1 stream
                         end
    fun readLines2 stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => let val s = stripLast line
                         in
                             if String.size s = 0
                             then []
                             else parseInputLine2 s :: readLines2 stream
                         end
    val ranges = readLines1 inStream
    val ingredients = readLines2 inStream
in
    (ranges, ingredients) before TextIO.closeIn inStream
end

val data = parseInputFile inputFile;


val part1 = fpart1 data
val _ = print ("solution part 1: " ^ (Int.toString (part1)) ^ "\n");

val d2 = simplifyRanges (#1 data)
val part2 = List.foldl LargeInt.+ 0 (map rangeSize d2)
val _ = print ("solution part 2: " ^ (LargeInt.toString (part2)) ^ "\n");
