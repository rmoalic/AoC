import std.stdio, std.file, std.range, std.string, std.algorithm, std.array, std.parallelism;

string input_file = "input.txt";

enum Direction {
    L,
    R
}

struct Junction {
    string left;
    string right;
}


struct Input {
    Direction[] way;
    Junction[string] network;   
}

long path_len(immutable Input input, string start, bool delegate(string) end_condition) 
in (start in input.network)
{
    if (end_condition(start)) return 0;
    auto ret = 0;
    auto curr = start;
    foreach (junc_dir; input.way.cycle) {
        final switch (junc_dir) {
        case Direction.L:
            curr = input.network[curr].left;
            break;
        case Direction.R:
            curr = input.network[curr].right;
        }
        ret += 1;
        if (end_condition(curr)) {
            break;
        }
    }

    return ret;
}

long part1(immutable Input input) {
    return path_len(input, "AAA", (x => x == "ZZZ"));
}

long ppcm(long a, long b) pure {
    if (a == 0 || b == 0) return 0;
    long p = a * b;

    while (a != b) {
        if (a < b) {
            b -= a;
        } else {
            a -= b;
        }
    }
    return p / a;
}

long part2(immutable Input input) {
    auto paths = input.network.keys;
    auto starts = paths.filter!(x => x[2] == 'A').array();
    long[] path_lens = new long[starts.count()];

    foreach (s; starts.enumerate.parallel(3)) {
        path_lens[s[0]] = path_len(input, s[1], (x => x[2] == 'Z'));
    }
    auto ret = path_lens.fold!ppcm();
    return ret;
}

void main() {
    File input = File(input_file, "r");
    Input parsed_input;
 
    string first_line = input.readln().strip;
    foreach (c; first_line) {
        if (c == 'L') {
            parsed_input.way ~= Direction.L;
        } else if (c == 'R') {
            parsed_input.way ~= Direction.R;
        } else {
            assert(false);
        }
    }
    while (! input.eof()) {
        string line = input.readln().strip;
        if (line.count() > 0) {
            auto equal = line.split(" = ");
            auto label = equal[0];
            auto coma = equal[1][1..$-1].split(", ");
            parsed_input.network[label] = Junction(coma[0], coma[1]);
        }
    }
    immutable auto iinput = cast(immutable) parsed_input;
    auto p1 = part1(iinput);
    writeln("part1: ", p1);
    auto p2 = part2(iinput);
    writeln("part2: ", p2);
    input.close();
}
