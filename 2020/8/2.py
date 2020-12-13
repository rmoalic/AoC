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

def run(data, ip, acc):
    flag = [0 for i in range(len(data))]
    error = False
    while ip < len(data) and not error:
        ist, val = data[ip]
        if flag[ip] > 0:
            error = True
        else:
            flag[ip] = flag[ip] + 1
            if ist is Instructions.NOP:
                ip = ip + 1
            elif ist is Instructions.ACC:
                ip = ip + 1
                acc = acc + val
            elif ist is Instructions.JMP:
                nip = ip + val
                if not (nip >= 0 and nip <= len(data)):
                    error = True
                else:
                    ip = nip
    return (ip, acc)

def print_d(data):
    print("---")
    for k, v in data:
        print(k.name, "\t", v)

print("len {}".format(len(data)))
correct = False
modified = False
flag_changed = [0 for i in range(len(data))]
gacc = 0
d = data.copy()
changed = 0
while not correct and changed < len(data):
    ip, acc = run(d, 0, 0)
    print(ip, acc)
    if modified:
        d = data.copy()
        modified = False
    if (ip < len(data)):
        for i, (ins, val) in enumerate(d):
            if ins is Instructions.NOP or ins is Instructions.JMP:
                if flag_changed[i] == 0:
                    if ins is Instructions.NOP:
                        d[i] = (Instructions.JMP, val)
                    elif ins is Instructions.JMP:
                        d[i] = (Instructions.NOP, val)
                    flag_changed[i] = 1
                    modified = True
                    changed = changed + 1
                    # print_d(d)
                    break
            else:
                if flag_changed[i] == 0:
                    flag_changed[i] = 1
                    changed = changed + 1
                
    else:
        correct = True
        gacc = acc


print("acc: {}".format(gacc))
