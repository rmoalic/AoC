import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range, std.container, std.math, std.functional;

string input_file = "input.txt";

uint nb_digits(long n) {
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

long[] blink(ref long[] input) {
  long[] ret;
  foreach (d; input) {
    if (d == 0) {
      ret ~= 1;
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
  auto data = cast(long[]) content.input.dup;
  foreach (i; iota(25)) {
    //writeln("After ", i + 1, " blink");
    data = blink(data);
    //writeln(data.length);
    //writeln(data);
  }
  return data.length;
}

ulong count_progress(long input, uint steps) {
  if (steps == 0) return 1;
  if (input == 0) return count_progress(1, steps - 1);
  auto digits = nb_digits(input);

  if (! is_odd(digits)) {
    auto mid = pow(10, digits / 2);
    auto p1 = input / mid;
    auto p2 = input - (p1 * mid);
    return count_progress(p1, steps - 1) + count_progress(p2, steps - 1);
  } else {
    return count_progress(input * 2024, steps - 1);
  }
}

alias progress_memoize = memoize!(progress, 9604);

long[] progress(long input) {
  if (input == 0) return [1];
  auto digits = nb_digits(input);

  if (! is_odd(digits)) {
    auto mid = pow(10, digits / 2);
    auto p1 = input / mid;
    auto p2 = input - (p1 * mid);
    return [p1, p2];
  } else {
    return [input * 2024];
  }
}

alias progress2_memoize = memoize!progess2;

long[] progess2(long[] step) {
  long[] ret;
  foreach (v; step) {
    ret ~= progress_memoize(v);
  }
  return ret;
}

ulong process(long input, uint steps) {
  long[] step = [input];
  auto count = 0;
  foreach (i; iota(steps)) {
    step = progress2_memoize(step);
    count++;
    writeln("finished step: ", count);
  }
  return step.length;
}

ulong part2(in Dinput content) {
  auto data = cast(long[]) content.input.dup;
  ulong ret = 0;
  foreach (nb, d; content.input) {
    ret += process(d, 75);
    writeln("total progess: ", nb / (content.input.length - 1 * 1.0) * 100.0);
  }

  return ret;}

struct Dinput {
  long[] input;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;

  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() != 0) {
      din.input ~= line.split(" ").map!(to!long).array;
    }
  }
  writeln(din);

  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
