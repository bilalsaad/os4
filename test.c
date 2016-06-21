#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#define d2 printf(1, "%d %s \n", __LINE__, __func__)

int
main(int argc, char *argv[])
{
  int i;
  int fd = open("blal", O_CREATE | O_RDWR);
  int fd2 = open("blal2", O_CREATE | O_RDWR);
  d2;

  char data[512];
  memset(data, 'b', sizeof(data));
  for(i = 0 ; i < 100; ++i) {
    if(write(fd, data, sizeof(data)) != sizeof(data)) {
      printf(1, "1 bad write iter %d \n", i);
      exit();
    }
    if(write(fd2, data, sizeof(data)) != sizeof(data)) {
      printf(1, "2 bad write iter %d \n", i);
      exit();
    }
  }
  close(fd);
  close(fd2);
  unlink("blal");
  exit();
}
