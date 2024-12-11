import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range, std.ascii;

string input_file = "input.txt";

struct Position {
  long x;
  long y;

  Position opBinary(string op : "-")(Position rhs) {
    return Position(this.x - rhs.x, this.y - rhs.y);
  }

  Position opBinary(string op : "+")(Position rhs) {
    return Position(this.x + rhs.x, this.y + rhs.y);
  }

  Position opBinary(string op : "*")(long rhs) {
    return Position(this.x * rhs, this.y * rhs);
  }

  Position opUnary(string op : "-")() {
    return Position(-this.x, -this.y);
  }

  bool opEquals(const Position rhs) const {
    return this.x == rhs.x && this.y == rhs.y;
  }

  int opCmp(Position rhs) const {
    if (this.x < rhs.x) return -1;
    if (this.x > rhs.x) return 1;
    if (this.y < rhs.y) return -1;
    if (this.y > rhs.y) return 1;
    return 0;
  }
}

Position[] get_antinode(Position[] antenas) {
  Position[] ret;
  foreach (a; antenas) {
    foreach (b; antenas) {
      if (a == b) continue;
      auto vec = a - b;
      auto antinode = a + vec;
      ret ~= antinode;
    }
  }
  return ret;
}

Position[][dchar] get_antenas(const Dinput content) {
  Position[][dchar] antenas;

  foreach (x, line; content.map) {
    foreach (y, car; line) {
      if (isAlphaNum(car)) {
        antenas[car] ~= Position(y, x);
      }
    }
  }
  return antenas;
}

ulong part1(const Dinput content) {
  auto antenas = get_antenas(content);
  auto length = content.map.length;
  auto width = content.map[0].length;
  auto antinodes = antenas.values
    .map!(get_antinode)
    .join
    .filter!(a => a.x >= 0 && a.x < width && a.y >= 0 && a.y < length)
    .array
    .sort
    .uniq;

  return antinodes.count;
}

ulong part2(const Dinput content) {
  auto antenas = get_antenas(content);
  auto length = content.map.length;
  auto width = content.map[0].length;

  Position[] get_antinode2(Position[] antenas) {
    Position[] ret = antenas;
    foreach (a; antenas) {
      foreach (b; antenas) {
        if (a == b) continue;
        auto vec = a - b;
        if (vec.x == 0 && vec.y == 0) continue;
        auto antinode = a + vec;
        while (antinode.x >= 0 && antinode.x < width && antinode.y >= 0 && antinode.y < length) {
          ret ~= antinode;
          antinode = antinode + vec;
        }
      }
    }
    return ret;
  }

  auto antinodes = antenas.values
    .map!(get_antinode2)
    .join
    .array
    .sort
    .uniq;
  /*
  writeln(antinodes);
  
  auto map2 = cast(dchar[][])content.map.dup;

  foreach (fa; antinodes) {
      map2[fa.y][fa.x] = '#';
  }
  foreach (l; map2) {
    writeln(l);
  }
  */
  return antinodes.count;
}

struct Dinput {
  dchar[][] map;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;

  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() != 0) {
      din.map ~= line.array;
    }
  }

  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
