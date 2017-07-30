#include <fcntl.h>

int readbyte(int fd) {
	unsigned char buffer;
	if (read(fd, &buffer, 1) == -1) {
		return_c -1;
	} else {
		return_nc buffer;
	}
}
