
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#define d2 printf(1, "%d %s \n", __LINE__, __func__)

int
main(int argc, char *argv[])
{
  mount("a", 2);
  exit();
}
