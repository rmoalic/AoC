val inputFile = "input.txt";

exception ParseError

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

fun intersect ([], _) = []
  | intersect (_, []) = []
  | intersect (a, (k :: xs)) = if List.exists (fn x => x = k) a
                               then k :: intersect (a, xs)
                               else intersect (a, xs)

fun intersectFirst (a, b) = hd (intersect (a, b))
                           
fun charPriority c = if Char.isUpper c
                     then (ord c) - 38
                     else (ord c) - 96

fun parseInputLine1 line = let
    val half = (size line) div 2
    val l = explode (String.substring (line, 0, half))
    val r = explode (String.substring (line, half, half))
in
    (l, r)
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

val data = parseInputFile inputFile parseInputLine1;
val dintersect = map intersectFirst data;
val part1 = List.foldl Int.+ 0 (map charPriority dintersect);

val _ = print ("solution part 1: " ^ (Int.toString part1) ^ "\n");

fun id (a: 'a): 'a = a

fun split3 (a :: b :: c :: xs) = [a, b, c] :: split3 xs
  | split3 [] = []
  | split3 _ = raise ParseError

fun intersectAll [] = []
  | intersectAll [k] = k
  | intersectAll (k :: xs) = intersect (k, intersectAll xs)

fun intersectAllFirst list = case intersectAll list of
                                 (k :: xs) => k
                               | []  => raise ParseError

val data2 = split3 (parseInputFile inputFile explode);
val dintersect = map intersectAllFirst data2;
val part2 = List.foldl Int.+ 0 (map charPriority dintersect);

val _ = print ("solution part 2: " ^ (Int.toString part2) ^ "\n");
