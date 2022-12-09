input_file = "input.txt"
data = dict()

with open(input_file, "r") as f:
    curr = [("/", data)]

    for line in f:
        line = line[:-1]
        if line.startswith("$ cd"):
            d = line.removeprefix("$ cd ")
            if d == "..":
                curr.pop()
                # print(f"$ cd ..\n {curr[-1][0]}")
            elif d == "/":
                pass
            else:
                folder = curr[-1][1]
                try:
                    new_folder = folder[d]
                except:
                    n = dict()
                    folder[d] = n
                    new_folder = n
                # print(f"$ cd {d}")
                curr.append((d, new_folder))
        elif line.startswith("$ ls"):
            pass
        elif line.startswith("dir"):
            pass
        else:
            folder = curr[-1][1]
            size, name = line.split(" ")
            folder[name] = int(size)


def dirsize(l, data):
    l = []
    def loop(data):
        acc = 0
        for k,v in data.items():
            if type(v) is int:
                acc = acc + v
            else:
                dname = k
                dsize = loop(v)
                l.append((dname, dsize))
                acc = acc + dsize
        return acc
    return l, loop(data)

sizes, total = dirsize(list(), data)
part1 = sum([size for name, size in sizes if size <= 100000])
print(f"solution part1: {part1}")

FULL = 70000000
NEEDED = 30000000

free_space = (FULL - total)
needed_for_install = NEEDED - free_space

part2 = min([size for name, size in sizes if size >= needed_for_install])
print(f"solution part2: {part2}")
