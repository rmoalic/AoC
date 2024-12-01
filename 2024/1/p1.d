import std.stdio, std.file, std.conv, std.algorithm, std.container.array, std.array, std.typecons, std.string, std.range, std.math;

string input_file = "input.txt";

ulong part1(const Line[] content) {
  int[] l1;
  int[] l2;

  foreach (t; content) {
    l1 ~= t[0];
    l2 ~= t[1];
  }

  auto zipped = zip(l1.sort, l2.sort);
  int[] acc;
  foreach (e1, e2; zipped) {
    acc ~= abs(e1 - e2);
  }

  return acc.sum;
}

ulong part2(const Line[] content) {
  ulong ret;

  int[] l1;
  int[] l2;

  foreach (t; content) {
    l1 ~= t[0];
    l2 ~= t[1];
  }

  auto nb_times_appeared = l2.sort.group.assocArray;
  foreach (e; l1) {
    ret += e * nb_times_appeared.get(e, 0);
  }

  return ret;
}

alias Line = Tuple!(int, int);

void main() {
  File input = File(input_file, "r");
  Line[] acc;
  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() > 0) {
      auto parts = line.split();
      auto p = parts.map!(to!int);
      acc ~= Line(p[0], p[1]);
    }
  }
  auto p1 = part1(acc);
  auto p2 = part2(acc);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
