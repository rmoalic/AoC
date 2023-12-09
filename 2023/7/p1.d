import std.stdio, std.file, std.range, std.string, std.conv, std.algorithm, std.array, std.math, std.ascii;

string input_file = "input.txt";

mixin template CachedProperty(string name, string baseName = '_' ~ name) {
    mixin("private typeof(" ~ baseName ~ ") " ~ name ~ "Cache;");
    mixin("private bool " ~ name ~ "IsCached = false;");
    mixin("@property typeof(" ~ baseName ~ ") " ~ name ~ "() {\n" ~
          "if (" ~ name ~ "IsCached" ~ ") return " ~ name ~ "Cache;\n" ~
          name ~ "IsCached = true;\n" ~
          "return " ~ name ~ "Cache = " ~ baseName ~ ";\n" ~
          '}');
}

immutable int[char] card_power;

shared static this() {
    int[char] tmp = [
        'A': 14,
        'K': 13,
        'Q': 12,
        'J': 11,
        'T': 10        
    ];
    foreach (i; 2..10) { 
        tmp[digits[i]] = i;
    }
    tmp.rehash();
    card_power = cast(immutable) tmp;
}

struct Card {
    char face;
    
    invariant {
        assert(['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'].canFind(face));
    }

    bool opEquals(const Card s) const {
        return s.face == this.face;
    }

    int opCmp(ref const Card b) { 
        int va = card_power[this.face];
        int vb = card_power[b.face];
        int ret = va==vb ? 0 : va<vb ? -1 : 1;

        return ret;
    }

    string toString() const pure @safe {
        return format("Card(%c)", face);
    }
}

enum HandType {
    FiveOfAKind = 7,
    FourOfAKind = 6,
    FullHouse = 5,
    ThreeOfAKind = 4,
    TwoPair = 3,
    OnePair = 2,
    HightCard = 1,
}

struct HandBid { 
    Card[5] hand;
    long bid;

    @property HandType _hand_type() const {
        auto hand_sorted = this.hand.dup.sort!();
        auto groups = hand_sorted.group();
    
        int nb_groups = cast(int) groups.count();
        if (nb_groups == 1) {
            return HandType.FiveOfAKind;
        } else if (nb_groups == 2) {
            if (groups.any!(x => x[1] == 4)()) {
                return HandType.FourOfAKind;
            } else {
                return HandType.FullHouse;
            }
        } else if (nb_groups == 3) {
            if (groups.any!(x => x[1] == 3)()) {
                return HandType.ThreeOfAKind;
            } else {
                return HandType.TwoPair;
            }
        } else if (nb_groups == 4) {
            return HandType.OnePair;
        } else {
            return HandType.HightCard;
        }
    }
    mixin CachedProperty!"hand_type";

    int opCmp(ref HandBid b) { 
        int va = this.hand_type();
        int vb = b.hand_type();

        if (va == vb) {
            foreach (i; 0..5) {
                if (this.hand[i] != b.hand[i]) {
                    auto vva = this.hand[i];
                    auto vvb = b.hand[i];
                    return vva==vvb ? 0 : vva<vvb ? -1 : 1;
                }
            }
            return 0;
        } else if (va < vb) {
           return -1; 
        } else {
            return 1;
        }
    }
}


long part1(immutable HandBid[] rc) {
    auto ret = 0;
    auto ranked = rc.dup.sort();

    foreach (i, c; ranked.enumerate()) {
        auto rank = i + 1;
//        writeln(rank, " ", c);
//        writeln(rank, " * ", c.bid);
        ret += c.bid * rank;
    }

    return ret;
}

long part2(immutable HandBid[] rc) {
    return 0;
}

void main() {
    File input = File(input_file, "r");
    HandBid[] hb;
    while (! input.eof()) {
        string line = input.readln().strip;
        if (line.count() > 0) {
            auto l = line.split();
            Card[5] tmp;
            foreach (i, c; l[0].enumerate()) {
                tmp[i] = Card(cast(char) c);
            }
            hb ~= HandBid(tmp, to!long(l[1]));           
        }
    }
    immutable auto ic = cast(immutable) hb;
    auto p1 = part1(ic);
    writeln("part1: ", p1);
    auto p2 = part2(cast(immutable) ic);
    writeln("part2: ", p2);
    input.close();
}
