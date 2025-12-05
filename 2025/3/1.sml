val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

exception ParseError;

fun power (x, 0) = 1
  | power (x, n) = LargeInt.* (power (x, n - 1), x)

fun max (l: int list) =
    case l of
        [] => raise Fail "max of empty list"
      | h :: t => let
          fun max_i [] (max_v, max_p) _ = (max_v, max_p)
            | max_i (x :: xs) (max_v, max_p) current_index =
              if x > max_v
              then max_i xs (x, current_index) (current_index + 1)
              else max_i xs (max_v, max_p) (current_index + 1)
      in
              max_i t (h, 0) 1
      end

fun maxJoltage batt = let
    val first = max (List.take (batt, (List.length batt) - 1))
    val second = max (List.drop (batt, (#2 first + 1)))
in
    10 * (#1 first) + (#1 second)
end
fun printList xs = print((String.concatWith ", " (map Int.toString xs)) ^ "\n");

fun findPosition v l = let
    fun find va (h :: t) n = if va = h
                            then SOME(n)
                            else find va t (n + 1)
      | find va [] n = NONE
in
    find v l 0
end

fun decompose 0 = []
  | decompose n = decompose (LargeInt.div (n,10)) @ [LargeInt.toInt (LargeInt.mod (n, 10))]

fun maxNJoltage n batt = let
    fun isPosible [] _ matched = (true, matched)
      | isPosible _ [] matched = (false, matched)
      | isPosible (h :: t) l matched = let
          val position = findPosition h l
      in
        case position of
            SOME(n) => isPosible t (List.drop (l, n + 1)) (matched + 1)
          | NONE => (false, matched)
      end
    fun findPosible (0 : LargeInt.int) = NONE
      | findPosible (c : LargeInt.int) = let
          val posible: (bool * int) = isPosible (decompose c) batt 0
      in
          if (#1 posible)
          then SOME (c)
          else findPosible (LargeInt.- (c, (power (10, n - (#2 posible) - 1))))
      end
in
    Option.valOf (findPosible (LargeInt.- (power (10, n), 1)))
end

fun parseInputLine line: int list = map (fn n => Char.ord n - Char.ord #"0") (String.explode line)

fun parseInputFile file = let
    val inStream = TextIO.openIn file
    fun readLines stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => parseInputLine (stripLast line) :: readLines stream
in
    readLines inStream before TextIO.closeIn inStream
end

val data = parseInputFile inputFile;

val d = map maxJoltage data
val part1 = List.foldl Int.+ 0 d;
val _ = print ("solution part 1: " ^ (Int.toString (part1)) ^ "\n");

val d2 = map (maxNJoltage 12) data
val part2 = List.foldl LargeInt.+ 0 d2;
val _ = print ("solution part 2: " ^ (LargeInt.toString (part2)) ^ "\n");
