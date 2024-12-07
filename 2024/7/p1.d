import std.stdio, std.file, std.conv, std.algorithm, std.string, std.range, std.typecons, core.exception;

string input_file = "input.txt";

struct BridgeData {
  long d;

  BridgeData opBinary(string op : "+")(const BridgeData b) {
    return BridgeData(this.d + b.d);
  }

  BridgeData opBinary(string op : "*")(const BridgeData b) {
    return BridgeData(this.d * b.d);
  }

  BridgeData opBinary(string op : "|")(const BridgeData b) {
    return BridgeData(to!long(to!string(this.d) ~ to!string(b.d)));
  }
}

struct PermutationsWithRepetitions(T) { // https://rosettacode.org/wiki/Permutations_with_repetitions#D
  const T[] data;
  const int n;

  int opApply(int delegate(ref T[]) dg) {
    int result;
    T[] aux;

    if (n == 1) {
      foreach (el; data) {
        aux = [el];
        result = dg(aux);
        if (result) goto END;
      }
    } else {
      foreach (el; data) {
        foreach (p; PermutationsWithRepetitions(data, n - 1)) {
          aux = el ~ p;
          result = dg(aux);
          if (result) goto END;
        }
      }
    }

  END:
    return result;
  }
}

auto permutationsWithRepetitions(T)(T[] data, in int n) pure nothrow
     in {
       assert(!data.empty && n > 0);
     } body {
  return PermutationsWithRepetitions!T(data, n);
 }

ulong partx(const Dinput[] content, string[] all_ops) {
  ulong ret = 0;

  foreach (pb; content) {
    //writeln(pb);
    auto nb_op = pb.components.length - 1;
    auto all_combs = all_ops.permutationsWithRepetitions(cast(int) nb_op);
    //writeln(nb_op, " ", all_combs);
    foreach (ops; all_combs) {
      auto curr_idx = 1;
      BridgeData[] stack;
      stack ~= cast(BridgeData) pb.components[0];
      //writeln(ops);
      foreach (op; ops) {
        stack ~= cast(BridgeData)pb.components[curr_idx];
        //writeln(" - ", op, " ",stack);
        if (op == "+") { // i cannot find how to do opBinary!op(). it is a ct macro so no pretty fold like function possible
          auto second = stack.back;
          stack.popBack();
          auto first = stack.back;
          stack.popBack();
          stack ~= first + second;
        } else if (op == "*") {
          auto second = stack.back;
          stack.popBack();
          auto first = stack.back;
          stack.popBack();
          stack ~= first * second;
        } else if (op == "|") {
          auto second = stack.back;
          stack.popBack();
          auto first = stack.back;
          stack.popBack();
          stack ~= first | second;
        }else {
          assert(0);
        }
        curr_idx += 1;
      }
      assert(stack.length == 1);
      //writeln("total ", stack);
      if (stack[0].d == pb.result) {
        ret += pb.result;
        goto next;
      }
    }
    //writeln(" == == = == ");
  next:
  }

  return ret;
}

ulong part1(const Dinput[] content) {
  return partx(content, ["*", "+"]);
}

ulong part2(const Dinput[] content) {
  return partx(content, ["*", "+", "|"]);
}

struct Dinput {
  ulong result;
  BridgeData[] components;
}

void main() {
  File input = File(input_file, "r");
  Dinput[] din;

  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() != 0) {
      auto t = line.split(": ");
      auto d = t[1].split().map!(to!ulong).array;
      Dinput ret;
      ret.result = t[0].to!ulong;
      foreach (v; d) {
        ret.components ~= BridgeData(v);
      }
      din ~= ret;
    }
  }
  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
