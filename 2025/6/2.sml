val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

datatype toperation = MUL | ADD
datatype parseType = OP of (toperation * int) list | NUMS of char list;
exception ParseError;

fun fpart2 (numbers, operations) = let
    fun app operation n = let
          val ope =  case operation of
                         MUL => LargeInt.*
                       | ADD => LargeInt.+
          val init = case operation of
                         MUL => 1
                       | ADD => 0
          val nums = List.map Int.toLarge (List.nth (numbers, n))
    in
        List.foldl ope init nums
    end
    fun loop [] _ = []
      | loop [operation] n = [app operation n]
      | loop (operation :: xs) (n: int) = app operation n :: loop xs (n + 1)
in
    loop operations 0
end

fun getNumbers (arr, ops) = let
    fun getN skip nb_operand = let
        fun loop 0 = []
          | loop n = ((valOf o Int.fromString) (Vector.foldl
                          (fn (x, acc) => (Char.toString x) ^ acc)
                          ""
                          (Array2.column (arr, (n - 1) + skip))))
                     :: loop (n - 1)
    in
        loop nb_operand
    end

    fun loop ([]: (toperation * int) list) skip = []
      | loop [x] skip = [getN skip (#2 x)]
      | loop (x :: xs) skip = getN skip (#2 x) :: loop xs (skip + #2 x + 1)
in
    loop ops 0
end


fun parseInputLine1 line = String.explode line
fun parseInputLine2 line = let
    fun token tk = case tk of
                       #"*" => MUL
                     | #"+" => ADD
                     | _ => raise ParseError
    fun count [] last_token n = []
      | count [x] last_token n = if x = #" "
                                 then [(token last_token, n + 1)]
                                 else [(token last_token, n + 1), (token x, 1)]
      | count (x :: xs) last_token n = if x = #" "
                                       then count xs last_token (n + 1)
                                       else (token last_token, n - 1) :: count xs x 1
    val l = String.explode line
in
    count (tl l) (hd l) 1
end

fun parseInputFile_Dispatch line =
    if List.exists (fn x => x = String.sub (line, 0)) [#"*", #"+"]
    then OP (parseInputLine2 line)
    else NUMS (parseInputLine1 line)

fun parseInputFile file = let
    val inStream = TextIO.openIn file
    fun readLines stream (nums, ops) =
        case TextIO.inputLine stream of
            NONE => (nums, ops)
          | SOME line => case parseInputFile_Dispatch (stripLast line) of
                             OP (x) => readLines stream (nums, x :: ops)
                          | NUMS (x) => readLines stream (x :: nums, ops)
in
    readLines inStream ([], []) before TextIO.closeIn inStream
end

val data = parseInputFile inputFile;

val d2 = (Array2.fromList (#1 data), hd (#2 data))
val d22 = (getNumbers d2, map #1 (#2 d2))
val part2 = List.foldl LargeInt.+ 0 (fpart2 d22)
val _ = print ("solution part 2: " ^ (LargeInt.toString (part2)) ^ "\n");
