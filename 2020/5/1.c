#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>

#define NR 7
#define NC 3

typedef struct Position {
	int row;
	int column;
} Position;

Position position_from_string(char* str) {
	int row_l = 0, row_h = 127;
	int column_l = 0, column_h = 7;
	Position p;

	for (int i = 0; i < NR; i++) {
		switch (str[i]) {
		case 'F':
			row_h = floor((row_l + row_h) / 2.0);
			break;
		case 'B':
			row_l = ceil((row_l + row_h) / 2.0);
			break;
		default:
			printf("Erreur: encontered %c in first half of string\n", str[i]);

		}
		assert(row_l <= row_h);
	}
	assert(row_l == row_h);

	p.row = row_l;

	for (int i = NR; i < (NR + NC); i++) {
		switch (str[i]) {
		case 'L':
			column_h = floor((column_l + column_h) / 2.0);
			break;
		case 'R':
			column_l = ceil((column_l + column_h) / 2.0);
			break;
		default:
			printf("Erreur: encontered %c in second half of string\n", str[i]);

		}
		assert(column_l <= column_h);
	}
	assert(column_l == column_h);

	p.column = column_l;
	return p;
}

int seat_id(Position pos) {
	return pos.row * 8 + pos.column;
}

int main(int argc, char** argv) {
	FILE* f;
	char* line = NULL;
        size_t len = 0;
        ssize_t nread;
	int hsid = -1;

	f = fopen("input.txt", "r");
	if (f == NULL) {
		perror("fopen");
		return EXIT_FAILURE;
	}

	while ((nread = getline(&line, &len, f)) != -1) {
		Position p;
		int sid;
		p = position_from_string(line);
		sid = seat_id(p);
		printf("%s: row %d, column %d, seat ID %d\n", line, p.row, p.column, sid);
		if (sid > hsid) {
			hsid = sid;
		}
	}
	printf("Higher ID: %d\n", hsid);

	free(line);
	fclose(f);
	return EXIT_SUCCESS;
}
