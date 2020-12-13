from enum import Enum, unique

@unique
class Instructions(Enum):
    NOP = 0
    JMP = 1
    ACC = 2

data = list()

with open("input.txt", "r") as f:
    for line in f:
        op, val = line.split(" ")
        op = op.upper()
        data.append((Instructions[op], int(val)))

ip = 0
acc = 0
flag = [0 for i in range(len(data))]
error = False

while ip < len(data) and not error:
    inst = data[ip]
    if flag[ip] > 0:
        error = True
    else:
        flag[ip] = flag[ip] + 1
        if inst[0] is Instructions.NOP:
            ip = ip + 1
        elif inst[0] is Instructions.ACC:
            ip = ip + 1
            acc = acc + inst[1]
        elif inst[0] is Instructions.JMP:
            nip = ip + inst[1]
            assert nip >= 0 and nip < len(data)
            ip = nip

if error:
    print("Program ended with error")

print("acc: {}".format(acc))
