val inputFile = "input.txt"

datatype mixedIntList = Int of int | List of mixedIntList list
exception ParseError

fun qsort func = let
    fun sort [] = []
      | sort (lhd :: ltl) = sort (List.filter (fn x => func (x, lhd)) ltl)
                            @ [lhd]
                            @ sort (List.filter (fn x => not (func(x, lhd))) ltl)
in
    sort
end

fun findi func = let
    fun loop acc (x :: xs) = if func x
                             then SOME (x, acc)
                             else loop (acc + 1) xs
      | loop acc [] = NONE
in
    loop 0
end

fun parseInputLine getc s = let
    val rInt = Int.scan StringCvt.DEC getc
    (*val _ = print "Start Line\n";*)
    fun parseArray r = let
        fun get r =
            case rInt r of
                SOME (n, r') => let
                 val (arr, rest) = get r'
             in                    
                 ((Int n) :: arr, rest)
             end
              | NONE => case getc r of
                            SOME (#",", r') => get r'
                          | SOME (#"]", r') => (
                              (*print ("End array: " ^ (Substring.string r') ^ "\n");*)
                              ([], r'))
                          | SOME (#"[", r') => let
                              (*val _ = print "Start of sub array\n";*)
                              val (arr, rest) = parseArray r'
                              val (arr2, rest2) = get rest
                          in
                              (*print ("End of sub array: " ^ (Substring.string rest) ^ "\n");*)
                              ((arr :: arr2), rest2)
                          end
                          | SOME (c, r') => (
                              print ("Ignored: " ^ (Char.toString c) ^ "\n");
                              ([], r'))
                          | NONE => raise ParseError
        val p = get r
    in
        (List (#1 p), #2 p)
    end
        
in
    case getc s of
        NONE => NONE
      | SOME (#"[", r) => let
          val (arr, rest) = parseArray r
      in
          SOME arr
      end
      | _ => NONE
end

fun makeCouples [] = []
  | makeCouples (SOME (l) :: SOME (r) :: NONE :: xs) = (l, r) :: makeCouples xs
  | makeCouples (SOME (l) :: SOME (r) :: []) = (l, r) :: []
  | makeCouples _ = raise ParseError

fun compareCouple (List (l :: xl), List (r :: xr)) = let
    val curr = compareCouple (l, r)
in
    if curr = EQUAL
    then compareCouple (List xl, List xr)
    else curr
end
  | compareCouple (List [], List []) = EQUAL
  | compareCouple (List _, List []) = GREATER
  | compareCouple (List [], List _) = LESS
  | compareCouple (List l, Int r) = compareCouple (List l, List [Int r])
  | compareCouple (Int l, List r) = compareCouple (List [Int l], List r)
  | compareCouple (Int l, Int r) = Int.compare (l, r)

fun solve data = let
    fun loop (x :: xs) pos acc = if compareCouple x = LESS
                                 then loop xs (pos + 1) (acc + pos)
                                 else loop xs (pos + 1) acc
      | loop [] pos acc = acc
in
    loop data 1 0
end

fun parseInputFile file parseLine = let
    val inStream = TextIO.openIn file
    fun readLines stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => (parseLine Substring.getc (Substring.full line)) :: readLines stream
in
    readLines inStream before TextIO.closeIn inStream
end

val data = parseInputFile inputFile  parseInputLine

val part1 = solve (makeCouples data)
val _ = print ("solution part 1: " ^ (Int.toString part1) ^ "\n")

val k1 = List [List [Int 2]]
val k2 = List [List [Int 6]]
val data2 = (List.map Option.valOf (List.filter Option.isSome data)) @ (k1 :: k2 :: [])
val sorted = qsort (fn (a, b) => compareCouple (a, b) = LESS) data2
val (_, posk1) = valOf (findi (fn x => x = k1) sorted)
val (_, posk2) = valOf (findi (fn x => x = k2) sorted)
val part2 = (posk1 + 1) * (posk2 + 1)
val _ = print ("solution part 2: " ^ (Int.toString part2) ^ "\n")
