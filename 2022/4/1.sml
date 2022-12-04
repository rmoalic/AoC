val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

type assignmentPair = ((int * int) * (int * int));
exception ParseError

fun isFullyContained (a, b) (c, d) = c <= a andalso d >= b
              
fun isPairFullyContained (x: assignmentPair): bool =
    (isFullyContained (#1 x) (#2 x)) orelse (isFullyContained (#2 x) (#1 x))

fun parseInputLine1 line: assignmentPair = let
    val elfs = String.tokens (fn x => x = #",") line;
    fun listCoupleToTuple (l: 'a list) =
        case l of
            (a :: b :: []) => (a, b)
          | _ => raise ParseError
in
    listCoupleToTuple
        (map
             (listCoupleToTuple
              o (map (valOf o Int.fromString))
              o (String.tokens (fn x => x = #"-"))) elfs)
end

fun parseInputFile file parseLine = let
    val inStream = TextIO.openIn file
    fun readLines stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => parseLine (stripLast line) :: readLines stream
in
    readLines inStream before TextIO.closeIn inStream
end

fun sumTrue l = List.foldl (fn (x, acc) => if x then acc + 1 else acc) 0 l
val data = parseInputFile inputFile parseInputLine1;
val part1 = sumTrue (map isPairFullyContained data);

val _ = print ("solution part 1: " ^ (Int.toString part1) ^ "\n");

fun isPartialyContained (a, b) (c ,d) =
    (a >= c andalso a <= d) orelse (b <= d andalso a >= d)

fun isPairPartialyContained (x: assignmentPair): bool =
    (isPartialyContained (#1 x) (#2 x)) orelse (isPartialyContained (#2 x) (#1 x))

val part2 = sumTrue (map isPairPartialyContained data);

val _ = print ("solution part 2: " ^ (Int.toString part2) ^ "\n");
