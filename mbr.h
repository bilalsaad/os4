#define BOOTSTRAP 446

#define NPARTITIONS 4

#define PART_ALLOCATED	1	// allocated partition
#define PART_BOOTABLE	2	// bootable partition

#define FS_INODE		0 	// inode based partition
#define FS_FAT	 		1	// fat based partition

#define SET_BOOTABLE(p, v) \
  *((char*) &p->flags) = v
#define GET_BOOT(p) \
  *((char*) &((p)->flags))
struct dpartition {
	uint flags;
	uint type;	
	uint offset;
	uint size;
};

// prevents the compiler from aligning (padding) 
// generated code for 4 byte boundary
#pragma pack(1)

struct mbr {
	uchar bootstrap[BOOTSTRAP];
	struct dpartition partitions[NPARTITIONS];
	uchar magic[2];
};

struct partition {
	uint dev;
  struct dpartition prt;
};
