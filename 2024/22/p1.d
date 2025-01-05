import std.stdio, std.file, std.conv, std.algorithm, std.string, std.math, std.range;

string input_file = "input.txt";

static const PRUNE = 16_777_216;
auto randomGenerator(ulong initial_secret) {
    ulong secret = initial_secret;
    return (){
      secret = ((secret * 64) ^ secret) % PRUNE;
      secret = ((secret / 32) ^ secret) % PRUNE;
      secret = ((secret * 2048) ^ secret) % PRUNE;
      return secret;
    };
}

unittest {
  assert((42 ^ 15) == 37);
  assert(100_000_000 % PRUNE == 16_113_920);
  assert(generate(randomGenerator(123)).take(10).array == [15887950, 16495136, 527345, 704524, 1553684, 12683156, 11100544, 12249484, 7753432, 5908254]);
}

ulong part1(in Dinput content) {
  ulong ret = 0;

  assert(generate(randomGenerator(1)).take(2000).array[$ - 1] == 8_685_429);

  foreach (secret; content.initial_secret) {
    auto gen = generate(randomGenerator(secret));
    auto num = gen.take(2000).array[$ - 1];
    // writeln(secret, ": ", num);
    ret += num;
  }

  return ret;
}

void shift(ref byte[4] arr) {
  arr[0] = arr[1];
  arr[1] = arr[2];
  arr[2] = arr[3];
  arr[3] = 0;
}

ulong part2(in Dinput content) {
  int[byte[4]] possible_sequence;
  foreach (secret; content.initial_secret) {
    bool[byte[4]] sequence_seen;
    auto gen = generate(randomGenerator(secret));
    byte[4] diff;
    byte inspos = 0;
    auto last = secret % 10;
    foreach (number; gen.take(2000)) {
      assert(last < 10);
      byte digit = cast (byte) (number % 10);
      diff[inspos] = cast(byte) (digit - last);

      if (inspos >= 3) {
        if (! sequence_seen.get(diff, false)) { // had to get a hint for that
          possible_sequence[diff] += digit;
          sequence_seen[diff] = true;
        }
        diff.shift;
      } else {
        inspos++;
      }

      last = digit;
    }
  }

  auto max = possible_sequence.byKeyValue.maxElement!(e => e.value);
  writeln(max.key);
  return max.value;
}

struct Dinput {
  ulong[] initial_secret;
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
      din.initial_secret ~= line.to!ulong;
    }
  }
  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
