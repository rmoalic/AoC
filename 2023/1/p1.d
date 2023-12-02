import std.stdio, std.file, std.string, std.ascii, std.conv, std.algorithm, std.range;

string input_file = "input.txt";

int part1(string line) {
   int first, last;
   bool found_first = false, found_last = false;
   
   foreach (char c; line) {
        if (isDigit(c)) {
            first = c - '0';
            found_first = true;
            break;
        }
   }

   foreach (dchar c; line.retro) {
        if (isDigit(c)) {
            last = c - '0';
            found_last = true;
            break;
        }
   }
   assert(found_first && found_last);
   return 10 * first + last;
}

enum motifs: int {
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
};

int parse_line(string line) {
    int ret;
    char c = line[0];

    if (isDigit(c)) {
        ret = c - '0';
    } else {
        auto dline = line[0 .. $];
        auto found = parse!motifs(dline);
        ret = found;
    }
    
    return ret;
}

int part2(string line) {
   auto count = line.count();
   int first, last;
   bool found_first = false, found_last = false;

    long i = 0;
    while (i < count) {
        auto dline = line[i .. $];
        try {
           first = parse_line(dline);
           found_first = true;
           break;
        } catch (std.conv.ConvException e) {
           i += 1;
        }
    }

    i = count - 1;
    while (i >= 0) {
        auto dline = line[i .. $];
        try {
           last = parse_line(dline);
           found_last = true;
           break;
        } catch (std.conv.ConvException e) {
           i -= 1;
        }
    }
    assert(found_first && found_last);
    return 10 * first + last;
}

unittest {
    assert(part2("eightwo") == 82);
    assert(part2("xxc3d") == 33);
}

void main() {
    File input = File(input_file, "r");
    auto acc1 = 0;
    auto acc2 = 0;
    while (! input.eof()) {
        string line = input.readln().strip;
        if (line.count() > 0) {
            acc1 += part1(line);
            acc2 += part2(line);
        }
    }
    writeln("part1: ", acc1);
    writeln("part2: ", acc2);
    input.close();
}
