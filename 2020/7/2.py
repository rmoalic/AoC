
class Bag():
    bags = dict()
    def __init__(self, name):
        self.name = name
        self.contains = list()
        self.contained = list()

    def getBag(name):
        if not name in Bag.bags:
            Bag.bags[name] = Bag(name)
        return Bag.bags[name]
    
    def printBags():
        for val in Bag.bags.values():
            print(val.name, val.contains)

    def addContained(self, bag):
        self.contained.append(bag)

    def addContains(self, bag):
        self.contains.append(bag)
    
    def __repr__(self):
        return "Bag({})".format(self.name)
    

with open("input.txt", "r") as f:
    for line in f:
        bag_c, contains = line.split(" bags contain")
        bag = Bag.getBag(bag_c)
        contains = contains[:-1] # remove "."
        for bags in contains.split(","):
            if bags == " no other bags.":
                continue
            sp = bags.split(" ")
            nb = int(sp[1])
            bag_2 = " ".join(sp[2:-1])
            bag_2 = Bag.getBag(bag_2)
            bag_2.addContained(bag)
            bag.addContains((nb, bag_2))

#Bag.printBags()

shiny = Bag.getBag("shiny gold")

def calc(head: Bag):
    #print("call ", head)
    print(head.contains)
    if len(head.contains) == 0:
        return 1
    ret = 1
    for nb, b in head.contains:
        c = calc(b)
        ret = ret + nb * c
        print("{} * {}".format(nb, c))
    #print("ret", ret)
    return ret

result = calc(shiny) - 1
print(result)



