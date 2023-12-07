import std.stdio, std.file, std.range, std.string, std.conv, std.algorithm, std.array, std.math, std.ascii;

string input_file = "input.txt";

struct Race {
    long time;
    long distance;
}

long part1(immutable Race[] rc) {
    auto ret = 1;
    foreach (race; rc) {
        long count_winning_time = 0;
        for (long push_time = 1; push_time < race.time; push_time++) {
            auto speed = push_time;
            auto race_dist = (race.time - push_time) * speed;
            if (race_dist > race.distance) {
                count_winning_time += 1;
            }
        }
        ret *= count_winning_time;
    }
    return ret;
}

long part2(immutable Race rc) {
    auto low  = ceil((rc.time - sqrt((rc.time ^^ 2) - (4 * rc.distance) * 1.0)) / 2);
    auto high = ceil((rc.time + sqrt((rc.time ^^ 2) - (4 * rc.distance) * 1.0)) / 2);
    return cast(long) high - cast(long)low;
}

void main() {
    File input = File(input_file, "r");
    Race[] rcs;
    long[] time;
    long[] distance;
    long p2_time;
    long p2_distance;
    Race p2_race;
    
    while (! input.eof()) {
        string line = input.readln().strip;
        if (line.count() > 0) {
            auto header = line.split(":");
            if (header[0] == "Time") {
                time = header[1].split().to!(long[])();
                p2_time = header[1].filter!(c => !c.isWhite)().to!long();
            } else if (header[0] == "Distance") {
                distance = header[1].split().to!(long[])();
                p2_distance = header[1].filter!(c => !c.isWhite)().to!long();
            }
        }
    }
    foreach (t, d; zip(time, distance)) {
        rcs ~= Race(t, d);
    }
    p2_race = Race(p2_time, p2_distance);
    immutable auto ircs = cast(immutable) rcs;
    auto p1 = part1(ircs);
    writeln("part1: ", p1);
    auto p2 = part2(cast(immutable) p2_race);
    writeln("part2: ", p2);
    input.close();
}
