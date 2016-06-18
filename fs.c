// File system implementation.  Five layers:
//   + Blocks: allocator for raw disk blocks.
//   + Log: crash recovery for multi-step updates.
//   + Files: inode allocator, reading, writing, metadata.
//   + Directories: inode with special contents (list of other inodes!)
//   + Names: paths like /usr/rtm/xv6/fs.c for convenient naming.
//
// This file contains the low-level file system manipulation 
// routines.  The (higher-level) system call implementations
// are in sysfile.c.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "stat.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"
#include "fs.h"
#include "buf.h"
#include "file.h"
#include "mbr.h"
#include "x86.h"
#define min(a, b) ((a) < (b) ? (a) : (b))
#define psb   cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d" \
        " inodestart %d bmap start %d\n\n", sb.size, \
        sb.nblocks, sb.ninodes, sb.nlog, \
        sb.logstart, sb.inodestart, sb.bmapstart);
#define pinode(ip) \
    cprintf("ip->inum: %d, ip->prt %p, boot_part %p \n", \
        ip->inum, ip->prt, boot_part);


static void itrunc(struct inode*);
int get_part();
void set_part(int);
struct superblock sb;   // there should be one per dev, but we run with one dev

struct partition partitions[NPARTITIONS];
struct partition* boot_part;      // the partition we boot from.
struct mbr mbr;         // the single mbr - only one mbr i hope to god.



// Mount point table - paths that are mounted 

struct mount_point {
  int is_taken;
  char path[DIRSIZ];  // which path we're talking bout.
  struct partition* prt; // to which partition we're mounted.
  int old_i;
  struct partition* old_prt;
};
struct {
  struct mount_point pnts[MOUNT_POINTS_SIZE];
}mount_points;

// functions for the mount points;

int mount(char* pth, int prt); // adds a new mount point with pth to prt prt.
int is_mounted(char* path); // is the following path mounted or not??.




// Read the super block.
void
readsb(struct partition* part, struct superblock *sb)
{
  struct buf *bp;
  bp = bread(part->dev, part->prt.offset);
  memmove(sb, bp->data, sizeof(*sb));
  brelse(bp);
}
// reads the MBR from block 0 of ROOTDEV (w/e) stores the mbr and prints it out.
void
readmbr(int dev) {
  struct buf *bp;
  struct dpartition* part = mbr.partitions;
  int i;
  struct superblock sb;
  bp = bread(dev, 0); // location of le mbr.
  memmove(&mbr, bp->data, sizeof(mbr));
  brelse(bp);
  // print output of partitions
  for (i = 0; i < NPARTITIONS; ++i) {
    if (part[i].flags != 0) {  // guess this means it exists.
      cprintf("Partition %d; bootable %s, type %s, offset %d, size %d \n",
          i, GET_BOOT((part + i)) == PART_BOOTABLE ? "YES" : "NO",
           part[i].type == FS_INODE ? "INODE" :
           part[i].type == FS_FAT ?   "FAT" :
           "???", part[i].offset, part[i].size);
    }
    partitions[i].dev = dev; 
    partitions[i].prt = part[i];
    readsb(&partitions[i], &sb);
    cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d"
        " inodestart %d bmap start %d\n\n", sb.size,
        sb.nblocks, sb.ninodes, sb.nlog,
        sb.logstart, sb.inodestart, sb.bmapstart);
  }
  while (part != mbr.partitions + NPARTITIONS) {
    if (GET_BOOT(part) == PART_BOOTABLE) {
      set_part(part - mbr.partitions);
      boot_part = partitions + (part - mbr.partitions);
      cprintf("setting current partition to %d \n", part - mbr.partitions);
      return;
    }
    ++part;
  }
  panic("no bootable partition found");
}

// Zero a block.
static void
bzero(int dev, int bno)
{
  struct buf *bp;
  
  bp = bread(dev, bno);
  memset(bp->data, 0, BSIZE);
  log_write(bp);
  brelse(bp);
}

// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(struct partition* prt)
{
  int b, bi, m;
  uint freeblock_offset;
  struct buf *bp;
  struct superblock sb;
  uint dev = prt->dev;
  readsb(prt, &sb);
//  psb;
  freeblock_offset = sb.bmapstart + 1;
  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    if (0 && proc && proc->pid > 2) {
      cprintf("bread(%d, %d) \n",dev, BBLOCK(b, sb));
    }
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use.
        log_write(bp);
        brelse(bp);
        // TODO(bilals) should an offset be added here?
        bzero(dev, freeblock_offset + b + bi);
        if(0 && proc && proc->pid > 2) {
          cprintf("balloc'd %d \n", freeblock_offset+b+bi);
        }
        return freeblock_offset + b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}

// Free a disk block.
static void
bfree(struct partition* prt, uint b)
{
  struct buf *bp;
  int bi, m;
  uint freeblock_offset;
  struct superblock sb;
  readsb(prt, &sb);
  freeblock_offset = sb.bmapstart + 1;
  b = b - freeblock_offset ;
  bp = bread(prt->dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0) {
    cprintf("tried to free blockno %d \n", b);
    panic("freeing free block");
  }
  bp->data[bi/8] &= ~m;
  log_write(bp);
  brelse(bp);
}

// Inodes.
//
// An inode describes a single unnamed file.
// The inode disk structure holds metadata: the file's type,
// its size, the number of links referring to it, and the
// list of blocks holding the file's content.
//
// The inodes are laid out sequentially on disk at
// sb.startinode. Each inode has a number, indicating its
// position on the disk.
//
// The kernel keeps a cache of in-use inodes in memory
// to provide a place for synchronizing access
// to inodes used by multiple processes. The cached
// inodes include book-keeping information that is
// not stored on disk: ip->ref and ip->flags.
//
// An inode and its in-memory represtative go through a
// sequence of states before they can be used by the
// rest of the file system code.
//
// * Allocation: an inode is allocated if its type (on disk)
//   is non-zero. ialloc() allocates, iput() frees if
//   the link count has fallen to zero.
//
// * Referencing in cache: an entry in the inode cache
//   is free if ip->ref is zero. Otherwise ip->ref tracks
//   the number of in-memory pointers to the entry (open
//   files and current directories). iget() to find or
//   create a cache entry and increment its ref, iput()
//   to decrement ref.
//
// * Valid: the information (type, size, &c) in an inode
//   cache entry is only correct when the I_VALID bit
//   is set in ip->flags. ilock() reads the inode from
//   the disk and sets I_VALID, while iput() clears
//   I_VALID if ip->ref has fallen to zero.
//
// * Locked: file system code may only examine and modify
//   the information in an inode and its content if it
//   has first locked the inode. The I_BUSY flag indicates
//   that the inode is locked. ilock() sets I_BUSY,
//   while iunlock clears it.
//
// Thus a typical sequence is:
//   ip = iget(dev, inum)
//   ilock(ip)
//   ... examine and modify ip->xxx ...
//   iunlock(ip)
//   iput(ip)
//
// ilock() is separate from iget() so that system calls can
// get a long-term reference to an inode (as for an open file)
// and only lock it for short periods (e.g., in read()).
// The separation also helps avoid deadlock and races during
// pathname lookup. iget() increments ip->ref so that the inode
// stays cached and pointers to it remain valid.
//
// Many internal file system functions expect the caller to
// have locked the inodes involved; this lets callers create
// multi-step atomic operations.

struct {
  struct spinlock lock;
  struct inode inode[NINODE];
} icache;

static struct inode* iget(struct partition*, uint inum);
void
iinit(int dev)
{
  struct inode* ip;
  initlock(&icache.lock, "icache");
  readmbr(dev);
  readsb(boot_part, &sb);
  // this should make sure that rooino->prt is the boot block.
  ip = iget(boot_part, ROOTINO);
  proc->cwd = ip;
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d"
          " inodestart %d bmap start %d\n", sb.size,
          sb.nblocks, sb.ninodes, sb.nlog,
          sb.logstart, sb.inodestart, sb.bmapstart);
}


