#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <assert.h>

#define stat xv6_stat  // avoid clash with host struct stat
#include "types.h"
#include "fs.h"
#include "stat.h"
#include "param.h"

// Task 0  - adding the mbr struct given to us.
#include "mbr.h"

#ifndef static_assert
#define static_assert(a, b) do { switch (0) case 0: case (a): ; } while (0)
#endif

#define NINODES 200
#define PART 0
// Disk layout:
// [ boot block | sb block | log | inode blocks | free bit map | data blocks ]

int nbitmap = FSSIZE/(BSIZE*8) + 1;
int ninodeblocks = NINODES / IPB + 1;
int nlog = LOGSIZE;  
int nmeta;    // Number of meta blocks (boot, sb, nlog, inode, bitmap)
int nblocks;  // Number of data blocks

int fsfd;
struct superblock sb;
char zeroes[BSIZE];
uint freeinode = 1;
uint freeblock;

// Task 0, our lovely struct mbr.
struct mbr mbr;
// Initializes the mbr to our liking.
void initialize_mbr(struct mbr* mbr);
// Adds a partition part to mbr at index index.
void add_partition(struct mbr* mbr, struct dpartition* part, int index);
// creates a partition with the give fields.
void create_partition(struct dpartition*, char, uint, uint, uint);

void balloc(int);
void wsect(uint, void*);
void winode(uint, struct dinode*);
void rinode(uint inum, struct dinode *ip);
void rsect(uint sec, void *buf);
uint ialloc(ushort type);
void iappend(uint inum, void *p, int n);


// convert to intel byte order
ushort
xshort(ushort x)
{
  ushort y;
  uchar *a = (uchar*)&y;
  a[0] = x;
  a[1] = x >> 8;
  return y;
}

uint
xint(uint x)
{
  uint y;
  uchar *a = (uchar*)&y;
  a[0] = x;
  a[1] = x >> 8;
  a[2] = x >> 16;
  a[3] = x >> 24;
  return y;
}

int create_bootload_kernel(struct mbr* mbr, char * bootload, char * kernel);

