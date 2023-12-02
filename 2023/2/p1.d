import std.stdio, std.file, std.string, std.conv, std.algorithm;

string input_file = "input.txt";

int[string] record_to_assoc(string record) {
    int[string] ret;
    auto colors = record.split(", ");
    foreach (color; colors) {
        auto c = color.split(" ");
        auto nb = to!int(c[0]);
        auto name = c[1];
        ret[name] = nb;
    }
    return ret;
}

bool check_record(int[string] record, immutable int[string] rules) {
    foreach (key, value; record) {
        if (rules[key] < value) {
            return false;
        }
    }
    return true;
}

int part1(string line) {
    immutable int[string] rules = [
        "red": 12, "green": 13, "blue": 14    
    ];
    auto game = line.split(": ");
    int game_id = to!int(game[0][5 .. $]);
    auto records = game[1].split("; ");

    foreach (record; records) {
        auto assoc = record_to_assoc(record);
        if (! check_record(assoc, rules)) {
           return 0; 
        }
    }
    return game_id;
}

int part2(string line) {
    auto game = line.split(": ");
    int game_id = to!int(game[0][5 .. $]);
    auto records = game[1].split("; ");

    auto assocs = records.map!(record_to_assoc);
    int[string] mins;
    foreach (agame; assocs) {
        foreach (key, value; agame) {
            mins.update(key,
                        () => value,
                        (ref int v) => v > value ? v : value);            
        }
    }

    auto power = mins.get("green", 0) *
                 mins.get("red", 0) *
                 mins.get("blue", 0);
    return power;
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
