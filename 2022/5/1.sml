(* This uses the wrong data structure: Array2 *)

val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

datatype Token =
         NOTK
       | RULE of (int * int * int)
       | BOARD of char list

exception ParseError


fun repeat f n = let
    val i = ref 0
in
    while !i < n do (
        f ();
        i := !i + 1
    );
    ()
end

fun nonEmpty c = c <> #" "

fun addRows arr n = let
    val newRows = (Array2.nRows arr) + n
    val newCols = Array2.nCols arr
    val newArray = Array2.array (newRows, newCols, #" ")
in
    Array2.copy {src= {base= arr, row= 0, col= 0, nrows= NONE, ncols=NONE}
                , dst= newArray, dst_row= n, dst_col= 0};
    newArray
end
fun move board ((toPos, to), (fromPos, from)) fromVal = (
    Array2.update (board, fromPos, from, #" ");
    Array2.update (board, toPos, to, fromVal);
    ()
)
    
fun moveOne board from to = let
    fun nonEmptyi (_, c) = nonEmpty c
    val board_max = (Array2.nRows board) - 1
    val fromPos =  case Vector.findi nonEmptyi (Array2.column (board, from)) of
                       SOME (pos, c) => (print ("move " ^ (Char.toString c) ^ " ON ") ; pos)
                     | NONE => raise ParseError
    val toPos = case Vector.findi nonEmptyi (Array2.column (board, to)) of
                    SOME (pos, c) => (print( (Char.toString c) ^ " pos " ^ (Int.toString pos) ^ "\n");
                                      if pos = 0
                                      then  pos
                                      else pos - 1)
                  | NONE => (print (" no\n"); board_max)
    val fromVal = Array2.sub (board, fromPos, from)
in
    print ("("^ (Int.toString from) ^ ", " ^ (Int.toString to) ^ ")\n" );
    move board ((toPos, to), (fromPos, from)) fromVal
end

fun moveOnebyOne board (count, from, to) = repeat (fn () => moveOne board from to) count

fun getFirst v =  case Vector.find nonEmpty v of
                      SOME c => c
                    | NONE => #" "

fun getTopRow b = let
    val nCols = Array2.nCols b
    fun loop n = if n = nCols
                 then []
                 else (getFirst (Array2.column (b, n))) :: loop (n + 1)
in
    String.implode (loop 0)
end

fun filteri f list = let
    fun loop _ [] = []
      | loop count (k :: xs) = if f count k
                               then k :: loop (count + 1) xs
                               else loop (count + 1) xs
in
    loop 0 list
end
        
fun parseInputLine_rows line = let
    val nb_tokens = (size line + 1) div 4
    fun isPos x _ = x mod 4 = 1
    val row = filteri isPos (explode line)
in
    if hd row = #"1"
    then NOTK
    else BOARD row
end
                                   
fun parseInputLine_rules line = let
    val rules_tokens = String.tokens (fn x => x = #" ") line
    fun toTuple (_ :: move :: _ :: from :: _ :: to :: xs) = ((valOf o Int.fromString) move,
                                                             ((valOf o Int.fromString) from) - 1,
                                                             ((valOf o Int.fromString) to) - 1)
      | toTuple _ = raise  ParseError
in
    toTuple rules_tokens
end

fun parseInputLine_Dispatch line =
    if size line = 0
    then NOTK
    else if String.isPrefix "move" line
    then RULE (parseInputLine_rules line)
    else parseInputLine_rows line

fun parseInputFile file parseLine = let
    val inStream = TextIO.openIn file
    fun readLines stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => case parseLine (stripLast line) of
                             RULE x => raise ParseError
                           | BOARD x => x :: readLines stream
                           | NOTK => []
    fun readLines2 stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => case parseLine (stripLast line) of
                             RULE x => x :: readLines2 stream
                           | BOARD x => raise ParseError
                           | NOTK => []
    val board = readLines inStream
    val _ = TextIO.inputLine inStream
    val rules = readLines2 inStream
in
    (board, rules) before TextIO.closeIn inStream
end

val data = parseInputFile inputFile parseInputLine_Dispatch;
val board = addRows (Array2.fromList (#1 data)) 100
val rules = #2 data;
val rearange1 = app (moveOnebyOne board) rules
val part1 = getTopRow board

val _ = print ("solution part 1: " ^ part1 ^ "\n");


