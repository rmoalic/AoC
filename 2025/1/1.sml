val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

datatype direction = Left | Right;
type move = direction * int;
exception ParseError;

fun isZero v = v = 0;

fun moveKnob curr (dir, nb) = case dir of
                                  Left => (curr - nb) mod 100
                                | Right => (curr + nb) mod 100

fun countKnobTurn curr (dir, nb) = let
    val turn = nb div 100
    val rest = nb mod 100
    val new_pos = moveKnob curr (dir, rest)
    val turn_end =  if new_pos = 0 then 1 else 0
    val turn_pass =  if curr = 0
                     then 0
                     else case dir of
                         Left => if new_pos > curr then 1 else 0
                       | Right =>if new_pos < curr then 1 else 0
    (*val _ = print ((Int.toString curr) ^ "->" ^ (Int.toString new_pos) ^ "\t#" ^ (Int.toString turn) ^ " " ^ (Int.toString turn_end) ^ " " ^ (Int.toString turn_pass) ^ "\n")*)
in
    if turn_end > 0
    then turn + turn_end
    else turn + turn_pass
end

fun moveAndCount (move, (curr, count_zero)) = let
    val new_pos = moveKnob curr move;
    val new_count = if isZero new_pos
                    then count_zero + 1
                    else count_zero
    (*val _ = print ("(" ^ (Int.toString new_pos) ^ ":" ^ (Int.toString new_count) ^ ")")*)
in
    (new_pos, new_count)
end

fun moveAndCountTurn (move, (curr, count_zero)) = let
    val new_pos = moveKnob curr move;
    val new_count = count_zero + (countKnobTurn curr move);
    (*val _ = print ("(" ^ (Int.toString new_pos) ^ ":" ^ (Int.toString new_count) ^ ")")*)
in
    (new_pos, new_count)
end

fun charToDirection #"L" = Left
  | charToDirection #"R" = Right
  | charToDirection c = raise ParseError

fun parseInputLine line: move = let
    val direction = charToDirection (String.sub (line, 0));
    val nb_turn = (valOf o Int.fromString) (String.extract (line, 1, NONE))
in
    (direction, nb_turn) : move
end

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

val part1 = List.foldl moveAndCount (50, 0) data
val _ = print ("solution part 1: " ^ (Int.toString (#2 part1)) ^ "\n");
val part2 = List.foldl moveAndCountTurn (50, 0) data
val _ = print ("solution part 2: " ^ (Int.toString (#2 part2)) ^ "\n");
