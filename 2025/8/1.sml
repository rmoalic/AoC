val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

type coordinate = {X: int, Y: int, Z: int}
exception ParseError;
exception hashmapfail;
exception Fail;

fun hashInt (x : word) : word = let (* from stackoverflow *)
    val C = 0wx45d9f3b;
    val x1 = (Word.xorb (Word.>> (x, 0w16), x)) * C;
    val x2 = (Word.xorb (Word.>> (x1, 0w16), x1)) * C
in
    Word.xorb (Word.>> (x2, 0w16), x2)
end

fun coordinate_hash (c : coordinate) : word = let
    val hx = (hashInt o Word.fromInt) (#X c)
    val hy = (hashInt o Word.fromInt) (#Y c)
    val hz = (hashInt o Word.fromInt) (#Z c)

    val COMBINE_PRIME = 0wx9e3779b9
    val combined_hash_1 = 0wx12345678
    val combined_hash_2 = Word.xorb (combined_hash_1 * COMBINE_PRIME, hx)
    val combined_hash_3 = Word.xorb (combined_hash_2 * COMBINE_PRIME, hy)
    val final_hash =      Word.xorb (combined_hash_3 * COMBINE_PRIME, hz)
in
    final_hash
end

fun same_coordinate (a: coordinate, b: coordinate) = #X a = #X b andalso #Y a = #Y b andalso #Z a = #Z b

structure CoordinateMap =HashTableFn
                             (struct
                               type hash_key = coordinate
                               fun hashVal k = coordinate_hash k
                               fun sameKey (a, b) = same_coordinate (a, b)
                               end)

fun square a = LargeInt.* (a, a)
fun euclidian_distance_fast (a: coordinate) (b: coordinate) = let
    val dx = Int.toLarge(#X b - #X a)
    val dy = Int.toLarge(#Y b - #Y a)
    val dz = Int.toLarge(#Z b - #Z a)
    val squared_sum = LargeInt.+ (LargeInt.+ (square dx, square dy), (square dz))
in
    squared_sum
end

fun make_pairs (l: 'a list): ('a * 'a) list =
    case l of
        [] => []
      | [_] => []
      | (hd :: tl) => let
          val pairs_hd = map (fn x => (hd, x)) tl
          val pairs_tl = make_pairs tl
      in
          pairs_hd @ pairs_tl
      end
fun ratePair (a,b) = euclidian_distance_fast a b

fun makeRatePairList (l: 'a list) (f: (('a * 'a) -> LargeInt.int)): (('a * 'a) * LargeInt.int) list = let
    val pairs = make_pairs (l)
    val rate = map f pairs
in
    ListPair.zip (pairs, rate)
end

fun minPair (l: (('a * 'a) * LargeInt.int) list) = let
    fun min ([]: (('a * 'a) * LargeInt.int) list) (pmin : (('a * 'a) * LargeInt.int)) = pmin
      | min [x] pmin = if (#2 pmin) < (#2 x)
                       then pmin
                       else x
      | min (x::xs) pmin = if (#2 pmin) < (#2 x)
                       then min xs pmin
                       else min xs x
in
    min (tl l) (hd l)
end

fun histogram items = let
    fun update (x, []) = [(x, 1)]
      | update (x, (y, n) :: rest) = if x = y
                                     then (y, n + 1) :: rest
                                     else (y, n) :: update (x, rest)
in
    foldl update [] items
end


fun histogram_unsorted items = let
    val hm = IntHashTable.mkTable (List.length items, hashmapfail)
    val _ = List.map (fn x => IntHashTable.insert hm (x, 0)) items

    fun loop [] = ()
      | loop (x :: xs) = let
          val curr = IntHashTable.lookup hm x
          val () = IntHashTable.insert hm (x, curr + 1)
      in
          loop xs
      end
    val () = loop items
in
    IntHashTable.listItemsi hm
end

fun printIntList xs =    let
    val s =
        "[" ^
        String.concatWith ", " (map Int.toString xs) ^
        "]\n"
in
    print s
end

fun CoordinateToString (c: coordinate) = "{X: " ^ Int.toString (#X c) ^ ", Y:" ^ Int.toString (#Y c) ^ ", Z:" ^ Int.toString (#Z c) ^ "}"

fun relabelAll circuitMap ca cb = let
    val entries = CoordinateMap.listItemsi circuitMap
    fun rewrite [] = ()
      | rewrite ((k, v) :: xs) = let
          val _ = if v = cb
                  then CoordinateMap.insert circuitMap (k, ca)(* before print ("  rewritten " ^ CoordinateToString k ^ " in group " ^ Int.toString ca ^ "\n")*)
                  else ()
      in
          rewrite xs
      end
in
    rewrite entries
end
(* apparently this is Kruskal's algorithm but with a Hashmap instead of an array, making it slower *)
fun groupMin (l: coordinate list) (f: ((coordinate * coordinate) -> LargeInt.int)) limitPairs = let
    val pairs = makeRatePairList l f
    val sortedPairs = ListMergeSort.sort (fn (a, b) => #2 a > #2 b) pairs
    val strippedPairs = map (fn (x: (coordinate * coordinate) * LargeInt.int) => #1 x) sortedPairs
    val circuitMap = CoordinateMap.mkTable (List.length l, hashmapfail)
    val _ = List.foldl (fn (x, acc) => acc + 1 before CoordinateMap.insert circuitMap (x, acc)) 0 l

    fun loop [] (processed_pairs:int) :int = processed_pairs
      | loop ((a, b) :: xs) processed_pairs = let
          val ca = CoordinateMap.lookup circuitMap a
          val cb = CoordinateMap.lookup circuitMap b
          (* val _ = print ("pair is " ^ CoordinateToString a ^ " " ^ CoordinateToString b ^
                        "\n  init group are " ^ Int.toString ca ^ " " ^ Int.toString cb ^ "\n")

          val _ = print ("  processed_pairs: " ^ Int.toString processed_pairs ^ "\n") *)
      in
          if processed_pairs >= limitPairs
          then processed_pairs (* before print ("!!limit\n") *)
          else if ca = cb
          then loop xs (processed_pairs + 1)
          else let
              val _ = relabelAll circuitMap ca cb
              (* val _ = print ("  relabel " ^  Int.toString cb ^ " -> " ^ Int.toString ca ^ "\n") *)
          in
              loop xs (processed_pairs + 1)
          end
      end
    val _ = loop strippedPairs 0
    val circuits = CoordinateMap.listItems circuitMap
    (*val _ = print ("num items " ^ (Int.toString (CoordinateMap.numItems circuitMap)) ^ "\n")
    val _ = printIntList (CoordinateMap.listItems circuitMap)
    val _ = printIntList circuits*)
in
    histogram_unsorted (circuits)
end

fun groupFindLoop (l: coordinate list) (f: ((coordinate * coordinate) -> LargeInt.int))  = let
    val pairs = makeRatePairList l f
    val sortedPairs = ListMergeSort.sort (fn (a, b) => #2 a > #2 b) pairs
    val strippedPairs = map (fn (x: (coordinate * coordinate) * LargeInt.int) => #1 x) sortedPairs
    val circuitMap = CoordinateMap.mkTable (List.length l, hashmapfail)
    val _ = List.foldl (fn (x, acc) => acc + 1 before CoordinateMap.insert circuitMap (x, acc)) 0 l

    fun loop [] (remaining_join:int) :(coordinate * coordinate) option= NONE
      | loop ((a, b) :: xs) remaining_join = let
          val ca = CoordinateMap.lookup circuitMap a
          val cb = CoordinateMap.lookup circuitMap b
      in
          if ca = cb
          then loop xs remaining_join
          else let
              val _ = relabelAll circuitMap ca cb
              val remaining_join_new = remaining_join - 1
          in
              if remaining_join_new = 0
              then SOME (a, b)
              else loop xs remaining_join_new
          end
      end
    val last_pair = loop strippedPairs ((List.length l) - 1)
in
    last_pair
end

fun parseInputLine line: coordinate = let
    val snums = String.tokens (fn x => x = #",") line
    val nums = map (valOf o Int.fromString) snums
in
    if List.length nums = 3
    then {
        X = List.nth (nums, 0),
        Y = List.nth (nums, 1),
        Z = List.nth (nums, 2)
    }
    else raise ParseError
end

fun parseInputFile file = let
    val inStream = TextIO.openIn file
    fun readLines stream  =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => if String.size line < 2
                         then []
                         else parseInputLine (stripLast line) :: readLines stream
in
    readLines inStream  before TextIO.closeIn inStream
end

val data = parseInputFile inputFile;

val d = if String.isSubstring "example" inputFile
        then groupMin data ratePair 10
        else groupMin data ratePair 1000
val sd = ListMergeSort.sort (fn (a, b) => #2 a < #2 b) d
val top = if List.length sd < 3
          then raise Fail
          else map (fn x => #2 x) (List.take (sd, 3))
val part1 = List.foldl op* 1 top
val _ = print ("solution part 1: " ^ (Int.toString (part1)) ^ "\n");

val (d2_a, d2_b) = valOf (groupFindLoop data ratePair)
val part2 = LargeInt.* (Int.toLarge(#X d2_a), Int.toLarge(#X d2_b))
val _ = print ("solution part 2: " ^ (LargeInt.toString (part2)) ^ "\n");