int
main(int argc, char *argv[])
{
  int i, cc, fd, sb_off;
  uint rootino, inum, off;
  struct dirent de;
  char buf[BSIZE];
  struct dinode din;
  struct dpartition part;


  static_assert(sizeof(int) == 4, "Integers must be 4 bytes!");

  if(argc < 2){
    fprintf(stderr, "Usage: mkfs fs.img files...\n");
    exit(1);
  }

  assert((BSIZE % sizeof(struct dinode)) == 0);
  assert((BSIZE % sizeof(struct dirent)) == 0);

  fsfd = open(argv[1], O_RDWR|O_CREAT|O_TRUNC, 0666);
  if(fsfd < 0){
    perror(argv[1]);
    exit(1);
  }

  // Initialize the whole file system w/ zeroes.
  for(i = 0; i < FSSIZE; i++)
    wsect(i, zeroes);
  // Task 0 initialize the mbr.
  initialize_mbr(&mbr);
  // Writes the bootloader + kernel to fs.img yikes.
  sb_off = create_bootload_kernel(&mbr, "bootblock", "kernel");
  if (sb_off < 1) {
    fprintf(stderr, "Usage: create_bootload_kernel failed...\n");
    close(fsfd);
    exit(1);
  }
  // ************************************************************************
  // ********************CREATES THE FIRST PARTITION*************************
  // ************************************************************************
  
  // 1 fs block = 1 disk sector
  // Number of metadata blocks 1 super block 1 mbr the logs the inodes the
  // bitmap.
  nmeta = 2 + nlog + ninodeblocks + nbitmap;
  // whats left is the data blocks.
  nblocks = FSSIZE - nmeta;
  
  // initializing the super block.
  sb.size = xint(FSSIZE);
  sb.nblocks = xint(nblocks);
  sb.ninodes = xint(NINODES);
  sb.offset = sb_off; // should be where we on the disk..
  sb.nlog = xint(nlog);
  sb.logstart = xint(sb_off+1);  // this should be offset from the start of part
  sb.inodestart = xint(sb_off+1+nlog);  // see above
  sb.bmapstart = xint(sb_off+1+nlog+ninodeblocks);  // see above

  printf("nmeta %d (boot, super, log blocks %u inode blocks %u,"
            " bitmap blocks %u) blocks %d total %d\n",
         nmeta, nlog, ninodeblocks, nbitmap, nblocks, FSSIZE);


  // Task 0 creating the partition.
  create_partition(&part, PART_BOOTABLE, FS_INODE, sb_off, xint(FSSIZE));
  add_partition(&mbr, &part, 0);
  freeblock = sb_off + nmeta;     // the first free block that we can allocate


  // Task 0 -  We want to write the mbr to the 0th slot in the 'disk'.
  memset(buf, 0, sizeof(buf));
  memmove(buf, &mbr, sizeof(mbr));
  wsect(0, buf);

  memset(buf, 0, sizeof(buf));
  memmove(buf, &sb, sizeof(sb));
  // Write the super block to the #1 slot in the 'PARTITION'.
  wsect(sb_off, buf);
  
  // Create the root INODE. 
  rootino = ialloc(T_DIR);
  assert(rootino == ROOTINO); //  Make sure it gets the right nubmer.

  bzero(&de, sizeof(de));
  // Create the ROOT INODE struct.
  de.inum = xshort(rootino);
  strcpy(de.name, ".");
  // I think this adds a file to the root directory.
  iappend(rootino, &de, sizeof(de));
  bzero(&de, sizeof(de));
  de.inum = xshort(rootino);
  strcpy(de.name, "..");
  // I think this adds a file to the root directory.
  iappend(rootino, &de, sizeof(de));

  for(i = 2; i < argc; i++){
    assert(index(argv[i], '/') == 0);

    if((fd = open(argv[i], 0)) < 0){
      perror(argv[i]);
      exit(1);
    }
    
    // Skip leading _ in name when writing to file system.
    // The binaries are named _rm, _cat, etc. to keep the
    // build operating system from trying to execute them
    // in place of system binaries like rm and cat.
    if(argv[i][0] == '_')
      ++argv[i];
    // For each file given the args - we create an Inode and write it to the
    // disk.
    inum = ialloc(T_FILE);
    // Add a new directory entry to the root. with the new file info.
    bzero(&de, sizeof(de));
    de.inum = xshort(inum);
    strncpy(de.name, argv[i], DIRSIZ);
    iappend(rootino, &de, sizeof(de));
    // Write the file to the disk.
    while((cc = read(fd, buf, sizeof(buf))) > 0)
      iappend(inum, buf, cc);

    close(fd);
  }

  // fix size of root inode dir. I.e make it a multiple of BSIZE.
  rinode(rootino, &din);
  off = xint(din.size);
  off = ((off/BSIZE) + 1) * BSIZE;
  din.size = xint(off);
  winode(rootino, &din);

  balloc(freeblock);

  exit(0);
}

void
wsect(uint sec, void *buf)
{
  if(lseek(fsfd, sec * BSIZE, 0) != sec * BSIZE){
    perror("lseek");
    exit(1);
  }
  if(write(fsfd, buf, BSIZE) != BSIZE){
    perror("write");
    exit(1);
  }
}

void
winode(uint inum, struct dinode *ip)
{
  char buf[BSIZE];
  uint bn;
  struct dinode *dip;

  bn = IBLOCK(inum, sb);
  rsect(bn, buf);
  dip = ((struct dinode*)buf) + (inum % IPB);
  *dip = *ip;
  wsect(bn, buf);
}

void
rinode(uint inum, struct dinode *ip)
{
  char buf[BSIZE];
  uint bn;
  struct dinode *dip;

  bn = IBLOCK(inum, sb);
  rsect(bn, buf);
  dip = ((struct dinode*)buf) + (inum % IPB);
  *ip = *dip;
}

void
rsect(uint sec, void *buf)
{
  if(lseek(fsfd, sec * BSIZE, 0) != sec * BSIZE){
    perror("lseek");
    exit(1);
  }
  if(read(fsfd, buf, BSIZE) != BSIZE){
    perror("read");
    exit(1);
  }
}

uint
ialloc(ushort type)
{
  uint inum = freeinode++;
  struct dinode din;

  bzero(&din, sizeof(din));
  din.type = xshort(type);
  din.nlink = xshort(1);
  din.size = xint(0);
  winode(inum, &din);
  return inum;
}

