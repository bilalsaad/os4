
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#define d2 printf(1, "%d %s \n", __LINE__, __func__)

int
main(int argc, char *argv[])
{
  int fd, fd2;
  char data[512];
  struct stat st;
  memset(data, 'b', sizeof(data));
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
  close(fd2);
  // now we'd like to create a file under a say foo.txt
  fd = open("/a/foo", O_CREATE | O_RDWR);

  if (fd < 0) {
    printf(1, "failed to create /a/foo\n");
    exit();
  }
  if(write(fd, data, sizeof(data)) != sizeof(data)) {
    printf(1, "bad write to /a/foo \n");
    exit();
  }
  // now let us try to stat /a/foo =].
  if(fstat(fd, &st) < 0) {
    printf(1, "cannot stat /a/foo\n"); 
    exit();
  }
  printf(1, "%s %d %d %d %d\n",
        "/a/foo", st.type, st.ino, st.size, st.prti);
  close(fd);
  exit();
}
