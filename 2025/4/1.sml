val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

datatype Token = EMPTY | ROLL;
exception ParseError;

fun adgacentMap map = let
    val (nrow, ncol) = Array2.dimensions map

    fun elementValue x = case x of
                             EMPTY => 0
                           | ROLL => 1

    fun guarded (x, y) = if x >= 0 andalso x < nrow andalso y >= 0 andalso y < ncol
                         then elementValue (Array2.sub (map, x, y))
                         else 0

    fun countAdgacent (i, j) =
        if Array2.sub (map, i, j) = ROLL
        then (guarded (i - 1, j - 1)) +
             (guarded (i - 1, j    )) +
             (guarded (i - 1, j + 1)) +
             (guarded (i    , j + 1)) +
             (guarded (i    , j - 1)) +
             (guarded (i + 1, j - 1)) +
             (guarded (i + 1, j    )) +
             (guarded (i + 1, j + 1))
        else 0
in
    Array2.tabulate Array2.RowMajor (nrow, ncol, countAdgacent)
end

fun countLower max (adjmap, map) =
    Array2.foldi Array2.RowMajor (fn (i, j, c, acc) =>
                                     if c < max andalso Array2.sub (map, i, j) = ROLL
                                     then acc + 1
                                     else acc) 0 {base=adjmap,row=0,col=0,nrows=NONE,ncols=NONE}
fun removeLower max (adjmap, map) =
    Array2.appi Array2.RowMajor (fn (i, j, c) =>
                                    if c < max andalso Array2.sub (map, i, j) = ROLL
                                    then Array2.update (map, i, j, EMPTY)
                                    else ()) {base=adjmap,row=0,col=0,nrows=NONE,ncols=NONE}

fun removeAll max map = let
    fun step () : int list = let
        val adj = adgacentMap map
        val can_remove = countLower max (adj, map)
        val _ = removeLower max (adj, map)
      in
          if can_remove = 0
          then []
          else can_remove :: step ()
      end
in
    List.foldl Int.+ 0 (step ())
end

fun toToken c = case c of
                    #"." => EMPTY
                  | #"@" => ROLL
                  | _ => raise ParseError

fun parseInputLine line: Token list = map toToken (String.explode line)

fun parseInputFile file = let
    val inStream = TextIO.openIn file
    fun readLines stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => parseInputLine (stripLast line) :: readLines stream
in
    readLines inStream before TextIO.closeIn inStream
end

val data = Array2.fromList (parseInputFile inputFile);

val adg = adgacentMap data
val part1 = countLower 4 (adg, data)
val _ = print ("solution part 1: " ^ (Int.toString (part1)) ^ "\n");

val part2 = removeAll 4 data
val _ = print ("solution part 2: " ^ (Int.toString (part2)) ^ "\n");
