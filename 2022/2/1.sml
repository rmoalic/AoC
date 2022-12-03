val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

datatype hand = Rock | Paper | Sizor;
type game = hand * hand;
datatype outcome = Win | Lose | Tie;
exception ParseError;

fun charToHand #"A" = Rock
  | charToHand #"X" = Rock
  | charToHand #"B" = Paper
  | charToHand #"Y" = Paper
  | charToHand #"C" = Sizor
  | charToHand #"Z" = Sizor
  | charToHand c = raise ParseError

fun handToScore Rock = 1
  | handToScore Paper = 2
  | handToScore Sizor = 3

fun roundToOutcome (Rock, Paper) = Win
  | roundToOutcome (Rock, Sizor) = Lose
  | roundToOutcome (Sizor, Paper) = Lose
  | roundToOutcome (Sizor, Rock) = Win
  | roundToOutcome (Paper, Sizor) = Win
  | roundToOutcome (Paper, Rock) = Lose
  | roundToOutcome (_, _) = Tie

fun outcomeToScore Win = 6
  | outcomeToScore Lose = 0
  | outcomeToScore Tie = 3

fun gameToScore game = outcomeToScore (roundToOutcome game) + handToScore (#2 game)

fun parseInputLine line = let
    val cars = explode line
    val opponent = charToHand (List.hd cars)
    val player = charToHand (List.last cars)
in
    (opponent, player)
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

val data = parseInputFile inputFile;
val part1 = List.foldl Int.+ 0 (map gameToScore data);
val _ = print ("solution part 1: " ^ (Int.toString part1) ^ "\n");
