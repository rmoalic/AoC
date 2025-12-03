val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

type drange = LargeInt.int * LargeInt.int;
exception ParseError;

fun applyN f 0 x = x
  | applyN f n x = applyN f (n-1) (f x)

fun uniqueSorted [] = []
  | uniqueSorted [x] = [x]
  | uniqueSorted (x1 :: x2 :: xs) =
    if x1 = x2
    then uniqueSorted (x2 :: xs)
    else x1 :: uniqueSorted (x2 :: xs)

fun qsort func = let
    fun sort [] = []
      | sort (lhd :: ltl) = sort (List.filter (fn x => func (x, lhd)) ltl)
                            @ [lhd]
                            @ sort (List.filter (fn x => not (func(x, lhd))) ltl)
in
    sort
end
                
fun nb_digits n = let
    val v = if LargeInt.<(n, 0) then LargeInt.~ n else n
    fun nb_digits_in 0 = 0
      | nb_digits_in n = 1 + (nb_digits_in (LargeInt.div (n, 10)))
in
    nb_digits_in v
end

fun inRange (range: drange) (v: LargeInt.int) =  LargeInt.>=(v, (#1 range)) andalso LargeInt.<=(v, (#2 range))

fun power (x, 0) = 1
  | power (x, n) = LargeInt.* (power (x, n - 1), x)

fun doubleNumber n = LargeInt.+(LargeInt.* (n, (power (10, nb_digits n))), n)

                                   
fun removeDigits n toRemove = LargeInt.div (n, (power (10, toRemove)))
fun addDigits d n = LargeInt.+ (LargeInt.* (n, power (10, nb_digits d)), d)

fun repeatNFirst n v = let
    val nb_d = nb_digits v
    val repeat_value = removeDigits v (nb_d - n)
    val nb_repeat = (nb_d div n) - 1
in
    if n <= (nb_d div 2) andalso (nb_d mod 2 = 0 orelse (nb_d mod 2 = 1 andalso (nb_d mod n) = 0))
    then SOME (applyN (addDigits repeat_value) nb_repeat repeat_value)
    else NONE
end

fun nearAll n = let
    val nb_d = nb_digits n
    fun repeat 0 = []
      | repeat i = repeatNFirst i n :: repeat (i - 1)
in
    List.map Option.valOf (List.filter Option.isSome (repeat (nb_d div 2)))
end

fun nearDouble n = let
    val nb_d = nb_digits n
in
    if nb_d mod 2 = 1
    then []
    else [doubleNumber (removeDigits n (nb_d div 2))]
end

fun checkRange (near) ((rstart, rend) : drange) : LargeInt.int list = let
    val nb_d = nb_digits rstart
    val search = near rstart
    
    val num_removed = nb_d div 2
    val base = LargeInt.+(removeDigits rstart num_removed, 1)
    val next_candidate = LargeInt.* (base, (power (10, num_removed)))

    val next_start = if inRange (rstart, rend) next_candidate then SOME next_candidate else NONE
    
    fun rnext () = (case next_start of
                        SOME y => checkRange near (y, rend)
                      | NONE => [])
    fun res (s :: xs) = if inRange (rstart, rend) s
                        then s :: res xs
                        else res xs
      | res [] = []
in
    uniqueSorted (qsort (fn (a,b) => a > b) ((res search @ rnext())))
end

fun parseInputLine line: drange list = let
    val tokens = String.tokens (fn x => x = #"," orelse x = #"-") line
    fun toRange (x :: y :: xs) = 
        (valOf (LargeInt.fromString x), valOf (LargeInt.fromString y)) :: toRange xs
      | toRange (x :: xs) = raise ParseError
      | toRange _ = []
in
    toRange tokens
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

val data = List.hd (parseInputFile inputFile);
val d = map (checkRange nearDouble) data

val part1 = List.foldl LargeInt.+ 0 (List.concat d);
val _ = print ("solution part 1: " ^ (LargeInt.toString (part1)) ^ "\n");

val d2 = map (checkRange nearAll) data
val part2 = List.foldl LargeInt.+ 0 (List.concat d2);
val _ = print ("solution part 2: " ^ (LargeInt.toString (part2)) ^ "\n");
