val inputFile = "input.txt";
val boardSize = (200, 200) (* only used for print *)

datatype dir = Up | Left | Right | Down
type way = dir * int
type pos = int * int
exception ParseError

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

fun toDir c = case c of
                  #"U" => Up
                | #"D" => Down
                | #"L" => Left
                | #"R" => Right
                | _ => raise ParseError

fun printBoard (l, w) ((hx, hy), (tx, ty)) = let
    fun loop x ~1 = ()
      | loop x y = let
        val c = if x = hx andalso y = hy
                then #"H"
                else if x = tx andalso y = ty
                then #"T"
                else #"."
        val nx = x + 1
      in
        print (Char.toString c);
        if nx > w
        then (print "\n"; loop 0 (y - 1))
        else loop (x + 1) y
    end
in
    loop 0 l
end
val pp = printBoard boardSize

fun printTailPositions (l, w) tailpos = let
    fun loop x ~1 = ()
      | loop x y = let
        val c = if List.exists (fn (cx, cy) => cx = x andalso cy = y) tailpos
                then #"1"
                else #"0"
        val nx = x + 1
      in
        print (Char.toString c);
        if nx > w
        then (print "\n"; loop 0 (y - 1))
        else loop (x + 1) y
    end
in
    loop 0 l
end
val ptp = printTailPositions boardSize               

fun unique [] = []
  | unique (k :: xs) = let
      val rest = List.filter (fn x => x <> k) xs
  in
      k :: unique rest
  end

fun countUniqueTailPositions tailpos = List.length (unique tailpos)

fun stepTail ((head, tail): pos * pos) = let
    val diffX = #1 head - #1 tail
    val diffY = #2 head - #2 tail
    val sX = Int.sign diffX
    val sY = Int.sign diffY
in
    (*print ("(" ^ (Int.toString sX) ^ ", " ^ (Int.toString sY) ^ ")\n");*)
    if Int.abs (diffX) > 1 orelse Int.abs diffY > 1
    then ((#1 tail) + sX, (#2 tail) + sY)
    else tail
end

fun stepHead (hX, hY) dir n = case dir of
                                  Up => (hX, hY + n)
                                | Down => (hX, hY - n)
                                | Left => (hX - n, hY)
                                | Right => (hX + n, hY)

fun stepHeadTail step (head, tail) = let
    val nhead = stepHead head (#1 step) (#2 step)
    fun loop (_, 0) (h, t) = []
      | loop (dir, pas) (h, t) = let
          val nhead = stepHead h dir 1
          val ntail = stepTail (nhead, t)
      in
          (*pp (nhead, ntail);
          print "----\n";*)
          ntail :: loop (dir, pas - 1) (nhead, ntail)
      end
in
    (nhead, loop step (head, tail))
end
       
fun followPath path = let
    fun loop [] _ = []
      | loop (step :: xs) (head, tail) = let
          (*val _ = (pp (head, tail); print "=============\n\n")*)
          val (nhead, tails) = stepHeadTail step (head, tail)
          val ntail = List.last tails
      in
          tails @ loop xs (nhead, ntail)
      end
in
    loop path ((0, 0), (0, 0))
end

fun parseInputLine line = let
    val d = toDir (String.sub (line, 0))
    val l = valOf (Int.fromString (String.extract (line, 2, NONE)))
in
    (d, l)
end

fun parseInputFile file parseLine = let
    val inStream = TextIO.openIn file
    fun readLines stream =
        case TextIO.inputLine stream of
            NONE => []
          | SOME line => parseLine (stripLast line) :: readLines stream
in
    readLines inStream before TextIO.closeIn inStream
end

val data = parseInputFile inputFile parseInputLine
val tailPositions = followPath data
val _ = ptp tailPositions

val part1 = countUniqueTailPositions tailPositions
val _ = print ("solution part 1: " ^ (Int.toString part1) ^ "\n");
