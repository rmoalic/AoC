val inputFile = "input.txt"

fun stripLast str = String.substring(str, 0, ((String.size str) - 1))

fun parseInputLine line = line

fun parseInputFile file parseLine = let
    val inStream = TextIO.openIn file
    fun readLines stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => parseLine (stripLast line) :: readLines stream
in
    readLines inStream before TextIO.closeIn inStream
end

(* BTreeSet would be faster *)
fun allDifferent l = let
    fun loop e [] acc = if acc >= 2
                        then false
                        else true
      | loop _ _ 2 = false
      | loop e (x :: xs) acc = if x = e
                               then loop e xs (acc + 1)
                               else loop e xs acc
in
    List.all (fn x => loop x l 0) l
end

fun solve s code_len = let
    val v = explode s
    val max = (size s) - code_len
    fun loop s pos = if pos > max
                     then NONE
                     else let
                         val start = List.take (s, code_len)
                         val rest = List.drop (s, 1)
                     in
                         if allDifferent start
                         then SOME pos
                         else loop rest (pos + 1)
                     end
in
    case (loop v 0) of
        SOME x => SOME (x + code_len)
      | NONE => NONE
end

val test = case solve "abdabdc" 4 of
               SOME x => if x <> 7
                         then raise Fail ("Assert failled: " ^ (Int.toString x))
                         else ()
             | NONE => raise Fail "Assert failled: None"

val data = hd (parseInputFile inputFile parseInputLine)
val part1 = valOf(solve data 4)
val _ = print ("solution part 1: " ^ (Int.toString part1) ^ "\n")

val part2 = valOf(solve data 14)
val _ = print ("solution part 2: " ^ (Int.toString part2) ^ "\n")
