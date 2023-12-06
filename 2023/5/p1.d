import std.stdio, std.file, std.range, std.string, std.conv, std.algorithm, std.array, std.parallelism;

string input_file = "input.txt";

long map_calc(immutable ALMap[] almmap, long source) {
    auto x = almmap.filter!(x =>  x.source <= source && (x.source + x.lenght) > source).takeOne;
    assert(x.count() <= 1);
    if (x.empty()) {
        return source;
    } else {
        auto c = x[0];
        return (c.destination - c.source) + source;
    }
}

long map_calc_inv(immutable ALMap[] almmap, long destination) {
    auto x = almmap.filter!(x =>  x.destination <= destination && (x.destination + x.lenght) > destination).takeOne;
    assert(x.count() <= 1);
    if (x.empty()) {
        return destination;
    } else {
        auto c = x[0];
        return destination - (c.destination - c.source);
    }
}

long seed_to_location(immutable Almanac alm, long seed) {
    auto soil = map_calc(alm.maps["seed-to-soil"], seed); 
    auto fertilizer = map_calc(alm.maps["soil-to-fertilizer"], soil);
    auto water = map_calc(alm.maps["fertilizer-to-water"], fertilizer); 
    auto light = map_calc(alm.maps["water-to-light"], water); 
    auto temperature = map_calc(alm.maps["light-to-temperature"], light); 
    auto humidity = map_calc(alm.maps["temperature-to-humidity"], temperature); 
    auto location = map_calc(alm.maps["humidity-to-location"], humidity); 
    return location;
}

long location_to_seed(immutable Almanac alm, long location) {
    static const string[] maps = ["seed-to-soil", "soil-to-fertilizer", "fertilizer-to-water", "water-to-light", "light-to-temperature", "temperature-to-humidity", "humidity-to-location"];
   
    long c = location; 
    foreach (map; maps.retro()) {
        c = map_calc_inv(alm.maps[map], c);
    }
    return c;
}

long part1(immutable Almanac alm) {
    long[] locations = new long[alm.seeds.count()];

    foreach (s; alm.seeds.enumerate().parallel()) {
       long location = seed_to_location(alm, s[1]);
       locations[s[0]] = location;
    }

    return locations.minElement();
}

long part2(immutable Almanac alm) {
    auto seeds_pair = alm.seeds.chunks(2).array;
    for (long i = 0; i < long.max; i++) {
        auto found_seed = location_to_seed(alm, i);
        foreach (seeds; seeds_pair) {
            auto min = seeds[0];
            auto max = min + seeds[1];
            if (found_seed >= min && found_seed < max) {
                return i;
            }
        }
        if (i % 1000 == 0) {
            writeln("pos: ", i);
        }
    }
    assert(false);
}

struct ALMap {
    long destination;
    long source;
    long lenght;
}

struct Almanac {
    long[] seeds;
    ALMap[][string] maps;
}
void main() {
    File input = File(input_file, "r");
    Almanac alm;
    auto seeds_s = input.readln().strip();
    alm.seeds = seeds_s[7 .. $].split().to!(long[])();
    auto _skip = input.readln();
    string curr_map = null;
    while (! input.eof()) {
        string line = input.readln().strip;
        if (line.count() > 0) {
            if (curr_map == null) {
                curr_map = line.split()[0];
            } else {
                auto map = line.split().to!(long[])();
                alm.maps[curr_map] ~= ALMap(map[0], map[1], map[2]);
            }
        } else {
            curr_map = null;
        }
    }
    immutable auto ialm = cast(immutable) alm;
    auto p1 = part1(ialm);
    writeln("part1: ", p1);
    auto p2 = part2(ialm);
    writeln("part2: ", p2);
    input.close();
}
