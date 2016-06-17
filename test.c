#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#define d2 printf(1, "%d %s \n", __LINE__, __func__)

int
main(int argc, char *argv[])
{
  int fd = open("blal", O_CREATE | O_RDWR);
  d2;
  char data[5] = "1 2 3";
  printf(1, "write: %d \n", write(fd, data, sizeof(data)));
  close(fd);
  exit();
}
