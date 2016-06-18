
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#define d2 printf(1, "%d %s \n", __LINE__, __func__)

int
main(int argc, char *argv[])
{
  int fd, fd2;
  printf(1, "mount a %d \n", mount("a", 2));
  
  fd = open("a", 0);
  if (fd < 0) {
    printf(1, "Failed to open a \n");
  }
  fd2 = open("/a/echo", 0);
  if (fd2 < 0) {
    printf(1, "Failed to open a/echo \n");
  }
  close(fd);
  exit();
}
