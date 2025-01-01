import std.stdio, std.file, std.conv, std.algorithm, std.string, std.math, std.range, std.parallelism, std.bigint, std.functional;

string input_file = "input.txt";

bool is_possible(ref Tree tree, string onsen) {
  if (onsen.length == 0) return true;
  string[] found_prefix = tree.prefix(onsen);
  if (! found_prefix.empty) {
    bool ret = false;
    foreach (prefix; found_prefix) {
      ret |= is_possible(tree, onsen[prefix.length .. $]);
      if (ret) break;
    }
    return ret;
  }

  return false;
}

ulong count_posibilities(ref Tree tree, string onsen) {
  ulong loop(string onsen, ulong pos) {
    ulong ret = 0;
    if (onsen.length == pos) {
      return 1;
    }
    string[] found_prefix = tree.prefix(onsen[pos..$]);
    if (! found_prefix.empty) {
      foreach (prefix; found_prefix) {
        ret += memoize!loop(onsen, pos + prefix.length);
      }
    }
    return ret;
  }

  return loop(onsen, 0);
}


struct Tree {
  dchar elem;
  bool terminal;
  Tree[] branch;
}

void insert(ref Tree tree, string str) {
  Tree* curr = &tree;
  foreach (c; str) {
    auto f = curr.branch.find!(e => e.elem == c);
    if (f.empty) {
      auto new_branch = Tree(c, false, []);
      curr.branch ~= new_branch;
      f = curr.branch.find!(e => e.elem == c); // ??? how to prevent copy ???
    }
    curr = &f[0];
  }
  curr.terminal = true;
}

string[] prefix(ref Tree tree, string str) {
  Tree* curr = &tree;
  string[] ret;
  foreach (nb, c; str) {
    auto f = curr.branch.find!(e => e.elem == c);
    if (f.empty) {
      break;
    }
    curr = &f[0];
    if (curr.terminal) {
      ret ~= str[0..nb + 1];
    }
  }

  return ret;
}

Tree tree_from_prefix(string[] onsen_prefix) {
  Tree ret = {'\0', false, []};
  foreach (prefix; onsen_prefix) {
    ret.insert(prefix);
  }
  return ret;
}

ulong part1(in Dinput content) {
  ulong ret = 0;
  auto tree = tree_from_prefix(cast(string[])content.towel_patterns);
  foreach (nb, onsen; content.onsen) {
    if (is_possible(tree, onsen)) {
      ret += 1;
    }
  }

  return ret;
}

ulong part2(in Dinput content) {
  ulong ret = 0;
  auto tree = tree_from_prefix(cast(string[])content.towel_patterns);
  foreach (nb, onsen; content.onsen) {
    ret += count_posibilities(tree, onsen);
  }

  return ret;
}

struct Dinput {
  string[] towel_patterns;
  string[] onsen;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;

  int part = 0;
  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() == 0) {
      part++;
      continue;
    }
    if (part == 0) {
      din.towel_patterns = line.split(", ");
    } else if (part == 1) {
      din.onsen ~= line;
    }
  }
  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
