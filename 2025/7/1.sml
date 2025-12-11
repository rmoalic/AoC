val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

datatype DynamicBoardExt = BEAM
datatype 'a BoardToken =
    EMPTY
  | START
  | SPLITTER
  | EXT of 'a

type BaseBoardToken = unit BoardToken
type DynamicBoardToken = DynamicBoardExt BoardToken
exception ParseError;
exception Fail;

fun isSplitter b = case b of
                       SPLITTER => true
                     | _ => false
fun isBeam b = case b of
                   EXT BEAM => true
                 | _ => false
fun isStart b = case b of
                    START => true
                  | _ => false
fun isEmpty b = case b of
                    EMPTY => true
                  | _ => false
fun toDynamic board = case board of
                          EMPTY => EMPTY
                        | START => START
                        | SPLITTER => SPLITTER
                        | EXT b => raise Fail
fun toDynamicList (board: BaseBoardToken list) : DynamicBoardToken list = map toDynamic board
fun firstRow (f : BaseBoardToken list) = List.map (fn x => if isStart x then EXT BEAM else EMPTY) f
fun firstRowPos [] pos = raise Fail
  | firstRowPos [x] pos = pos
  | firstRowPos (x :: xs) pos = if isStart x then pos else firstRowPos xs (pos + 1)
fun nextRow (curr : DynamicBoardToken list) = List.map (fn x => if isBeam x then EXT BEAM else EMPTY) curr
fun mergeRow (base: BaseBoardToken list) (row: DynamicBoardToken list) = let
    val nb_splitter = ref 0;
    fun merge ([]: DynamicBoardToken list) ([]: DynamicBoardToken list) (acc: DynamicBoardToken list) = acc
      | merge [b] [r] acc = r :: acc
      | merge [b] (r :: rx) acc = raise Fail
      | merge (b :: bx) [r] acc = raise Fail
      | merge (b :: bx) (r :: rx) acc = if isSplitter b  andalso isBeam r
                                        then merge (tl bx) (tl rx)
                                                   ((if isEmpty (hd acc)
                                                     then r
                                                     else hd acc)
                                                    :: b
                                                    :: (if isEmpty (hd bx)
                                                        then r
                                                        else hd bx)
                                                    :: (tl acc)) before nb_splitter := !nb_splitter + 1
                                        else
                                            if isBeam r
                                            then merge bx rx (r :: acc)
                                            else merge bx rx (b :: acc)
in
    (List.rev (merge (toDynamicList base) (row) []), ! nb_splitter)
end
fun compute map = let
    val first = firstRow (hd map)
    val nb_split = ref 0
    fun loop [] next = []
      | loop (b :: bx) next = let
          val (curr, nb_splitter) = mergeRow b next
          val _ = nb_split := !nb_split + nb_splitter;
      in
          curr :: loop bx (nextRow curr)
      end
    val ret = loop (tl map) first
in
    (ret, !nb_split)
end

fun mergeRow2 (base: BaseBoardToken list) pos = let
    val p = List.nth (base, pos)
in
    if isSplitter p
    then ((if pos > 0 andalso isEmpty (List.nth (base, pos - 1))
           then SOME(pos-1)
           else NONE),
          (if pos + 1 < List.length base andalso isEmpty (List.nth (base, pos + 1))
           then SOME(pos+1)
           else NONE))
    else (NONE, NONE)
end

fun hashInt (x : word) : word = let (* from stackoverflow *)
    val C = 0wx45d9f3b;
    val x1 = (Word.xorb (Word.>> (x, 0w16), x)) * C;
    val x2 = (Word.xorb (Word.>> (x1, 0w16), x1)) * C
in
    Word.xorb (Word.>> (x2, 0w16), x2)
end
fun hash_array (type_list : BaseBoardToken list) : word = let
    fun type_to_seed t =
        case t of
            EMPTY => 0w101
          | START => 0w103
          | SPLITTER => 0w107;

    fun combine_simple (type_item, current_hash) = let
        val seed = type_to_seed type_item
        val new_hash = Word.xorb ((current_hash * 0w31), seed)
      in
        new_hash
      end
  in
    List.foldl combine_simple 0w7 type_list
  end

fun compute2 map = let
    val length = List.length map
    val vec = Vector.fromList map
    val firstPos = firstRowPos (Vector.sub (vec, 0)) 0
    fun chash (v: (int * int)) = Word.xorb ((hashInt (Word.fromInt (#1 v))), (hashInt (Word.fromInt (#2 v))))
    fun csame (a: (int * int), b: (int * int)) = #2 a = #2 b andalso #1 a = #1 b
    val cache = HashTable.mkTable (chash, csame) (20, Fail)
    fun cloop (idx_map: int) (next: int) : LargeInt.int = let
        val cache_entry = HashTable.find cache (idx_map, next)
    in
        case cache_entry of
            SOME (v: LargeInt.int) => v
          | NONE => let
              val v = loop idx_map next
              val _ = HashTable.insert cache ((idx_map, next), v)
          in
              v
          end
    end
    and loop idx_map next =
        if idx_map >= length
        then 1
        else  let
          val b = Vector.sub (vec, idx_map)
          val merge =  mergeRow2 b next
      in
          case merge of
              (NONE, NONE) => cloop (idx_map+1) next
            | (SOME a, NONE) => cloop (idx_map+1) a
            | (NONE, SOME b) => cloop (idx_map+1) b
            | (SOME a, SOME b) => LargeInt.+ ((cloop (idx_map+1) a), (cloop (idx_map+1) b))
      end
    val ret = cloop 0 firstPos
in
    ret
end

fun TypeToToken (t: 'a BoardToken) =
    case t of
        START => "S"
      | EMPTY => "."
      | SPLITTER => "^"
      | EXT e => "|"

fun printMap mmap = let
    fun printLine c = print ((String.concatWith "" (map TypeToToken c)) ^ "\n")
in
    map printLine mmap
end

fun tokenToType c : BaseBoardToken =
    case c of
        #"S" => START
      | #"." => EMPTY
      | #"^" => SPLITTER
      | _ => raise ParseError

fun parseInputLine line: BaseBoardToken list = map tokenToType (String.explode line)

fun parseInputFile file = let
    val inStream = TextIO.openIn file
    fun readLines stream  =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => parseInputLine (stripLast line) :: readLines stream
in
    readLines inStream  before TextIO.closeIn inStream
end

val data = parseInputFile inputFile;
val d = compute data;
printMap (#1 d);

val part1 = (#2 d);
val _ = print ("solution part 1: " ^ (Int.toString (part1)) ^ "\n");

val part2 = compute2 data;
val _ = print ("solution part 2: " ^ (LargeInt.toString (part2)) ^ "\n");
