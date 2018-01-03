#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <assert.h>

//TODO error messages, create, delete, seek

int fd, ret, i;
char buf[1024];

int main(int argc, char **argv) {
	printf("File test program\n\n");

	printf("Opening '/HOME/TESTFILE.TXT'...\n");
	fd = open("/HOME/TESTFILE.TXT", (1 << O_RDONLY), 0);
	assert(fd != -1);
	printf("Success: Fd = %d\n", fd);

	printf("Reading 10 bytes from file...\n");
	ret = read(fd, buf, 10);
	assert(ret != -1);
	printf("Success. %d bytes read\n", ret);

	printf("Writing 10 bytes to file...\n");
	ret = write(fd, buf, 10);
	assert(ret != -1);
	printf("Success. %d bytes written\n", ret);

	printf("Closing file...\n");
	ret = close(fd);
	assert(ret == 0);
	printf("Success\n");
	return 0;
}
