data = list() 

with open("input.txt", "r") as f:
    for line in f:
        data.append(int(line))

found = 0
found_val = []

while found < 2 and len(data) > 0:
    val = data.pop()
    needed = 2020 - val
    print(val)
    if needed <= 0:
        continue
    for d in data:
        if d == needed:
            found = found + 1
            found_val.append(val)
            found_val.append(d)
            break

print("values {}".format(found_val))
product = found_val[0] * found_val[1]
print("result {}".format(product))

