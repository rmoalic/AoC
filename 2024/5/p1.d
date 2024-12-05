import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range;

string input_file = "input.txt";

int get_middle(const int[] arr) {
  return arr[arr.length / 2];
}

bool check_page(const int[] page, const Dinput content) {
  auto nb_rules = content.ordering_rule_first.length;
  foreach (nb, p; page) {
    for (int i = 0; i < nb_rules; i++) {
      if (content.ordering_rule_first[i] == p) {
        auto second = content.ordering_rule_second[i];
        if (page[0..nb].canFind(second)) return false;
      }
      if (content.ordering_rule_second[i] == p) {
        auto first = content.ordering_rule_first[i];
        if (page[nb..$].canFind(first)) return false;

      }
    }
  }
  return true;
}

ulong part1(const Dinput content) {
  ulong ret = 0;

  foreach (page; content.pages) {
    if (check_page(page, content)) {
      ret += get_middle(page);
    }
  }

  return ret;
}

void try_fix_page(ref int[] page, const Dinput content) {
  auto nb_rules = content.ordering_rule_first.length;
  foreach (nb, p; page) {
    for (int i = 0; i < nb_rules; i++) {
      if (content.ordering_rule_first[i] == p) {
        auto second = content.ordering_rule_second[i];
        auto s = page[0..nb].countUntil(second);
        if (s != -1) {
          swap(page[nb], page[s]);
        }
      }
      if (content.ordering_rule_second[i] == p) {
        auto first = content.ordering_rule_first[i];
        auto s = page[nb..$].countUntil(first);
        if (s != -1) {
          swap(page[nb], page[nb + s]);
        }
      }
    }
  }
}

ulong part2(const Dinput content) {
  ulong ret = 0;

  foreach (page; content.pages) {
    if (! check_page(page, content)) {
      auto np = page.dup;

      int fix_attempts = 0;
      const int max_attemps = 10;
      do {
        try_fix_page(np, content);
        fix_attempts += 1;
      } while (! check_page(np, content) && fix_attempts < max_attemps);

      if (fix_attempts < max_attemps) {
        ret += get_middle(np);
      } else {
        writeln("fix did not work");
      }
    }
  }
  return ret;
}

struct Dinput {
  int[] ordering_rule_first;
  int[] ordering_rule_second;
  int[][] pages;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;
  int ppart = 0;
  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() == 0) {
      ppart++;
      continue;
    }
    if (ppart == 0) {
      auto t = line.split("|").map!(to!int);
      din.ordering_rule_first ~= t[0];
      din.ordering_rule_second ~= t[1];
    } else if (ppart == 1) {
      din.pages ~= line.split(",").map!(to!int).array;
    } else {
      break;
    }
  }
  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
