import std.stdio, std.file, std.conv, std.algorithm, std.string, std.math, std.range, std.parallelism, std.bigint, std.container.dlist;

string input_file = "input.txt";


class Computer(T) {
  T A;
  T B;
  T C;
  T ip;

  enum Instruction: long {
    iadv = 0,
    ibxl = 1,
    ibst = 2,
    ijnz = 3,
    ibxc = 4,
    iout = 5,
    ibdv = 6,
    icdv = 7
  }

  this(T A, T B, T C) {
    this.A = T(A);
    this.B = T(B);
    this.C = T(C);
  }

  override string toString() const {
    return format("(ip=%d A=%d B=%d C=%d)", ip, A, B, C);
  }

  T combo_operand(long operand) {
    if (operand < 4) {
      return T(operand);
    }
    switch (operand) {
    case 4: return this.A;
    case 5: return this.B;
    case 6: return this.C;
    case 7: assert(0, "not used");
    default: assert(0);
    }
  }

  long iout(long operand) {
    T c_op = combo_operand(operand);
    T ret = c_op % 8;
    //writeln("iout: ", ret);
    return ret;
  }

  void iadv(long operand) {
    T c_op = combo_operand(operand);
    T ret = this.A / (pow(2, c_op));
    //writeln("adv: ", operand);
    this.A = cast(T) ret;
  }

  void ibxl(long operand) {
    this.B = this.B ^ operand;
  }

  void ibst(long operand) {
    T c_op = combo_operand(operand);
    this.B = c_op % 8;
  }

  bool ijnz(long operand) {
    if (this.A == 0) return false;
    this.ip = operand;
    return true;
  }

  void ibxc(long operand) {
    cast(void) operand;
    this.B = this.B ^ this.C;
  }

  void ibdv(long operand) {
    T c_op = combo_operand(operand);
    this.B = this.A / (pow(2, c_op));
  }

  void icdv(long operand) {
    auto c_op = combo_operand(operand);
    this.C = this.A / (pow(2, c_op));
  }

  long[] run_program(in long[] program) in {
    assert(program.length % 2 == 0);
  } do {
    long[] ret;
    //writeln("running: ", program);
    this.ip = 0;
    auto plen = program.length;
    while (ip < plen) {
      auto instruction = program[ip];
      auto operand = program[ip + 1];
      auto has_jumped = false;
      //writeln(this);
      //writeln("current instruction: ", cast(Instruction) instruction);

      final switch (instruction) {
      case Instruction.iout:
        ret ~= this.iout(operand);
        break;
      case Instruction.ijnz:
        has_jumped = this.ijnz(operand);
        break;
      case Instruction.iadv:
        this.iadv(operand);
        break;
      case Instruction.ibxl:
        this.ibxl(operand);
        break;
      case Instruction.ibst:
        this.ibst(operand);
        break;
      case Instruction.ibxc:
        this.ibxc(operand);
        break;
      case Instruction.ibdv:
        this.ibdv(operand);
        break;
      case Instruction.icdv:
        this.icdv(operand);
        break;
      }
      if (! has_jumped) {
        this.ip += 2;
      }
      //writeln(this);
    }

    return ret;
  }

  unittest {
    Computer c = new Computer!long(0, 0, 9);
    c.run_program([2, 6]);
    assert(c.B == 1);
  }

  unittest {
    Computer c = new Computer!long(10, 0, 0);
    auto ret = c.run_program([5, 0, 5, 1, 5, 4]);
    assert(ret == [0, 1, 2]);
    }

  unittest {
    Computer c = new Computer!long(2024, 0, 0);
    auto ret = c.run_program([0,1,5,4,3,0]);
    assert(ret == [4,2,5,6,7,7,7,7,3,1,0]);
    assert(c.A == 0);
  }

  unittest {
    Computer c = new Computer!long(0, 29, 0);
    c.run_program([1, 7]);
    assert(c.B == 26);
  }

  unittest {
    Computer c = new Computer!long(0, 2024, 43_690);
    c.run_program([4, 0]);
    assert(c.B == 44_354);
  }
}

string part1(in Dinput content) {
  auto computer = new Computer!long(content.A, content.B, content.C);
  auto output = computer.run_program(content.program);
  return output.map!(to!string).join(",");
}

struct Queue_Value {
  ulong reg_a;
  ulong nb_correct_digits;
}

ulong part2(in Dinput content) {
  auto queue = DList!Queue_Value();

  queue.insertBack(Queue_Value(0, 0));

  while (! queue.empty) {
    Queue_Value curr = queue.front;
    queue.removeFront();

    foreach (v; 0..8) {
      ulong tmp_new_A = (curr.reg_a << 3) | v;
      auto computer = new Computer!ulong(tmp_new_A, content.B, content.C);
      auto output = computer.run_program(content.program);

      if (output[0] == content.program[$ - curr.nb_correct_digits - 1]) {
        if (curr.nb_correct_digits == content.program.length - 1) {
          return tmp_new_A;
        } else {
          queue.insertBack(Queue_Value(tmp_new_A, curr.nb_correct_digits + 1));
        }
      }

    }
  }
  assert(0);
}

struct Dinput {
  long A, B, C;
  long[] program;
}

void main() {
  File input = File(input_file, "r");
  Dinput din;

  int part = 0;
  while (! input.eof()) {
    string line = input.readln().strip;
    if (line.count() == 0) part++;
    if (part == 0) {
      auto l = line.chompPrefix("Register ");
      if (l[0] == 'A') {
        din.A = l[3..$].to!long;
      } else if (l[0] == 'B') {
        din.B = l[3..$].to!long;
      } else if(l[0] == 'C') {
        din.C = l[3..$].to!long;
      }
    } else if (part == 1) {
      auto l = line.chompPrefix("Program: ");
      din.program = l.split(",").map!(to!long).array;
    }
  }
  auto p1 = part1(din);
  auto p2 = part2(din);

  writeln("part1: ", p1);
  writeln("part2: ", p2);
}
