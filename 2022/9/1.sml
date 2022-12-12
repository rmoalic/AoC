val inputFile = "input.txt";
val boardSize = (~50, ~50, 200, 150) (* only used for print *)

datatype dir = Up | Left | Right | Down
type way = dir * int
type pos = int * int
structure PosSet =
RedBlackSetFn (struct
                type ord_key = pos
                fun compare ((a1, a2), (b1, b2)) =
                    if a1 = b1
                    then Int.compare (a2, b2)
                    else Int.compare (a1, b1)
                end)
exception ParseError

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

fun printIntTuple (x, y) = "(" ^ (Int.toString x) ^ ", " ^ (Int.toString y) ^ ")"

fun toDir c = case c of
                  #"U" => Up
                | #"D" => Down
                | #"L" => Left
                | #"R" => Right
                | _ => raise ParseError

fun printPBMHeader (bx, by, ux, uy) = let
    val x = Int.abs(bx) + ux
    val y = Int.abs(by) + uy
in
    print ("P1\n" ^ (Int.toString x) ^ " " ^ (Int.toString y) ^ "\n")
end

fun printTailPositions (bx, by, ux, uy) tailpos = let
    fun loop x y = if y <= by
                   then ()
                   else let
                       val c = if PosSet.member (tailpos, (x, y))
                               then #"1"
                               else #"0"
                       val nx = x + 1
                   in
                       print (Char.toString c);
                       if nx >= ux
                       then (print "\n"; loop bx (y - 1))
                       else loop (x + 1) y
                   end
in
    loop bx uy
end
val ptp = printTailPositions boardSize               

fun stepTail ((head, tail): pos * pos) = let
    val diffX = #1 head - #1 tail
    val diffY = #2 head - #2 tail
    val sX = Int.sign diffX
    val sY = Int.sign diffY
in
    (*print ((printIntTuple (sX, sY)) ^ "\n");*)
    if Int.abs (diffX) > 1 orelse Int.abs diffY > 1
    then ((#1 tail) + sX, (#2 tail) + sY)
    else tail
end

fun stepHead (hX, hY) dir n = case dir of
                                  Up => (hX, hY + n)
                                | Down => (hX, hY - n)
                                | Left => (hX - n, hY)
                                | Right => (hX + n, hY)

fun stepTails ((head, tails): pos * pos list) = let
    val all = head :: tails
    fun loop [] = []
      | loop (a :: b :: xs) = stepTail (a, b) :: loop (b :: xs)
      | loop [b] = []
in
    loop all
end

signature S =
sig
    val stepHead : pos -> dir -> int
    val stepTails : pos * pos list -> pos list
    val stepHeadTail : way -> pos * pos list -> pos * pos list list
    val followPath : way list -> int -> PosSet.set
end

fun stepHeadTail step (head, tails) = let
    val nhead = stepHead head (#1 step) (#2 step)
    fun loop (_, 0) (h, t) = []
      | loop (dir, pas) (h, t) = let
          val nhead = stepHead h dir 1
          val ntail = stepTails (nhead, t)
      in(*
          print ((Int.toString pas) ^ (printIntTuple head) ^ " -> ");
          print (String.concatWith ", "(map printIntTuple ntail));
          print "\n";*)
          ntail :: loop (dir, pas - 1) (nhead, ntail)
      end
in
    (nhead, loop step (head, tails))
end

(* BUG: some of the last tails positions might be missing for some reason (see input_test2.txt) *)
fun followPath path ntails = let
    val start = ((0, 0), List.tabulate (ntails, (fn _ => (0, 0))))
    fun loop [] _ = PosSet.empty
      | loop (step :: xs) (head, tails) = let
          val (nhead, tailspos): pos * pos list list = stepHeadTail step (head, tails)
          val ntail: pos list = List.last tailspos
      in(*
          print ("nhead: " ^ (printIntTuple nhead) ^ "\n");
          print (String.concatWith ", "(map printIntTuple (map List.last tailspos)));
          print "\n";*)
          PosSet.addList ((loop xs (nhead, ntail)), map List.last tailspos)
      end
in
    loop path start
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
val tailPositions = followPath data 1
(*
val _ = printPBMHeader boardSize
val _ = ptp tailPositions
val _ = print "\n"
*)
val part1 = PosSet.numItems tailPositions
val _ = print ("solution part 1: " ^ (Int.toString part1) ^ "\n");

val tailPositions = followPath data 9
(*
val _ = printPBMHeader boardSize
val _ = ptp tailPositions
val _ = print "\n"
*)
val part2 = PosSet.numItems tailPositions
val _ = print ("solution part 2: " ^ (Int.toString part2) ^ "\n");
