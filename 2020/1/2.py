from bisect import bisect_left, bisect_right

def search_combination(data, n, value=2020):
    found = list()
    if len(data) == 0:
        return found
    print("{}sc({}, {}, {})".format("  "*(5-n), len(data), n, value))
    for d in data:
        needed = value - d
        if needed == 0 and n == 1:
            print("FOUND {}".format(d))
            found.append(d)
            break
        if needed < 0:
            continue
        if n > 1: 
            idx = bisect_right(data, needed)
            ndata = data[:idx]
            if d <= needed:
                ndata.remove(d)
            res = search_combination(ndata, n - 1, needed)
            if len(res) == (n - 1):
                found.extend(res)
                found.append(d)
                print("res {}".format(found))
                break
    return found            



data = list() 

with open("input.txt", "r") as f:
    for line in f:
        data.append(int(line))

data.sort()

found_val = search_combination(data, 4, 6327)

print("values {}".format(found_val))

from math import prod
product = prod(found_val)

print("result {}".format(product))

