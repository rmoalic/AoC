
class Data(object):

    def __init__(self, file_name: str):
        self.mdata = list()
        self.line_lenght = -1

        with open(file_name, "r") as f:
            for line in f:
                d = [1 if c == "#" else 0 for c in line.strip()]
                if self.line_lenght == -1:
                    self.line_lenght = len(d)
                assert self.line_lenght == len(d)
                self.mdata.append(d)
        self.nb_line = len(self.mdata)
        self.debug = list()

    def get(self, x: int, y: int):
        #if x > self.nb_line:
        #    raise Exception("outside of scope")
        ny = y % (self.line_lenght)
        print("g", x, ny)
        self.debug.append((x, ny))
        return self.mdata[x][ny]

    def get_hight(self):
        return self.nb_line

    def display(self):
        for x, line in enumerate(self.mdata):
            for y, c in enumerate(line):
                if (x,y) in self.debug:
                    print("X", end="")
                else:
                    if c == 1:
                        print("#", end="")
                    elif c == 0:
                        print(".", end="")
                    else:
                        print("@", end="")
            print()

data = Data("input.txt")

pas_x = 3
pas_y = 1

displacement = ((data.get_hight() - 1) // pas_y)  * pas_x
print(displacement)
acc = list()
for x, y in zip(range(0, data.get_hight()+1, pas_y), range(0, displacement+pas_x, pas_x)):
    print("r", x, y)
    acc.append(data.get(x, y))
acc.pop(0)
print(acc)
from collections import Counter
print(Counter(acc))
