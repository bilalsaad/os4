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

  char data[512];
  memset(data, 'b', sizeof(data));
  for(i = 0 ; i < 20; ++i) {
    if(write(fd, data, sizeof(data)) != sizeof(data)) {
      printf(1, "bad write iter %d \n", i);
      exit();
    }
      
  }
  close(fd);
  unlink("blal");
  exit();
}
