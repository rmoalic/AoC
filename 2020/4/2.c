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

bool validate_record_values(struct KeyVal r) {
	bool valid = false;
	char* k = r.key;
	char* v = r.val;

	if (strcmp(k, "byr") == 0) {
		int year;
		if (sscanf(v, "%4d", &year) > 0 && strlen(v) == 4) {
			valid = year >= 1920 && year <= 2002;
		}
	} else if (strcmp(k, "iyr") == 0) {
		int year;
		if (sscanf(v, "%4d", &year) > 0 && strlen(v) == 4) {
			valid = year >= 2010 && year <= 2020;
		}
	} else if (strcmp(k, "eyr") == 0) {
		int year;
		if (sscanf(v, "%4d", &year) > 0 && strlen(v) == 4) {
			valid = year >= 2020 && year <= 2030;
		}
	} else if (strcmp(k, "hgt") == 0) {
		int hgt;
		char unit[3];
		if (sscanf(v, "%3d%2s", &hgt, unit) == 2) {
			if (strcmp(unit, "cm") == 0 && strlen(v) == 5) {
				valid = hgt >= 150 && hgt <= 193;
			} else if (strcmp(unit, "in") == 0 && strlen(v) == 4) {
				valid = hgt >= 59 && hgt <= 76;
			}
		}
	} else if (strcmp(k, "hcl") == 0) {
		char color[7];
		valid = sscanf(v, "#%6[0-9a-f]", color) > 0  && strlen(v) == 7;
	} else if (strcmp(k, "ecl") == 0) {
		static const char* values[] = {"amb", "blu", "brn", "gry", "grn", "hzl", "oth"};
		static const int n = sizeof(values) / sizeof (values[0]);
		bool found = false;
		int i = 0;
		while (!found && i < n) {
			if (strcmp(v, values[i]) == 0) {
				found = true;
			}
			i = i + 1;
		}
		valid = found;
	} else if (strcmp(k, "pid") == 0) {
		int number;
		valid = sscanf(v, "%9d", &number) > 0 && strlen(v) == 9;
	} else if (strcmp(k, "cid") == 0) {
	} else {
		printf("ignoring cid");
	}

	return valid;
}

bool validate_record(struct KeyVal* r, int l) {
	bool valid = false;
	int found_required = 0;
	int found_valid = 0;

	for (int i = 0; i < l; i++) {
		bool found = false;
		for (int j = 0; j < mandatory_len; j++) {
			if (strcmp(r[i].key, mandatory[j]) == 0) {
				if (validate_record_values(r[i])) {
					//printf("valid r[%s]=%s\n", r[i].key, r[i].val);
					found_valid = found_valid + 1;
				}
				found_required = found_required + 1;
				found = true;
			}
		}
		if (!found) {
			//	printf("ignored r['%s']=%s\n", r[i].key, r[i].val);
		}
	}

	if (found_required == mandatory_len && found_valid == mandatory_len) {
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
