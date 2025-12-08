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
                        | _ => raise Fail
fun toDynamicList (board: BaseBoardToken list) : DynamicBoardToken list = map toDynamic board
fun firstRow (f : BaseBoardToken list) = List.map (fn x => if isStart x then EXT BEAM else EMPTY) f
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

(*
Val d2 = simplifyRanges (#1 data)
val part2 = List.foldl LargeInt.+ 0 (map rangeSize d2)
val _ = print ("solution part 2: " ^ (LargeInt.toString (part2)) ^ "\n");
*)
