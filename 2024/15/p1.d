import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range;

string input_file = "input.txt";

struct Position {
  long x;
  long y;

  Position opBinary(string op : "+")(Position rhs) {
    return Position(this.x + rhs.x, this.y + rhs.y);
  }
}

Position find_start(Block[][] map) {
  foreach (i, line; map) {
    foreach (j, c; line) {
      if (c == Block.START) {
        return Position(cast(long) i, cast(long) j);
      }
    }
  }
  assert(0);
}

Position move(ref Block[][] map, Position to_move, Direction direction) {
  auto new_pos = to_move + direction.vector;
  auto c_c = map[to_move.x][to_move.y];
  auto n_c = map[new_pos.x][new_pos.y];
  if (n_c == Block.EMPTY) {
    map[to_move.x][to_move.y] = Block.EMPTY;
    map[new_pos.x][new_pos.y] = c_c;
    return new_pos;
  } else if (n_c == Block.WALL) {
    return to_move;
  } else if (n_c == Block.BOX) {
    auto bm = move(map, new_pos, direction);
    if (bm != new_pos) {
      map[to_move.x][to_move.y] = Block.EMPTY;
      map[new_pos.x][new_pos.y] = c_c;
      return new_pos;
    } else {
      return to_move;
    }
  }
  assert(0);
}

bool can_move(ref Block[][] map, Position to_move, Direction direction, int deep) {
  string tab = "-".repeat(deep).join;
  writeln(tab, "> ", to_move, " (",direction,")");
  bool ret = true;
  auto new_pos = to_move + direction.vector;
  auto curr = map[to_move.x][to_move.y];
  auto next = map[new_pos.x][new_pos.y];
  writeln(tab, "new_pos: ", new_pos," next: ", next);

  if (next == Block.WALL) {
    writeln(tab, "FALSE");
    ret &= false;
  } else if (next == Block.EMPTY || next == Block.START) {
    writeln(tab, "TRUE");
    ret &= true;
  } else if (next == Block.BOXL || next == Block.BOXR) {
    auto other_box_dir = (next != Block.BOXR ? Direction.RIGHT : Direction.LEFT);
    auto other_box_pos = new_pos + other_box_dir.vector;
    writeln(tab, other_box_dir);
    if (other_box_dir == direction) {
      writeln(tab, "ignore a");
      ret &= can_move(map, other_box_pos, direction, deep + 2);
    } else if (other_box_dir == direction.rotate180) {
      writeln(tab, "ignore b");
      ret &= can_move(map, new_pos, direction, deep + 2);
    } else if (direction == Direction.DOWN || direction == Direction.UP){
      writeln(tab, "branch");
      ret &= (can_move(map, new_pos, direction, deep + 2) && can_move(map, other_box_pos, direction, deep + 2));
      }
  } else {
    assert(0);
  }
  writeln(tab, "ret: ", ret);
  return ret;
}


Position move_force(ref Block[][] map, Position to_move, Direction direction) {
  auto new_pos = to_move + direction.vector;
  auto curr = map[to_move.x][to_move.y];
  auto next = map[new_pos.x][new_pos.y];

  if (next == Block.BOXL || next == Block.BOXR) {

    auto other_box_dir = (next != Block.BOXR ? Direction.RIGHT : Direction.LEFT);
    auto other_box_pos = new_pos + other_box_dir.vector;

    if (other_box_dir == direction) {
      move_force(map, new_pos, direction);
    } else if (other_box_dir == direction.rotate180) {
      move_force(map, new_pos, direction);
    } else if (direction == Direction.DOWN || direction == Direction.UP){
      move_force(map, new_pos, direction);
      move_force(map, other_box_pos, direction);
    }

  }
  map[to_move.x][to_move.y] = Block.EMPTY;
  map[new_pos.x][new_pos.y] = curr;
  return new_pos;
}

void print_map(Block[][] map) {
  foreach (l; map) {
    writeln(l.map!(to!char));
  }
}

ulong get_map_score(Block[][] map) {
  ulong ret = 0;
  foreach (i, l; map) {
    foreach (j,c; l) {
      if (c == Block.BOX || c == Block.BOXL) {
        ret += (100 * i + j);
      }
    }
  }
  return ret;
}

ulong part1(in Dinput content) {
  auto map = content.map.map!(x => x.dup).array;
  auto start = find_start(map);
  auto curr = start;
  //print_map(map);
  foreach (dir; content.directions) {
    curr = move(map, curr, dir);
  }
  //print_map(map);
  return get_map_score(map);
}

Block[][] p2(Block[][] map) {
  Block[][] ret;
  foreach (l; map) {
    ret ~= l.substitute([Block.WALL], [Block.WALL, Block.WALL],
                        [Block.BOX], [Block.BOXL, Block.BOXR],
                        [Block.EMPTY], [Block.EMPTY, Block.EMPTY],
                        [Block.START], [Block.START, Block.EMPTY]).array;
  }
  return ret;
}

ulong part2(in Dinput content) {
  auto map = content.map.map!(x => x.dup).array.p2;
  auto start = find_start(map);

  auto curr = start;
  //print_map(map);

  foreach (dir; content.directions) {
    writeln(curr, " ", dir);
    if (can_move(map, curr, dir, 1)) {
      writeln("can_move");
      curr = move_force(map, curr, dir);
      //print_map(map);

    }

  }
  print_map(map);
  return get_map_score(map);
}

enum Block: char {
  EMPTY = '.',
  WALL = '#',
  BOX = 'O',
  START = '@',
  BOXL = '[',
  BOXR = ']',
}

enum Direction: char {
  UP = '^',
  DOWN = 'v',
  LEFT = '<',
  RIGHT = '>'
}

Position vector(Direction dir) {
  final switch (dir) {
  case Direction.UP: return Position(-1, 0);
  case Direction.RIGHT: return Position(0, 1);
  case Direction.DOWN: return Position(1,0);
  case Direction.LEFT: return Position(0, -1);
  }
}

Direction rotate180(Direction dir) {
  final switch (dir) {
  case Direction.UP: return Direction.DOWN;
  case Direction.RIGHT: return Direction.LEFT;
  case Direction.DOWN: return Direction.UP;
  case Direction.LEFT: return Direction.RIGHT;
  }
}

struct Dinput {
  Block[][] map;
  Direction[] directions;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;

  int part = 0;
  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() == 0) part++;
    if (part == 0) {
      din.map ~= line.map!(to!Block).array;
    } else if (part == 1) {
      din.directions ~= line.map!(to!Direction).array;
    }
  }
  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
