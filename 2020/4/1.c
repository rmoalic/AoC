#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

static char* mandatory[] = {"byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"};
static int mandatory_len = sizeof(mandatory) / sizeof(mandatory[0]);

struct KeyVal {
	char* key;
	char* val;
};

struct KeyVal* make_record(char* record_txt, size_t l, int* nb) {
	char *token1, *token2;
	char *saveptr1, *saveptr2;
	struct KeyVal* ret = NULL;
	size_t ret_len = 0;
	//printf("> %s\n", record_txt);

	token1 = strtok_r(record_txt, " ", &saveptr1);
	while (token1 != NULL) {
		ret_len = ret_len + 1;
		ret = realloc(ret, ret_len * sizeof(*ret));

		token2 = strtok_r(token1, ":", &saveptr2);
		ret[ret_len-1].key = strdup(token2);

		token2 = strtok_r(NULL, ":", &saveptr2);
		ret[ret_len-1].val = strdup(token2);

		token1 = strtok_r(NULL, " ", &saveptr1);
	}
	*nb = ret_len;
	return ret;
}

int free_record(struct KeyVal* r, int l) {
	for (int i = 0; i < l; i++) {
		free(r[i].key);
		free(r[i].val);
	}
	free(r);
	return 0;
}

bool validate_record(struct KeyVal* r, int l) {
	bool valid = false;
	int found_required = 0;

	for (int i = 0; i < l; i++) {
		bool found = false;
		for (int j = 0; j < mandatory_len; j++) {
			if (strcmp(r[i].key, mandatory[j]) == 0) {
				found_required = found_required + 1;
				found = true;
			}
		}
		if (!found) {
			//	printf("ignored r['%s']=%s\n", r[i].key, r[i].val);
		}
	}

	if (found_required == mandatory_len) {
		valid = true;
	}
	return valid;
}

int main(int argc, char** arv) {
	FILE* f = NULL;
	char* line = NULL;
	char* record = NULL;
	size_t record_len = 0;
	size_t len = 0;
	ssize_t nread = 0;
	int nb_valid = 0;

	f = fopen("input.txt", "r");
	if (f == NULL) {
		perror("fopen");
		return EXIT_FAILURE;
	}

	while (!feof(f)) {
		assert(nread != -1);
		nread = getline(&line, &len, f);
		if (nread == 1 || feof(f)) {
			struct KeyVal* r;
			int nb_r;
			bool valid;
			r = make_record(record, record_len, &nb_r);
			valid = validate_record(r, nb_r);
			if (valid) {
				nb_valid = nb_valid + 1;
			}

			free_record(r, nb_r);

			record[0] = '\0';
			record_len = 0;
		} else {
			bool new = record_len == 0;
			record_len = record_len + nread + 1;
			record = realloc(record, record_len);
			if (new) record[0] = '\0';
			line[nread-1] = ' ';
			strncat(record, line, nread);
		}
	}

	assert(record[0] == '\0');
	printf("nb_valid: %d\n", nb_valid);

	free(line);
	free(record);
	fclose(f);
	return EXIT_SUCCESS;
}
