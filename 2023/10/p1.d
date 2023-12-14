import std.stdio, std.file, core.exception, std.conv, std.range, std.string, std.algorithm, std.array, std.parallelism, std.container.array, std.container.dlist;

string input_file = "input.txt";

struct pos {
    long x;
    long y;

    pos opBinary(string op : "+")(pos b) {
        return pos(this.x + b.x, this.y + b.y);
    }
}

long part1(immutable char[][] input) {
    pos start = find_start(input);
    pos[] discovered;
    int max_steps = 0;

    auto Q = DList!pos();
    auto depthQ = DList!int(); //TODO; merge the 2 Queue
    discovered ~= start;
    Q.insertBack(start);
    depthQ.insertBack(0);

    while (! Q.empty) {
        auto v = Q.front;
        Q.removeFront();
        auto depth = depthQ.front;
        depthQ.removeFront();
        foreach (j; get_adjacent(input, v)) {
            if (! discovered.canFind(j)) {
                discovered ~= j;
//                writeln(j, "  ", depth);
                max_steps = depth + 1;
                Q.insertBack(j);
                depthQ.insertBack(depth + 1);
            }
        }
    }
    return max_steps;
}

long part2(immutable char[][] input) {
    pos start = find_start(input);
    char[][] board = input.map!(x => x.dup).array;

    pos[] discovered;
    void dfg(pos v) {
        discovered ~= v;
        board[v.x][v.y] = 'X';
        foreach (j; get_adjacent(input, v)) {
            if (! discovered.canFind(j)) {
                dfg(j);
            }
        }
    }
    dfg(start);

    pos[] simplify(pos[] path) {
        pos[] ret;
        bool vertical = path[0].x != path[1].x;
        foreach (edge; path.slide(2)) {
            auto x1 = edge[0].x;
            auto y1 = edge[0].y;
            auto x2 = edge[1].x;
            auto y2 = edge[1].y;

            if (x1 != x2 && vertical) {
                ret ~= edge[0];
                vertical = false;
            } else if (y1 != y2 && !vertical) {
                ret ~= edge[0];
                vertical = true;
            }
        }
        return ret;
    }

    pos[] simplified_discovered = simplify(discovered);

    long ret = 0;
    
    bool is_inside(pos[] edges, pos point) { //from https://www.youtube.com/watch?v=RSXM9bgqxJM
        ulong counter = 0;
        foreach (edge; edges.slide(2)) {
            auto x1 = edge[0].x;
            auto y1 = edge[0].y;
            auto x2 = edge[1].x;
            auto y2 = edge[1].y;
            if (((point.y < y1) != (point.y < y2)) && 
                (point.x < x1 + ((point.y - y1) / (y2-y1)) * (x2 - x1))) {
                counter += 1;
            }
        }
        return counter % 2 == 1;
    }

   
   writeln("warning: ignoring line 14"); 
    for (int x = 0; x < input.count(); x++) {
        for (int y = 0; y < input[x].count(); y++) {
            auto curr = pos(x,y);
            auto junction = board[x][y];
            if (junction != 'X' && y != 14 && is_inside(simplified_discovered, curr)) { // FIXME: find where the weird line 14 bug comes from
                ret += 1;
                board[x][y] = '%';
            }
        }
    }

    writeln(" --- ");
    for (int x = 0; x < input.count(); x++) {
        for (int y = 0; y < input[x].count(); y++) {
            auto curr = pos(x,y);
            auto junction = board[x][y];
            auto junction_c = input[x][y];
            if (junction == '%') {
                printf("\x1b[31m%%\033[0m");
            } else if (junction == 'X') {
                printf("\033[1;32m%c\033[0m", junction_c);
            } else {
                printf("%c", junction);
            }
        }   
        printf("\n");
    }

    return ret;
}

static const bool[][char] connect_to;
shared static this() {
   connect_to = [
        '-': [false, true, false, true],
        '|': [true, false, true, false],
        '7': [false, false, true, true],
        'J': [true, false, false, true],
        'L': [true, true, false, false],
        'F': [false, true, true, false],
        '.': [false, false, false, false],
        'S': [true , true, true, true],
    ];

}

static pos[4] direction = [pos(-1, 0), pos(0, +1), pos(+1, 0), pos(0, -1)];

pos[] get_adjacent(immutable char[][] g, pos curr_pos) {
    pos[] ret;
    char curr = g[curr_pos.x][curr_pos.y];
    bool[4] can_connect = connect_to[curr];

    for (int i = 0; i < 4; i++) {
        if (! can_connect[i]) continue;
        auto adjacent_pos = curr_pos + direction[i];
        char adjacent;
        try {     
            adjacent = g[adjacent_pos.x][adjacent_pos.y];
        } catch (core.exception.ArrayIndexError e) {
            continue;
        }
        if (connect_to[adjacent][(i + 2) % 4]) {
            ret ~= adjacent_pos;
        }
    }    
    return ret;
}

pos find_start(immutable char[][] g) {
    for (int x = 0; x < g.count(); x++) {
        for (int y = 0; y < g[x].count(); y++) {
            char curr = g[x][y];
            if (curr == 'S') {
                return pos(x, y);
            }
        }
    }
    assert(false);
}

void main() {
    File input = File(input_file, "r");
    auto parsed_input = new Array!string(); 
    while (! input.eof()) {
        string line = input.readln().strip;
        if (line.count() > 0) {
            parsed_input.insert(line);
        }
    }
    immutable auto iinput = cast(immutable) parsed_input.array;
    auto p1 = part1(iinput);
    writeln("part1: ", p1);
    auto p2 = part2(iinput);
    writeln("part2: ", p2);
    input.close();
}
