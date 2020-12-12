data = list()

with open("input.txt", "r") as f:
    for line in f:
        sp = line.split(" ")
        mm = tuple(int(x) for x in sp[0].split("-"))
        letter = sp[1][:-1]
        pw = sp[2]
        data.append((mm, letter, pw))

def check(nm, letter, pw):
    count = 0
    for l in pw:
        if l == letter:
            count = count + 1
    return count >= nm[0] and count <= nm[1]

i = 0
for d in data:
    if check(*d):
        i = i + 1
print(i)        
