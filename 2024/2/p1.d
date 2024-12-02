import std.stdio, std.file, std.conv, std.algorithm, std.container.array, std.array, std.typecons, std.string, std.range, std.math, std.meta;

string input_file = "input.txt";

bool is_valid(const int[] c) {
  if (! c.slide(2).all!("a[0] > a[1]")) {
    if (! c.slide(2).all!("a[0] < a[1]"))
      return false;
  }
  if (! c.slide(2).map!("abs(a[0] - a[1])").all!("a > 0 && a < 4")) {
    return false;
  }
  return true;
}

ulong part1(const int[][] content) {
  ulong ret = 0;

  foreach (t; content) {
    if (is_valid(t)) {
      ret += 1;
    }
  }

  return ret;
}

ulong part2(const int[][] content) {
  ulong ret;

  foreach (t; content) {
    if (is_valid(t)) {
      ret += 1;
    } else {
      for (int i = 0; i < t.length; i++) {
        auto t2 = t.dup.remove(i);
        if (is_valid(t2)) {
          ret += 1;
          break;
        }
      }
    }
  }

  return ret;
}

void main() {
  File input = File(input_file, "r");
  int[][] acc;
  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() > 0) {
      auto p = line.split().map!(to!int).array;
      acc ~= p;
    }
  }
  auto p1 = part1(acc);
  auto p2 = part2(acc);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
