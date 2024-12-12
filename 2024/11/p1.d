import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range, std.container, std.math, std.functional, std.typecons, std.bigint;

string input_file = "input.txt";

uint nb_digits(BigInt n) {
  if (n == 0) return 0;
  if (n < 0) n = -n;
  uint ret = 0;
  do {
    n /= 10;
    ret += 1;
  } while (n > 0);
  return ret;
}

bool is_odd(long n) {
  return n & 1;
}

BigInt[] blink(BigInt[] input) {
  BigInt[] ret;
  foreach (d; input) {
    if (d == 0) {
      ret ~= d + 1;
    } else {
      auto digits = nb_digits(d);
      if (! is_odd(digits)) {
        auto mid = pow(10, digits / 2);
        auto p1 = d / mid;
        auto p2 = d - (p1 * mid);
        ret ~= p1;
        ret ~= p2;
      } else {
        ret ~= d * 2024;
      }
    }
  }
  return ret;
}

ulong part1(in Dinput content) {
  auto data = cast(BigInt[]) content.input.dup;
  foreach (i; iota(25)) {
    data = blink(data);
  }
  return data.length;
}

alias progress_memoize = memoize!(progress);

BigInt[] progress(BigInt input) {
  if (input == 0) return [input + 1];
  auto digits = nb_digits(input);

  if (! is_odd(digits)) {
    BigInt mid = pow(10, digits / 2);
    BigInt p1 = input / mid;
    BigInt p2 = input - (p1 * mid);
    return [p1, p2];
  } else {
    return [input * 2024];
  }
}

ulong[BigInt] progress2(ulong[BigInt]  step) {
  ulong[BigInt] ret;
  foreach (pair; step.byKeyValue()) {
    auto p = progress_memoize(pair.key);
    foreach (v; p) {
      ret[v] += pair.value;
    }
  }

  return ret;
}

BigInt process(BigInt[] input, uint steps) {
  ulong[BigInt] counter = cast(ulong[BigInt])input.sort.group.assocArray;
  foreach (i; iota(steps)) {
    counter = progress2(counter);
    //assert (! counter.byKey.map!(c => c.ulongLength).array.any!(c => c > 1));
  }
  BigInt ret = 0;
  foreach (b; counter.byValue) {
    ret += b;
  }
  return ret;
}

BigInt part2(in Dinput content) {
  return process(content.input.dup, 75);
}

struct Dinput {
  BigInt[] input;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;

  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() != 0) {
      din.input ~= line.split(" ").map!(to!BigInt).array;
    }
  }

  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