//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(struct partition* prt, short type)
{
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;
  uint dev = prt->dev;
  readsb(prt, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){
    bp = bread(dev, IBLOCK(inum, sb));
    dip = (struct dinode*)bp->data + inum%IPB;
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(prt, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb; 
  readsb(ip->prt, &sb);
  bp = bread(ip->prt->dev, IBLOCK(ip->inum, sb));
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  log_write(bp);
  brelse(bp);
}

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(struct partition* prt, uint inum)
{
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    if(ip->ref > 0 && ip->prt == prt && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
    panic("iget: no inodes");
  ip = empty;
  ip->prt = prt;
  ip->inum = inum;
  ip->ref = 1;
  ip->flags = 0;
  ip->mnt_info.is_mnt = 0;
  release(&icache.lock);

  return ip;
}

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
  acquire(&icache.lock);
  ip->ref++;
  release(&icache.lock);
  return ip;
}

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;
  if(ip == 0 || ip->ref < 1)
    panic("ilock");
  if (ip->prt == 0) {
    cprintf("ip w/- prt: %p : inum: %d major: %d minor: %d prt: %p\n", ip,
        ip->inum, ip->major, ip->minor, ip->prt);
    panic("ilock no partition");
  }
  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  release(&icache.lock);
  readsb(ip->prt, &sb);
  if(!(ip->flags & I_VALID)){
    bp = bread(ip->prt->dev, IBLOCK(ip->inum, sb));
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    brelse(bp);
    ip->flags |= I_VALID;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
    panic("iunlock");

  acquire(&icache.lock);
  ip->flags &= ~I_BUSY;
  wakeup(ip);
  release(&icache.lock);
}

// Drop a reference to an in-memory inode.
// If that was the last reference, the inode cache entry can
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
    itrunc(ip);
    ip->type = 0;
    iupdate(ip);
    acquire(&icache.lock);
    ip->flags = 0;
    wakeup(ip);
  }
  ip->ref--;
  release(&icache.lock);
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
}

//PAGEBREAK!
// Inode content
//
// The content (data) associated with each inode is stored
// in blocks on the disk. The first NDIRECT block numbers
// are listed in ip->addrs[].  The next NINDIRECT blocks are 
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0) {
      ip->addrs[bn] = addr = balloc(ip->prt);
    }
    return addr;
  }
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0) {
      ip->addrs[NDIRECT] = addr = balloc(ip->prt);
    }
    bp = bread(ip->prt->dev, addr);
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
      a[bn] = addr = balloc(ip->prt);
      log_write(bp);
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}

// Truncate inode (discard contents).
// Only called when the inode has no links
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    if(ip->addrs[i]){
      bfree(ip->prt, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->prt->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
      if(a[j])
        bfree(ip->prt, a[j]);
    }
    brelse(bp);
    bfree(ip->prt, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
}

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
  // TODO() what should be done with stat
  st->dev = ip->prt->dev;
  st->ino = ip->inum;
  st->type = ip->type;
  st->nlink = ip->nlink;
  st->size = ip->size;
}

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->prt->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->prt->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}

//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
  return strncmp(s, t, DIRSIZ);
}

static int is_inode_mounted(struct inode*, int*, struct partition**);

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
  uint off, inum;
  int mnt_in;
  struct partition* mnt_prt;
  struct dirent de;
  int flag = is_inode_mounted(dp, &mnt_in, &mnt_prt);
  dp = flag ? iget(mnt_prt, mnt_in) : dp;
  if(dp->type != T_DIR) {
    pinode(dp);
    panic("dirlookup not DIR");
  }

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
      // entry matches path element
      if(poff)
        *poff = off;
      inum = de.inum;
      return iget(dp->prt, inum);
   }
  }
  return 0;
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
  
  return 0;
}

