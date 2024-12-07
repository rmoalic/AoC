import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range, std.typecons, core.exception;

string input_file = "input.txt";

struct Point {
  long x;
  long y;
  
  Point opBinary(string op : "+")(Point b) {
    return Point(this.x + b.x, this.y + b.y);
  }
}

Point find_start(const Dinput content) {
  foreach (i, line; content.map) {
    foreach (j, c; line) {
      if (c == MAP_MARKS.START) {
        return Point(cast(int) i, cast(int) j);
      }
    }
  }
  assert(0);
}

void step(ref Point position, ref DIRECTION dir, const Dinput content) {
  auto new_pos = position + vector(dir);
  if (content.map[new_pos.x][new_pos.y] == MAP_MARKS.WALL) {
    dir = rotate90(dir);
  } else {
    position = new_pos;
  }
}

ulong part1(const Dinput content) {
  ulong ret = 0;
  auto start = find_start(content);

  Point curr_pos = start;
  DIRECTION curr_dir = DIRECTION.NORTH;

  bool[][] marked = new bool[][](content.width, content.height);
  auto steps_count = 0;
  try {
    do {
      if (! marked[curr_pos.x][curr_pos.y]) {
        ret += 1;
        marked[curr_pos.x][curr_pos.y] = true;
      }
      step(curr_pos, curr_dir, content);
      steps_count++;
    } while (steps_count < long.max);
  } catch (core.exception.ArrayIndexError e) { }
  writeln("steps: ", steps_count);
  return ret;
}

ulong part2(const Dinput content) {
  ulong ret = 0;
  auto start = find_start(content);

  auto contentd = cast(Dinput)content;
  
  foreach (i, line; contentd.map) {
    foreach (j, c; line) {
      if (c == MAP_MARKS.WALL) continue;
      contentd.map[i][j] = MAP_MARKS.WALL;

      long steps = 0;
      static const long max_steps = 50000;
      Point curr_pos = start;
      DIRECTION curr_dir = DIRECTION.NORTH;
      try {
        do {
          step(curr_pos, curr_dir, contentd);
          steps++;
        } while (steps < max_steps);
      } catch (core.exception.ArrayIndexError e) {}
      if (steps >= max_steps) {
        ret += 1;
      }
      
      contentd.map[i][j] = MAP_MARKS.EMPTY;
    }

    writeln(i/(cast(float)contentd.height));
  }
  
  return ret;
}

enum MAP_MARKS{
  EMPTY = '.',
  WALL = '#',
  START = '^'
}

enum DIRECTION {
  NORTH,
  SOUTH,
  EAST,
  WEST
}

DIRECTION rotate90(DIRECTION dir) {
  final switch (dir) {
  case DIRECTION.NORTH: return DIRECTION.EAST;
  case DIRECTION.EAST: return DIRECTION.SOUTH;
  case DIRECTION.SOUTH: return DIRECTION.WEST;
  case DIRECTION.WEST: return DIRECTION.NORTH;
  }
}

Point vector(DIRECTION dir) {
  final switch (dir) {
  case DIRECTION.NORTH: return Point(-1, 0);
  case DIRECTION.EAST: return Point(0, 1);
  case DIRECTION.SOUTH: return Point(1,0);
  case DIRECTION.WEST: return Point(0, -1);
  }
}

struct Dinput {
  ulong width;
  ulong height;
  MAP_MARKS[][] map;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;

  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() != 0) {
      auto t = line.map!(to!MAP_MARKS).array;
      din.map ~= t;
    }
  }
  din.height = din.map.length;
  din.width = din.map[0].length;
  
  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
