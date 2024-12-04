import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range, core.exception;

string input_file = "input.txt";

// - remove unnecesary recursion count_word2
// - do bound check instead of exception

int count_word2(const string[] content, int i, int j, int di, int dj, string word) {
  if (word.length == 0) return 1;
  auto searched_letter = word[0];
  auto rest = word[1..$];

  try {
    if (content[i + di][j + dj] == searched_letter) {
      return count_word2(content, i+di, j+dj, di, dj, rest);
    }
  } catch (core.exception.ArrayIndexError e) {}
  return 0;
}

int count_word(const string[] content, int i, int j, string word) {
  auto searched_letter = word[0];
  auto rest = word[1..$];

  static int[2][8] dir = [[-1, 1], [-1, -1], [-1, 0], [0, -1], [0, +1], [+1, -1], [+1, 0], [+1, +1]];
  int ret = 0;
  foreach (d; dir) {
    auto dx = d[0];
    auto dy = d[1];
    try {
      auto curr_letter = content[i + dx][j + dy];
      if (curr_letter == searched_letter) {
        ret +=  count_word2(content, i + dx, j + dy, dx, dy, rest);
      }
    } catch (core.exception.ArrayIndexError e) {}
  }

  return ret;
}

ulong part1(const string[] content) {
  ulong ret = 0;

  auto line_size = content[0].length;
  for (int i = 0; i < content.length; i++) {
    for (int j = 0; j < line_size; j++) {
      auto c = content[i][j];
      if (c == 'X') {
        ret += count_word(content, i, j, "MAS");
      }
    }
  }

  return ret;
}

bool is_xmas(const string[] content, int i, int j) {
  if (content[i][j] != 'A') return false;
  bool ret = true;
  try {
    ret &= content[i - 1][j - 1] != content[i + 1][j + 1];
    ret &= content[i + 1][j - 1] != content[i - 1][j + 1];
    ret &= (content[i - 1][j - 1] == 'S' || content[i - 1][j - 1] == 'M');
    ret &= (content[i + 1][j + 1] == 'S' || content[i + 1][j + 1] == 'M');
    ret &= (content[i + 1][j - 1] == 'S' || content[i + 1][j - 1] == 'M');
    ret &= (content[i - 1][j + 1] == 'S' || content[i - 1][j + 1] == 'M');
  } catch (core.exception.ArrayIndexError e) {return false;}
  return ret;
}

ulong part2(const string[] content) {
  ulong ret = 0;

  auto line_size = content[0].length;
  for (int i = 0; i < content.length; i++) {
    for (int j = 0; j < line_size; j++) {
      if (is_xmas(content, i, j)) {
        ret += 1;
      }
    }
  }
  return ret;
}

void main() {
  File input = File(input_file, "r");
  string[] acc;
  ulong line_size;
  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() > 0) {
      line_size = line.count();
      acc ~= line;
    }
  }
  auto p1 = part1(acc);
  auto p2 = part2(acc);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
