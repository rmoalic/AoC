val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

datatype toperation = MUL | ADD
datatype parseType = OP of toperation list | NUM of int list;
exception ParseError;

fun fpart1 (numbers, operations) = let
    fun app operation n = let
          val ope =  case operation of
                         MUL => LargeInt.*
                       | ADD => LargeInt.+
          val init = case operation of
                         MUL => 1
                       | ADD => 0
          val nums = List.map (fn x => Int.toLarge (List.nth (x, n))) numbers
    in
        List.foldl ope init nums
    end
    fun loop [] _ = []
      | loop [operation] n = [app operation n]
      | loop (operation :: xs) (n: int) = app operation n :: loop xs (n + 1)
in
    loop operations 0
end

fun parseInputLine1 line = map (valOf o Int.fromString) (String.tokens (fn x => x = #" ") line)
fun parseInputLine2 line = map (fn x => if x = "*" then MUL else ADD) ((String.tokens (fn x => x = #" ") line))

fun parseInputFile_Dispatch line =
    if List.exists (fn x => x = String.sub (line, 0)) [#"*", #"+"]
    then OP (parseInputLine2 line)
    else NUM (parseInputLine1 line)

fun parseInputFile file = let
    val inStream = TextIO.openIn file
    fun readLines stream (nums, ops) =
        case TextIO.inputLine stream of
            NONE => (nums, ops)
          | SOME line => case parseInputFile_Dispatch (stripLast line) of
                             OP (x) => readLines stream (nums, x :: ops)
                          | NUM (x) => readLines stream (x :: nums, ops)
in
    readLines inStream ([], []) before TextIO.closeIn inStream
end

val data = parseInputFile inputFile;

val d1 = (#1 data, hd (#2 data))
val d11 = fpart1 d1
val part1 = List.foldl LargeInt.+ 0 d11
val _ = print ("solution part 1: " ^ (LargeInt.toString (part1)) ^ "\n");
(*
val d2 = simplifyRanges (#1 data)
val part2 = List.foldl LargeInt.+ 0 (map rangeSize d2)
val _ = print ("solution part 2: " ^ (LargeInt.toString (part2)) ^ "\n");
*)