void
balloc(int used)
{
  uchar buf[BSIZE];
  int i;

  printf("balloc: first %d blocks have been allocated\n", used);
  assert(used < BSIZE*8);
  bzero(buf, BSIZE);
  for(i = 0; i < used; i++){
    buf[i/8] = buf[i/8] | (0x1 << (i%8));
  }
  printf("balloc: write bitmap block at sector %d\n", sb.bmapstart);
  wsect(sb.bmapstart, buf);
}

#define min(a, b) ((a) < (b) ? (a) : (b))

void
iappend(uint inum, void *xp, int n)
{
  char *p = (char*)xp;
  uint fbn, off, n1;
  struct dinode din;
  char buf[BSIZE];
  uint indirect[NINDIRECT];
  uint x;

  rinode(inum, &din);
  off = xint(din.size);
  //printf("append inum %d at off %d sz %d\n", inum, off, n);
  while(n > 0){
    fbn = off / BSIZE;
    assert(fbn < MAXFILE);
    if(fbn < NDIRECT){
      if(xint(din.addrs[fbn]) == 0){
        din.addrs[fbn] = xint(freeblock++);
      }
      x = xint(din.addrs[fbn]);
    } else {
      if(xint(din.addrs[NDIRECT]) == 0){
        din.addrs[NDIRECT] = xint(freeblock++);
      }
      rsect(xint(din.addrs[NDIRECT]), (char*)indirect);
      if(indirect[fbn - NDIRECT] == 0){
        indirect[fbn - NDIRECT] = xint(freeblock++);
        wsect(xint(din.addrs[NDIRECT]), (char*)indirect);
      }
      x = xint(indirect[fbn-NDIRECT]);
    }
    n1 = min(n, (fbn + 1) * BSIZE - off);
    rsect(x, buf);
    bcopy(p, buf + off - (fbn * BSIZE), n1);
    wsect(x, buf);
    n -= n1;
    off += n1;
    p += n1;
  }
  din.size = xint(off);
  winode(inum, &din);
}

// Task 0.
void initialize_mbr(struct mbr* mbr) {
  // initiliaze mbr in the following manner:
  // bootstrap with 0z 446 bytes
  // partitions with 0 16 * 4
  // boot signature 2
  // all in all 512 
  memset(&mbr->bootstrap, 0, sizeof(mbr->bootstrap));
  memset(&mbr->partitions, 0, sizeof(mbr->partitions));
  mbr->magic[0] = 0x55;
  mbr->magic[1] = 0xAA;
}

void add_partition(struct mbr* mbr, struct dpartition* part, int index) {
  memmove(&mbr->partitions[index], part, sizeof(*part));
}

void create_partition(
    struct dpartition* part, char bootable, uint type, uint offset, uint size) {
  SET_BOOTABLE(part, bootable);
  part->type = type;
  part->offset = offset;
  part->size = size;
}
// Writes the kernel to the disk starting at block one. updates the mbr to hold
// the correct bootloader... on success returns the next free block number after
// the kernel on the disk. The disk is fsfd (maybe accept as an argument).
int create_bootload_kernel(struct mbr* mbr, char * bl, char * kern) {
  // First we open the boolloader file (bl) and the kernal file kern - 
  // these files should exist in the current directory as us.
  // step 1: read the bl file into the bootload section of the mbr.
  // step 2: starting from sector 1 start writing the damn kernel file.
  int blfd, kfd, cc, kern_blocks, i;
  char buf[BSIZE];
  blfd = open(bl, O_RDONLY);
  if (blfd < 0) {
    perror(bl);
    return -1;
  }
  kfd = open(kern, O_RDONLY);
  if (kfd < 0) {
    perror(kern);
    close(blfd);
    return -1;
  }
  
  // let us try and read the bootloader into the mbr at most sizeof(bootstap)
  // bytes;
  cc = read(blfd, mbr->bootstrap, sizeof(mbr->bootstrap)); 
  if (cc < 0) {
    return -1;
  }

  // Now we try to write the kernel to the disk starting from block 1
  kern_blocks = 0;
  i = 1;  // block index 
  while ((cc = read(kfd, buf, sizeof(buf))) > 0) {
    ++kern_blocks;
    wsect(i, buf); 
    ++i;
  }
  printf("the kernel took %d blocks \n", kern_blocks);

  // the ith block should be safe for the super block now.
  return i;
}
