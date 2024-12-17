import std.stdio, std.file, std.conv, std.algorithm, std.string, std.math, std.range, std.parallelism;

string input_file = "input.txt";


class Computer {
  long A;
  long B;
  long C;
  long ip;

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
  
  this(long A, long B, long C) {
    this.A = A;
    this.B = B;
    this.C = C;
  }

  override string toString() const {
    return format("(ip=%d A=%d B=%d C=%d)", ip, A, B, C);
  }

  long combo_operand(long operand) {
    if (operand < 4) {
      return operand;
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
    auto c_op = combo_operand(operand);
    auto ret = c_op % 8;
    //writeln("iout: ", ret);
    return ret;
  }

  void iadv(long operand) {
    auto c_op = combo_operand(operand);
    auto ret = this.A / (pow(2, c_op));
    //writeln("adv: ", operand);
    this.A = cast(long) ret;
  }

  void ibxl(long operand) {
    this.B = this.B ^ operand;
  }

  void ibst(long operand) {
    auto c_op = combo_operand(operand);
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
    auto c_op = combo_operand(operand);
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
    Computer c = new Computer(0, 0, 9);
    c.run_program([2, 6]);
    assert(c.B == 1);
  }

  unittest {
    Computer c = new Computer(10, 0, 0);
    auto ret = c.run_program([5, 0, 5, 1, 5, 4]);
    assert(ret == [0, 1, 2]);
    }
  
  unittest {
    Computer c = new Computer(2024, 0, 0);
    auto ret = c.run_program([0,1,5,4,3,0]);
    assert(ret == [4,2,5,6,7,7,7,7,3,1,0]);
    assert(c.A == 0);
  }
  
  unittest {
    Computer c = new Computer(0, 29, 0);
    c.run_program([1, 7]);
    assert(c.B == 26);
  }

  unittest {
    Computer c = new Computer(0, 2024, 43_690);
    c.run_program([4, 0]);
    assert(c.B == 44_354);
    }
}

string part1(in Dinput content) {
  auto computer = new Computer(content.A, content.B, content.C);
  auto output = computer.run_program(content.program);
  writeln(output);
  return output.map!(to!string).join(",");
}

ulong part2(in Dinput content) {

  auto found = 0;
  auto max = uint.max;
  foreach (i; parallel(iota(100_000_000, max))) {
    if (found == 0) {
      auto computer = new Computer(i, content.B, content.C);
      auto output = computer.run_program(content.program);
      if (output == content.program) {
        writeln("found: ", i);
        found = i;
      }
      if (i % 10_000 == 0) {
        writeln(">> ", (i / (cast(double) max)) * 100);
      }
    } else {
      if (i % 10_000 == 0) {
        writeln(":: ", (i / (cast(double) max)) * 100);
      }
    }
  }
  return found;
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
