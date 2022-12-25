val inputFile = "input.txt";

fun stripLast str = String.substring(str, 0, ((String.size str) - 1));

datatype MixInt = Mix of int | Fixed of int
type ListLoop = MixInt list * MixInt list

fun mixint_to_string x = case x of
                             Mix n => "m " ^ (Int.toString n)
                           | Fixed n => "f " ^ (Int.toString n)

fun list_to_string x = "[" ^ (String.concatWith ", " (map mixint_to_string x)) ^ "]";

fun print_list x = print ((list_to_string x) ^ "^n")
fun print_mixint (x, y) = print ("(" ^ (list_to_string x) ^ ", " ^ (list_to_string y) ^ ")\n")


fun fwd (x::xs, y) = (xs, x::y)
  | fwd ([], y) = case List.rev y of 
                      (y::xy) => (xy, [y])
                    | [] => ([], [])

fun bwd (x, y::xy) = (y::x, xy)
  | bwd (x, []) = case List.rev x of
                      (x::xs) => ([x], xs)
                    | [] => ([], [])

fun rst (x, y) = ((List.rev y) @ x, [])

fun mix_size (x, y) = List.length x + List.length y

fun repeat n f s = let
    fun loop c acc = if c = 1
                     then acc
                     else loop (c - 1) (f acc)
in
    if n < 0
    then raise Fail "repeat call with n <= 0"
    else if n = 0
    then s
    else loop n (f s)
end

fun addr (x, y) n = if List.length x = 0
                    then (x, y @ [n])
                    else (x, n::y)

fun addl (x, y) n = if List.length y = 0
                    then (x @ [n], y)
                    else (n::x, y)

fun move_to to mix = let
    fun loop (x, y) = if (hd y) = to
                          then (x, y)
                          else loop (fwd (x, y))

in
    loop (bwd mix)
end

fun move_mix (x, []) = (x, [])
  | move_mix (x, y::ys) = case y of
                              Mix n => let
                               val move = (Int.abs n) mod (mix_size (x, ys))
                               val dir = if Int.sign n > 0
                                         then (fwd, addr)
                                         else (bwd, addl)
                               val mfwd = repeat move (#1 dir) (x, ys)
                               val added_back = (#2 dir) mfwd (Fixed n)
                           in
                               added_back
                           end
                            | Fixed _ => (x, y::ys)

fun is_mix (_, []) = false
  | is_mix (_, y::ys) = case y of
                            Mix _ => true
                          | _ => false

fun mix_val (x, []) = raise Fail "Empty mix_val"
  | mix_val (x, y::xs) = case y of
                             Mix n => n
                           | Fixed n => n
                                      

fun fix input = let
    val max = (List.length (#1 input))
    fun loop lloop 0 = lloop
      | loop lloop n = let
          (* val _ = print_mixint lloop *)
          val f = fwd lloop
          val moving = is_mix f
      in
          if moving
          then
              let
                  val s = move_mix f              
              in
                  loop (rst s) max
              end
          else loop f (n - 1)
      end
in
    loop input max
end

fun calc_sum input zero = let
    val s0 = move_to zero input
    val s1 = repeat 1000 fwd s0
    val s2 = repeat 1000 fwd s1
    val s3 = repeat 1000 fwd s2
in
    (mix_val s1) + (mix_val s2) + (mix_val s3)
end
    
fun solve1 input = let
    val size = List.length input
    val lloop: ListLoop = (input, [])
    val sol = fix lloop
    val sum = calc_sum sol (Fixed 0)
in
    (#1 (rst sol), sum)
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

val test_data = [Mix 1, Mix 2, Mix ~3, Mix 3, Mix ~2, Mix 0, Mix 4]
val test_result = [Fixed 1, Fixed 2, Fixed ~3, Fixed 4, Fixed 0, Fixed 3, Fixed ~2]

val data = parseInputFile inputFile (Mix o valOf o Int.fromString);
val (res1, part1) = solve1 data
(* val _ = print_mixint (res1, []) *)
val _ = print ("solution part 1: " ^ (Int.toString part1) ^ "\n");

val (rest1, partt1) = solve1 test_data
val _ = print_mixint (rest1, [])
val ok = ListPair.allEq op= (rest1, test_result)
val _ = print ("solution part 1 (test): " ^ (Int.toString partt1) ^ " " ^ (Bool.toString ok) ^ "\n");

fun smix_val v = case v of
                     Mix n => n
                   | Fixed n => n

fun smix_to_smix v = Mix (smix_val v)
fun smix_to_sfix v = Fixed (smix_val v)

fun mix_rst (x, y) = let
    val (nx, ny) = rst (x, y)
in
    (map smix_to_smix nx, ny)
end

fun mix_set (x, y) = let
    val (nx, ny) = rst (x, y)
in
    (map smix_to_sfix nx, ny)
end


val key = 811589153
fun addDecriptionKey x = Mix (key * (smix_val x))

fun fix2 base input = let
    (* val _ = print_mixint input *)
    fun loop lloop [] = lloop
      | loop lloop (x::xs) = let
          val f = move_to x lloop
          (*val _ = print_mixint f*)
          val s = move_mix f
      in
          loop (rst s) xs
      end
in
    loop input base
end

fun solve2 input = let
    val size = List.length input
    val lloop: ListLoop = (input, [])
    val mfix = fix2 input
    val sol = mix_set (repeat 10 (mix_rst o mfix) lloop)
    (*val _ = print "DONE sol\n"*)
    val sum = calc_sum sol (Fixed 0)
in
    (#1 (rst sol), sum)
end

val data2 = map addDecriptionKey data
val (res2, part2) = solve2 data2
val _ = print ("solution part 2: " ^ (Int.toString part2) ^ "\n");

val test_data2 = map addDecriptionKey test_data
val test_result2 = [Fixed 0, Fixed ~2434767459, Fixed 1623178306, Fixed 3246356612, Fixed ~1623178306, Fixed 2434767459, Fixed 811589153]
val (rest2, partt2) = solve2 test_data2
val _ = print_mixint (rest2, [])
val ok2 = ListPair.allEq op= (rest2, test_result2)
val _ = print ("solution part 2 (test): " ^ (Int.toString partt2) ^ " " ^ (Bool.toString ok2) ^ "\n");
