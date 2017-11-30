#include <fcntl.h>

int writebyte(int fd, int c) {
	if (write(fd, &c, 1) == -1) {
		return_c -1;
	} else {
		return_nc c;
	}
}
