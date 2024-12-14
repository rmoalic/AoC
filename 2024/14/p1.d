import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range, std.container, std.math, std.functional, std.traits, std.typecons, std.bigint;

string input_file = "input.txt";


pure T mod1(T)(T n, T d) if(isIntegral!(T)){
  T r = n % d;
  return sgn(r) == -(sgn(d)) ? r + d : r;
}

struct Position {
  long x;
  long y;

  Position mod(ref Position rhs) {
    return Position(mod1!long(this.x, rhs.x), mod1!long(this.y, rhs.y));
  }

  Position opBinary(string op : "%")(Position rhs) {
    return Position(this.x % rhs.x, this.y % rhs.y);
  }

  Position opBinary(string op : "%")(long rhs) {
    return Position(this.x % rhs, this.y % rhs);
  }

  Position opBinary(string op : "-")(Position rhs) {
    return Position(this.x - rhs.x, this.y - rhs.y);
  }

  Position opBinary(string op : "+")(Position rhs) {
    return Position(this.x + rhs.x, this.y + rhs.y);
  }

  Position opBinary(string op : "*")(Position rhs) {
    return Position(this.x * rhs.x, this.y * rhs.y);
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

void print_board_egg(Position size, Position[] robots) {
  auto board = new int[size.x * size.y];

  foreach (robot; robots) {
    board[robot.y * size.x + robot.x]++;
  }
  bool here = false;
  foreach (l; board.chunks(size.x)) {
    if (l.sum() > 25) here = true;
  }

  if (here) {
    writeln(" HERE ");
    foreach (l; board.chunks(size.x)) {
      writeln(l.map!(to!string).substitute("0", " ").join(""));
    }
  }
}

void print_board(Position size, Position[] robots) {
  auto board = new int[size.x * size.y];

  foreach (robot; robots) {
    board[robot.y * size.x + robot.x]++;
  }
  foreach (l; board.chunks(size.x)) {
    writeln(l.map!(to!string).substitute("0", " ").join(""));
  }
}


int[4] get_chunks_sum(Position size, Position[] last_pos) {
  int[4] ret;
  auto mid_x = size.x / 2;
  auto mid_y = size.y / 2;
  writeln(mid_x, " & ", mid_y);

  auto pos = last_pos.sort;
  ret[0] = pos.filter!(p => p.x < mid_x && p.y < mid_y).group.fold!((a, e) => a + e[1])(0);
  ret[1] = pos.filter!(p => p.x > mid_x && p.y < mid_y).group.fold!((a, e) => a + e[1])(0);
  ret[2] = pos.filter!(p => p.x < mid_x && p.y > mid_y).group.fold!((a, e) => a + e[1])(0);
  ret[3] = pos.filter!(p => p.x > mid_x && p.y > mid_y).group.fold!((a, e) => a + e[1])(0);
  return ret;
}

ulong part1(in Dinput content) {
  auto steps = 100;
  Position[] last_pos;
  foreach (Robot robot; content.robots) {
    auto pos = (robot.p + (robot.v * steps)).mod(cast(Position)content.size);
    last_pos ~= pos;
  }
  //print_board(content.size, last_pos);
  auto c = get_chunks_sum(content.size, last_pos);
  return c.fold!((a,e) => a * e)(1);
}

void part2(in Dinput content) {
  foreach (steps; 0..10000) {
    writeln("--------- steps ", steps, " -------------");
    Position[] last_pos;
    foreach (Robot robot; content.robots) {
      auto pos = (robot.p + (robot.v * steps)).mod(cast(Position)content.size);
      last_pos ~= pos;
    }
    print_board_egg(content.size, last_pos);
  }
}

struct Robot {
  Position p;
  Position v;
}

struct Dinput {
  Position size;
  Robot[] robots;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;

  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() != 0) {
      Robot tmp;
      auto s1 = line.split(" ");
      auto p = s1[0][2..$].split(",").array.map!(to!long).array;
      auto v = s1[1][2..$].split(",").array.map!(to!long).array;
      tmp.p = Position(p[0], p[1]);
      tmp.v = Position(v[0], v[1]);
      din.robots ~= tmp;
    }
  }
  din.size = Position(101, 103);

  writeln(din);

  auto p1 = part1(din);
  part2(din);

  writeln("part1: ", p1);
  writeln("part2: (p1 > test.log; less less.log; #search for HERE and look for tree");}
