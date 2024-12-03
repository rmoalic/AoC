import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range, std.regex;

string input_file = "input.txt";

auto r = regex(r"mul\(([0-9]{1,3}),([0-9]{1,3})\)");

ulong part1(const string content) {
  ulong ret = 0;

  auto matchs = content.matchAll(r);
  foreach (m; matchs) {
    int result = to!int(m[1]) * to!int(m[2]);
    ret += result;
  }

  return ret;
}

int process(string rest, bool activated) {
  int ret = 0;
  if (rest.length == 0) return 0;
  if (activated) {
    auto a = rest.findSplit("don't()");
    auto matchs = a[0].matchAll(r);

    foreach (m; matchs) {
      int result = to!int(m[1]) * to!int(m[2]);
      ret += result;
    }
    return ret + process(a[2], false);
  } else {
    auto a = rest.findSplit("do()");
    return process(a[2], true);
  }
}

ulong part2(const string content) {
  return process(content, true);
}

void main() {
  File input = File(input_file, "r");
  string acc;
  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() > 0) {
      acc ~= line;
    }
  }
  auto p1 = part1(acc);
  auto p2 = part2(acc);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
