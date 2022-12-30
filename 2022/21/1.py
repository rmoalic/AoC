from operator import add, mul, sub, floordiv

data = dict()

def get(v):
    if type(v) is int:
        def g():
            return v
    elif type(v) is tuple:
        def g():
            op1, o, op2 = v
            return o(op1(), op2())
    else:
        print(v)
        raise Exception("unreachable")
        
    return g

def ref(name):
    def find():
        return data[name]()
    return find

with open("input.txt") as f:

    for line in f:
        line = line[:-1]
        name, rest = line.split(": ")
        try:
            n = int(rest)
            data[name] = get(n)
            continue
        except ValueError:
            pass

        op1, o, op2 = rest.split(" ")
        
        if o == "+":
            op = add
        elif o == "-":
            op = sub
        elif o == "/":
            op = floordiv
        elif o == "*":
            op = mul
        else:
            raise Exception("unreachable")

        data[name] = get((ref(op1), op, ref(op2)))

part1 = data["root"]()

print(f"solution part1: {part1}")