//PAGEBREAK!
// Paths

// Copy the next path element from path into name.
// Return a pointer to the element following the copied one.
// The returned path has no leading slashes,
// so the caller can check *path=='\0' to see if the name is the last one.
// If no name to remove, return 0.
//
// Examples:
//   skipelem("a/bb/c", name) = "bb/c", setting name = "a"
//   skipelem("///a//bb", name) = "bb", setting name = "a"
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
    path++;
  return path;
}
static struct mount_point* find_mp(char* path);
#define d4 if (flag) d3
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;
  int flag = 0; 
  if (is_mounted(path)) {
    ip = iget(find_mp(path)->prt, ROOTINO);
    path = "/"; 
    flag = 1;
  } else if(*path == '/')
    ip = iget(boot_part, ROOTINO);
  else {
    ip = idup(proc->cwd);
  }
  if (flag) {
    cprintf("ip->inum: %d, ip->prt %p, boot_part %p \n",
        ip->inum, ip->prt, boot_part);
  }
  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
      return 0;
    }
    
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
      cprintf("call to dirlookup failed w/ :  ");
      cprintf("path:%s name: %s \n", path, name);
      cprintf("ip->inum: %d, ip->prt %p, boot_part %p \n",
          ip->inum, ip->prt, boot_part);
      
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}

struct inode*
namei(char *path)
{
  char name[DIRSIZ];
  struct inode* ret;
  
  ret = namex(path, 0, name);
  if (!ret ) {
    name[DIRSIZ] = 0;
    cprintf("namex failed path %s name %s \n", path, name);
  }  
  return ret;
}

struct inode*
nameiparent(char *path, char *name)
{
  struct inode* ret;
  
  ret =  namex(path, 1, name);
  
  return ret;
}

// TODO() think this over..
static int cur_part;
int get_part() {
  return cur_part;
}

void set_part(int p) {
  cur_part = p; 
}
struct partition* get_boot_block() {
  return boot_part;
}

static struct mount_point* find_mp(char* path) {
  struct mount_point* it = mount_points.pnts;
  while(it < MOUNT_POINTS_SIZE +  mount_points.pnts) {
    if(namecmp(path, it->path) == 0){
      return it;
    }
    ++it;
  }
  return 0;
}

static int is_inode_mounted(struct inode* in,
    int* new_i, struct partition** new_p) {
  struct mount_point* it = mount_points.pnts;
  while(it < MOUNT_POINTS_SIZE +  mount_points.pnts) {
    if(it->old_i == in->inum && it->old_prt == in->prt){
      *new_i = ROOTINO;
      *new_p = it->prt;
      return 1;
    }
    ++it;
  }
  return 0;
}

static struct mount_point* mpalloc(struct mount_point* pnts) {
  struct mount_point* it = pnts;
  while (it < pnts + MOUNT_POINTS_SIZE) {
    if (cas(&it->is_taken, 0, 1)){
      return it;
    }
    ++it;
  }
  return 0;
}

int is_mounted(char* p) {
  return find_mp(p) != 0;
}
// How should we deal with allready mounted paths?
int mount(char* path, int i) {
  struct mount_point* pnt;
  struct inode* in = namei(path);
  if (in == 0) {
    cprintf("cannot mount non existing path %s \n", path);
    return -1;
  }
  if (is_mounted(path)) {
    cprintf("trying to mount an allready mounted path - %s \n", path);
    return -1;
  }
  pnt = mpalloc(mount_points.pnts); 
  if (pnt == 0) {
    cprintf("failed to alloc mp \n");
    return -1;
  }
  memmove(pnt->path, path, sizeof(pnt->path));  
  pnt->prt = &partitions[i];
  pnt->old_i = in->inum;
  pnt->old_prt = in->prt;
  return 0;
}

