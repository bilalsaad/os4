
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#define d2 printf(1, "%d %s \n", __LINE__, __func__)
#define DIRSZ 14
int
main(int argc, char *argv[])
{
  //char buffer[DIRSZ];
  printf(1, "argv1 %s argv2 %s \n", argv[1], argv[2]);
  if (mount(argv[1], atoi(argv[2])) < 0)
    printf(1, "mount failed \n");
  else 
    printf(1, "mount succeeded \n");

  exit();
}
