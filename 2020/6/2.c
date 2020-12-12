#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

#define N 26
#define GROUP_SIZE 15

typedef struct Person {
	bool ans_yes[N];
	int nb_yes;
} Person;

typedef struct Group {
	Person members[GROUP_SIZE];
	int nb_members;
} Group;


bool make_person(Person* ret, char* input) {
	ret->nb_yes = 0;
	for (int i = 0; i < N; i++) {
		ret->ans_yes[i] = false;
	}

	int len = strlen(input);
	for (int i = 0; i < len; i++) {
		int v = input[i] - 97;
		if (v < 0 || v > 122) {
			printf("make_person: invalid vote %c\n", input[i]);
			return false;
		}
		if (ret->ans_yes[v]) {
			printf("make_person: duplicate vote %s %c\n", input, input[i]);
		} else {
			ret->ans_yes[v] = true;
			ret->nb_yes++;
		}
	}
	return true;
};

void print_person(Person p) {
	for (int i = 0; i < N; i++) {
		printf("%d", p.ans_yes[i]);
	}
	printf(" : %d\n", p.nb_yes);

}

void print_group(Group g) {
	printf("-- Group\n");
	for (int i = 0; i < g.nb_members; i++) {
		print_person(g.members[i]);
	}
	printf("-- End Group\n");
}

int group_at_least_one_yes(Group g) {
	bool ans_yes[N] = { 0 };
	int nb = 0;

	for (int i = 0; i < g.nb_members; i++) {
		for (int j = 0; j < N; j++) {
			if (g.members[i].ans_yes[j] && ! ans_yes[j]) {
				ans_yes[j] = true;
				nb++;
			}
		}
	}
	return nb;
}

int group_all_yes(Group g) {
	int ans_yes[N] = { 0 };
	int nb = 0;

	for (int i = 0; i < g.nb_members; i++) {
		for (int j = 0; j < N; j++) {
			if (g.members[i].ans_yes[j]) {
				ans_yes[j]++;
			}
		}
	}

	for (int i = 0; i < N; i++) {
		if (ans_yes[i] == g.nb_members) {
			nb++;
		}
	}

	return nb;
}

int main(int argc, char** arv) {
	FILE* f = NULL;
	char* line = NULL;
	size_t len = 0;
	ssize_t nread = 0;

	Group g = { 0 };
	unsigned long acc = 0;

	f = fopen("input.txt", "r");
	if (f == NULL) {
		perror("fopen");
		return EXIT_FAILURE;
	}

	while (!feof(f)) {
		assert(nread != -1);
		nread = getline(&line, &len, f);
		if (nread == 1 || feof(f)) {
			print_group(g);
			int yeses = group_all_yes(g);
			printf("yes: %d\n", yeses);
			acc = acc + yeses;

			g.nb_members = 0;
		} else {
			assert(g.nb_members < GROUP_SIZE);
			line[strcspn(line, "\n")] = 0;
			make_person(&(g.members[g.nb_members]), line);
			g.nb_members++;
		}
	}
	printf("acc: %lu\n", acc);
	free(line);
	fclose(f);
	return EXIT_SUCCESS;
}
