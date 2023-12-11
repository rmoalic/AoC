import std.stdio, std.file, std.conv, std.range, std.string, std.algorithm, std.array, std.parallelism, core.checkedint;

string input_file = "input.txt";

long next_value(long[] history) {
   long[][] steps;
   steps ~= history;
   bool all_zeroes = false;
   do {
       auto step = steps[$ - 1].slide(2).array.map!(a => a[1] - a[0]).array;
       all_zeroes = step.all!(x => x == 0);
       steps ~= step;
       assert(step.count() > 1);
   } while (! all_zeroes);
   ulong nb_steps = steps.count();
   long[] new_values = new long[nb_steps];
   new_values[0] = 0;
   for (int i = 1; i < nb_steps; i++) {
       bool overflow;
       new_values[i] = adds(steps[$ - i - 1][$ - 1], new_values[i - 1], overflow);
       assert(! overflow);
   }
   return new_values[$ - 1];
}

long part1(immutable long[][] input) {
    long[] next_values = new long[input.count()];
    foreach (report; input.enumerate().array.parallel()) {
        next_values[report[0]] = next_value(report[1].dup);
    }
    return next_values.sum();
}

long part2(immutable long[][] input) {
    long[] next_values = new long[input.count()];
    foreach (report; input.enumerate().array.parallel()) {
        next_values[report[0]] = next_value(report[1].dup.reverse);
    }
    return next_values.sum();
}

void main() {
    File input = File(input_file, "r");
    long[][] parsed_input; 
    while (! input.eof()) {
        string line = input.readln().strip;
        if (line.count() > 0) {
            parsed_input ~= line.split().to!(long[])(); 
        }
    }
    immutable auto iinput = cast(immutable) parsed_input;
    auto p1 = part1(iinput);
    writeln("part1: ", p1);
    auto p2 = part2(iinput);
    writeln("part2: ", p2);
    input.close();
}
