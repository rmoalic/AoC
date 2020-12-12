#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include <math.h>

#define NR 7
#define NC 3

typedef struct Position {
	int row;
	int column;
} Position;

#define Plane_len 128*8
typedef bool Plane[Plane_len];

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

int find_empty_seat(Plane p) {
	bool found = false;
	int i = 0;
	bool started = false;

	while (! found && i < Plane_len) {
		if (!started) {
			started = p[i];
		} else {
			if (!p[i]) {
				found = true;
			}
		}
		i = i + 1;
	}
	if (!found) {
		return -1;
	}

	return i - 1;
}

int main(int argc, char** argv) {
	FILE* f;
	char* line = NULL;
        size_t len = 0;
        ssize_t nread;
	int hsid = -1;
	Plane plane = { 0 };
	int my_place;

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
		plane[sid] = true;
		//printf("%s: row %d, column %d, seat ID %d\n", line, p.row, p.column, sid);
		if (sid > hsid) {
			hsid = sid;
		}
	}
	printf("Higher ID: %d\n", hsid);
	my_place = find_empty_seat(plane);

	for (int i = 0; i < Plane_len; i++) {
		printf("%d", plane[i]);
		if ((i+1) % 8 == 0) printf("\n");
	}
	printf("My seat is %d\n", my_place);

	free(line);
	fclose(f);
	return EXIT_SUCCESS;
}
