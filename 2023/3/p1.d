import std.stdio, std.file, std.ascii, std.conv, std.algorithm, std.container.array, std.array, std.typecons, std.range, std.math;

string input_file = "input.txt";

bool check_for_adjacent_symbol(immutable ubyte[][] content, long x, long y, ulong max_x, ulong max_y) {

    bool check_for_symbol(long x, long y) { //TODO: function pointer ?
        if (x >= 0 && y>=0 && x < max_x && y < max_y) {
            auto c = content[x][y];
            return (! isDigit(c)) && c != '.';
        } else {
            return false;
        }
    }

    bool ret = false;
    ret |= check_for_symbol(x - 1, y);
    ret |= check_for_symbol(x + 1, y);
    ret |= check_for_symbol(x, y - 1);
    ret |= check_for_symbol(x, y + 1);
    ret |= check_for_symbol(x - 1, y - 1);
    ret |= check_for_symbol(x - 1, y + 1);
    ret |= check_for_symbol(x + 1, y - 1);
    ret |= check_for_symbol(x + 1, y + 1);
    return ret;
}

ulong part1(immutable ubyte[][] content) {
    ulong ret = 0;
    ulong nb_lines = content.count();
    ulong line_len = content[0].count();

    auto has_adjacent_symbol = false;
    auto tmp = Array!char();

    for (auto i = 0; i < nb_lines; i++) {
        for (auto j = 0; j < line_len; j++) {
            ubyte c = content[i][j];
            if (isDigit(c)) {
                tmp.insert(c);
                has_adjacent_symbol |= check_for_adjacent_symbol(content, i, j, nb_lines, line_len);
            } else {
                if (! tmp.empty() && has_adjacent_symbol) {
                    auto n = to!uint(tmp.data());
                    ret += n;
                }
                tmp.clear();
                has_adjacent_symbol = false;
            }
        }
        if (! tmp.empty() && has_adjacent_symbol) { //TODO: dup
            auto n = to!uint(tmp.data());
            ret += n;
        }
        tmp.clear();
        has_adjacent_symbol = false;
    }

    return ret;
}

struct Point {
    ulong x;
    ulong y;

    int opCmp(ref const Point p) const {
        int first = x==p.x ? 0 : x<p.x ? -1 : 1;
        if (first != 0) {
             return first;
        } else {
             return y==p.y ? 0 : y<p.y ? -1 : 1;
        }
    }
}

Point[] list_adjacent_stars(immutable ubyte[][] content, long x, long y, ulong max_x, ulong max_y) {
    Point[] ret;
    void check_for_symbol(long x, long y) { //TODO: function pointer ?
        if (x >= 0 && y>=0 && x < max_x && y < max_y) {
            auto c = content[x][y];
            if (c == '*') {
                ret ~= Point(x, y);
            }
        }
    }
    check_for_symbol(x - 1, y);
    check_for_symbol(x + 1, y);
    check_for_symbol(x, y - 1);
    check_for_symbol(x, y + 1);
    check_for_symbol(x - 1, y - 1);
    check_for_symbol(x - 1, y + 1);
    check_for_symbol(x + 1, y - 1);
    check_for_symbol(x + 1, y + 1);
    return ret;
}

alias hP = Tuple!(int, "nb", Point, "point");
ulong part2(immutable ubyte[][] content) {
    ulong ret = 0;
    ulong nb_lines = content.count();
    ulong line_len = content[0].count();

    auto tmp = Array!char();
    bool[Point] tmp_stars;
    auto half_pairs = Array!hP();

    for (long i = 0; i < nb_lines; i++) {
        for (long j = 0; j < line_len; j++) {
            ubyte c = content[i][j];
            if (isDigit(c)) {
                tmp.insert(c);
                foreach (Point p; list_adjacent_stars(content, i, j, nb_lines, line_len)) {
                    tmp_stars[p] = false;
                }
            } else {
                if (! tmp.empty() && tmp_stars.length > 0) {
                    auto n = to!uint(tmp.data());
                    foreach (key, val; tmp_stars) {
                        half_pairs.insert(hP(n, key));
                    }
                }
                tmp.clear();
                tmp_stars.clear();
            }
        }
        if (! tmp.empty() && tmp_stars.length > 0) { //TODO: dup
            auto n = to!uint(tmp.data());
            foreach (key, val; tmp_stars) {
                half_pairs.insert(hP(n, key));
            }
        }
        tmp.clear();
        tmp_stars.clear();
    }
    half_pairs.data().sort!("a.point < b.point");
    /*foreach (hp; half_pairs.data()) {
        writeln("> ", hp.point.x, ",", hp.point.y, " val ", hp.nb);
    }*/

    foreach (hp; half_pairs.data().slide(2)) {
        auto hp1 = hp[0];
        auto hp2 = hp[1];
        if (hp1.point == hp2.point) {
            auto ratio = hp1.nb * hp2.nb;
            ret += ratio;
            //writeln("pair(", hp1.nb,", ",hp2.nb,") = ", ratio);
        }
    }

    return ret;
}

void main() {
    immutable ubyte[] content = cast(immutable ubyte[])input_file.read();
    immutable ubyte[][] content_lines = content.splitter("\n").array;
    auto p1 = part1(content_lines[0..$-1]);
    auto p2 = part2(content_lines[0..$-1]);
    writeln("part1: ", p1);
    writeln("part2: ", p2);
}
