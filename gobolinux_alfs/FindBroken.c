#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

int main(int argc, char **argv)
{
	struct stat statbuf;
	int ret, i;
	for (i=1; i<argc; ++i) {
		ret = lstat(argv[i], &statbuf);
		if (ret == 0 && access(argv[i], F_OK) < 0) {
			printf("%s\n", argv[i]);
		}
	}
	return 0;
}
