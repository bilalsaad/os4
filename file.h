struct file {
  enum { FD_NONE, FD_PIPE, FD_INODE } type;
  int ref; // reference count
  char readable;
  char writable;
  struct pipe *pipe;
  struct inode *ip;
  uint off;
};

struct mnt_info {
  int is_mnt;
  struct partition* prt;
  uint inum;
};

// in-memory copy of an inode
struct inode {
  uint inum;                            // Inode number
  int ref;                              // Reference count
  int flags;                            // I_BUSY, I_VALID
  struct partition* prt;         // Which partition. also holds dev.
  struct mnt_info mnt_info;

  short type;         // copy of disk inode
  short major;
  short minor;
  short nlink;
  uint size;
  uint addrs[NDIRECT+1];
};
#define I_BUSY 0x1
#define I_VALID 0x2

// table mapping major device number to
// device functions
struct devsw {
  int (*read)(struct inode*, char*, int);
  int (*write)(struct inode*, char*, int);
};

extern struct devsw devsw[];

#define CONSOLE 1

//PAGEBREAK!
// Blank page.
