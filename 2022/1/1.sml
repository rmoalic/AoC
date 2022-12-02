val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

fun qsort func = let
    fun sort [] = []
      | sort (lhd :: ltl) = sort (List.filter (fn x => func (x, lhd)) ltl)
                            @ [lhd]
                            @ sort (List.filter (fn x => not (func(x, lhd))) ltl)
in
    sort
end

fun parseInputLine (line: string, record_n: int) =
    case Int.fromString line of
        SOME i =>  SOME (record_n, i)
      | NONE => NONE

fun parseInputFile file = let
    val inStream = TextIO.openIn file
    fun readLines (stream, record_n) =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => case parseInputLine ((stripLast line), record_n) of
                             SOME data => data :: readLines(stream, record_n)
                           | NONE => readLines(stream, record_n + 1)

in
    readLines(inStream, 0) before TextIO.closeIn inStream
end

fun sumConsecutiveKey data = let
    val first_value = #2 (hd data)
    fun loop ([], acc: int) = []
      | loop ([(k1, v1)], acc) = (k1, acc) :: []
      | loop (((k1, v1) :: (k2, v2) :: xs), acc) = if k1 = k2
                                                   then loop (((k2, v2) :: xs), acc + v2)
                                                   else (k1, acc) :: loop (((k2, v2) :: xs), v2)
in
    loop (data, first_value)
end

fun max [] = NONE
  | max [x] = SOME x
  | max ((k1, v1) :: (k2, v2) :: xs) = if v1 < v2
                                       then max ((k2, v2) :: xs)
                                       else max ((k1, v1) :: xs)

fun formatTuple (k, v) = "(" ^ Int.toString k ^ ", " ^ Int.toString v ^ ")"

val data: (int * int) list = parseInputFile inputFile
val summed_data = sumConsecutiveKey data
val solucePart1 = valOf (max summed_data)
val sorted_data = qsort (fn (v1, v2) => (#2 v1) > (#2 v2)) summed_data
val solucePart2 = List.foldl Int.+ 0 (map #2 (List.take (sorted_data, 3)))


val _ = print ("solution part 1: " ^ (formatTuple solucePart1)
           ^ "\nsolution part 2: " ^ (Int.toString solucePart2) ^ "\n")

