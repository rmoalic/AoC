import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range, std.container, std.math, std.functional, std.typecons, std.bigint;

string input_file = "input.txt";

BigInt[2] solve(Game game) {
  auto delta = abs((game.bA[0] * game.bB[1]) - (game.bB[0] * game.bA[1]));
  auto delta1 = abs((game.prize[0] * game.bB[1]) - (game.bB[0] * game.prize[1]));
  auto delta2 = abs((game.bA[0] * game.prize[1]) - (game.prize[0] * game.bA[1]));

  auto x1 = cast(double) delta1 / (cast(double) delta);
  auto x2 = cast (double) delta2 / (cast(double) delta);

  if (floor(x1) == x1 && floor(x2) == x2) {
    return [BigInt(cast(ulong)floor(x1)),  BigInt(cast(ulong)floor(x2))];
  } else {
    throw new Exception("no result");
  }
}

BigInt part1(in Dinput content) {
  BigInt ret;

  foreach (game; content.games) {
    try {
      auto res = solve(game);
      //writeln(res);
      if (res[0] >= 100 || res[1] >= 100) {
        writeln("more than 100");
        continue;
      }
      ret += 3 * res[0] + 1 * res[1];
    } catch (Exception e) { /*writeln(e);*/ }
  }

  return ret;
}

Game p2(Game p) {
  p.prize[0] += 10000000000000;
  p.prize[1] += 10000000000000;
  return p;
}

BigInt part2(in Dinput content) {
  BigInt ret;

  foreach (game; content.games) {
    try {
      auto res = solve(game.p2);
      //writeln(res);
      ret += 3 * res[0] + 1 * res[1];
    } catch (Exception e) { /*writeln(e);*/ }
  }

  return ret;
}

struct Game {
  BigInt[2] bA;
  BigInt[2] bB;
  BigInt[2] prize;
}

struct Dinput {
  Game[] games;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;

  Game tmp;

  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() != 0) {
      auto s1 = line.split(":");
      auto s2 = s1[1].split(",");

      if (s1[0] == "Button A") {
        tmp.bA[0] = s2[0][3..$].to!BigInt;
        tmp.bA[1] = s2[1][3..$].to!BigInt;
      } else if (s1[0] == "Button B") {
        tmp.bB[0] = s2[0][3..$].to!BigInt;
        tmp.bB[1] = s2[1][3..$].to!BigInt;
      } else if (s1[0] == "Prize") {
        tmp.prize[0] = s2[0][3..$].to!BigInt;
        tmp.prize[1] = s2[1][3..$].to!BigInt;
      } else {
        assert(0);
      }
    } else {
      din.games ~= tmp;
    }
  }

  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
