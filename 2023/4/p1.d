import std.stdio, std.file, std.range, std.string, std.conv, std.algorithm, std.array, std.typecons, std.container.array;

string input_file = "input.txt";

struct Card {
    int number;
    int[] winning_numbers;
    int[] game_numbers;
}

Card parse_card(string card) {
    auto game = card.split(": ");
    int game_id = to!int(strip(game[0][5 .. $]));
    auto numbers = game[1].split(" | ");
    int[] winning_numbers = numbers[0].split().map!(to!int).array.sort().array;
    int[] game_numbers    = numbers[1].split().map!(to!int).array.sort().array;
    return Card(game_id, winning_numbers, game_numbers);
}

int part1(immutable Card[] cards) {
    auto acc = 0;    
    
    foreach (c; cards) {
        auto correct_numbers = setIntersection(c.winning_numbers, c.game_numbers);
        auto won = correct_numbers.count() == 0 ? 0 : cast(int) 2 ^^ (correct_numbers.count() - 1);
        acc += won;
    }
    
    return acc;
}

int part2(immutable Card[] cards) {
    int[] won_per_card = new int[](cards.count());
    int[] count = new int[](cards.count());
    auto acc = 0;    
    
    foreach (c; cards) {
        auto correct_numbers = setIntersection(c.winning_numbers, c.game_numbers);
        won_per_card[c.number - 1] = cast(int) correct_numbers.count();
    }

    void rec(int curr) {
        count[curr - 1] += 1;
        int won = won_per_card[curr - 1];
        for (int i = won - 1; i >= 0 ; i--) {
            rec(curr + 1 + i);
        }
    }
    for (int i = 1; i < cards.count() + 1; i++) {
    	rec(i);
    }
/* // SList is very slow as a stack
    auto def = to!(int[])(iota(1, cards.count() + 1, 1).array);
    auto stack = SList!int(def);

    while (! stack.empty()) {
        int curr = stack.front;
        stack.removeFront();

        count[curr - 1] += 1;
        int won = won_per_card[curr - 1];
        for (int i = won - 1; i >= 0 ; i--) {
            stack.insertFront(curr + 1 + i);
        }
    }*/
    return count.sum();
}

void main() {
    File input = File(input_file, "r");
    auto cards = Array!Card();
    cards.reserve(250);
    while (! input.eof()) {
        string line = input.readln().strip;
        if (line.count() > 0) {
            Card c = parse_card(line);
            cards.insert(c);
        }
    }
    immutable auto icards = cast(immutable) cards.array;
    auto p1 = part1(icards);
    writeln("part1: ", p1);
    auto p2 = part2(icards);
    writeln("part2: ", p2);
    input.close();
}
