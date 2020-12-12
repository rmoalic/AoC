data = list()

with open("input.txt", "r") as f:
    for line in f:
        sp = line.split(" ")
        mm = tuple(int(x) for x in sp[0].split("-"))
        letter = sp[1][:-1]
        pw = sp[2]
        data.append((mm, letter, pw))

def check(nm, letter, pw):
    if nm[1] > len(pw):
        return False
    return (pw[nm[0]-1] == letter) ^ (pw[nm[1]-1] == letter)

i = 0
for d in data:
    if check(*d):
        i = i + 1
print(i)
