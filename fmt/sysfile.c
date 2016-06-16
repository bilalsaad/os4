5850 //
5851 // File-system system calls.
5852 // Mostly argument checking, since we don't trust
5853 // user code, and calls into file.c and fs.c.
5854 //
5855 
5856 #include "types.h"
5857 #include "defs.h"
5858 #include "param.h"
5859 #include "stat.h"
5860 #include "mmu.h"
5861 #include "proc.h"
5862 #include "fs.h"
5863 #include "file.h"
5864 #include "fcntl.h"
5865 #define d2 cprintf("%d %s \n", __LINE__, __func__)
5866 
5867 // Fetch the nth word-sized system call argument as a file descriptor
5868 // and return both the descriptor and the corresponding struct file.
5869 static int
5870 argfd(int n, int *pfd, struct file **pf)
5871 {
5872   int fd;
5873   struct file *f;
5874 
5875   if(argint(n, &fd) < 0)
5876     return -1;
5877   if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
5878     return -1;
5879   if(pfd)
5880     *pfd = fd;
5881   if(pf)
5882     *pf = f;
5883   return 0;
5884 }
5885 
5886 
5887 
5888 
5889 
5890 
5891 
5892 
5893 
5894 
5895 
5896 
5897 
5898 
5899 
5900 // Allocate a file descriptor for the given file.
5901 // Takes over file reference from caller on success.
5902 static int
5903 fdalloc(struct file *f)
5904 {
5905   int fd;
5906 
5907   for(fd = 0; fd < NOFILE; fd++){
5908     if(proc->ofile[fd] == 0){
5909       proc->ofile[fd] = f;
5910       return fd;
5911     }
5912   }
5913   return -1;
5914 }
5915 
5916 int
5917 sys_dup(void)
5918 {
5919   struct file *f;
5920   int fd;
5921 
5922   if(argfd(0, 0, &f) < 0)
5923     return -1;
5924   if((fd=fdalloc(f)) < 0)
5925     return -1;
5926   filedup(f);
5927   return fd;
5928 }
5929 
5930 int
5931 sys_read(void)
5932 {
5933   struct file *f;
5934   int n;
5935   char *p;
5936 
5937   if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
5938     return -1;
5939   return fileread(f, p, n);
5940 }
5941 
5942 
5943 
5944 
5945 
5946 
5947 
5948 
5949 
5950 int
5951 sys_write(void)
5952 {
5953   struct file *f;
5954   int n;
5955   char *p;
5956 
5957   if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
5958     return -1;
5959   return filewrite(f, p, n);
5960 }
5961 
5962 int
5963 sys_close(void)
5964 {
5965   int fd;
5966   struct file *f;
5967 
5968   if(argfd(0, &fd, &f) < 0)
5969     return -1;
5970   proc->ofile[fd] = 0;
5971   fileclose(f);
5972   return 0;
5973 }
5974 
5975 int
5976 sys_fstat(void)
5977 {
5978   struct file *f;
5979   struct stat *st;
5980 
5981   if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
5982     return -1;
5983   return filestat(f, st);
5984 }
5985 
5986 
5987 
5988 
5989 
5990 
5991 
5992 
5993 
5994 
5995 
5996 
5997 
5998 
5999 
6000 // Create the path new as a link to the same inode as old.
6001 int
6002 sys_link(void)
6003 {
6004   char name[DIRSIZ], *new, *old;
6005   struct inode *dp, *ip;
6006 
6007   if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
6008     return -1;
6009 
6010   begin_op();
6011   if((ip = namei(old)) == 0){
6012     end_op();
6013     return -1;
6014   }
6015 
6016   ilock(ip);
6017   if(ip->type == T_DIR){
6018     iunlockput(ip);
6019     end_op();
6020     return -1;
6021   }
6022 
6023   ip->nlink++;
6024   iupdate(ip);
6025   iunlock(ip);
6026 
6027   if((dp = nameiparent(new, name)) == 0)
6028     goto bad;
6029   ilock(dp);
6030   if(dp->prt != ip->prt || dirlink(dp, name, ip->inum) < 0){
6031     iunlockput(dp);
6032     goto bad;
6033   }
6034   iunlockput(dp);
6035   iput(ip);
6036 
6037   end_op();
6038 
6039   return 0;
6040 
6041 bad:
6042   ilock(ip);
6043   ip->nlink--;
6044   iupdate(ip);
6045   iunlockput(ip);
6046   end_op();
6047   return -1;
6048 }
6049 
6050 // Is the directory dp empty except for "." and ".." ?
6051 static int
6052 isdirempty(struct inode *dp)
6053 {
6054   int off;
6055   struct dirent de;
6056 
6057   for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
6058     if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
6059       panic("isdirempty: readi");
6060     if(de.inum != 0)
6061       return 0;
6062   }
6063   return 1;
6064 }
6065 
6066 
6067 
6068 
6069 
6070 
6071 
6072 
6073 
6074 
6075 
6076 
6077 
6078 
6079 
6080 
6081 
6082 
6083 
6084 
6085 
6086 
6087 
6088 
6089 
6090 
6091 
6092 
6093 
6094 
6095 
6096 
6097 
6098 
6099 
6100 int
6101 sys_unlink(void)
6102 {
6103   struct inode *ip, *dp;
6104   struct dirent de;
6105   char name[DIRSIZ], *path;
6106   uint off;
6107   if(argstr(0, &path) < 0) {
6108     return -1;
6109   }
6110 
6111   begin_op();
6112   if((dp = nameiparent(path, name)) == 0){
6113     end_op();
6114     return -1;
6115   }
6116   ilock(dp);
6117 
6118   // Cannot unlink "." or "..".
6119   if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
6120     goto bad;
6121   if((ip = dirlookup(dp, name, &off)) == 0) {
6122     d2;
6123     goto bad;
6124   }
6125   ilock(ip);
6126   if(ip->nlink < 1)
6127     panic("unlink: nlink < 1");
6128   if(ip->type == T_DIR && !isdirempty(ip)){
6129     d2;
6130     iunlockput(ip);
6131     goto bad;
6132   }
6133   memset(&de, 0, sizeof(de));
6134   if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
6135     panic("unlink: writei");
6136   if(ip->type == T_DIR){
6137     dp->nlink--;
6138     iupdate(dp);
6139   }
6140   iunlockput(dp);
6141   ip->nlink--;
6142   iupdate(ip);
6143   iunlockput(ip);
6144 
6145   end_op();
6146   return 0;
6147 
6148 bad:
6149 
6150   iunlockput(dp);
6151   end_op();
6152   cprintf("failed to unlink %s \n", name);
6153   panic("I AN RAMBOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
6154   return -1;
6155 }
6156 
6157 static struct inode*
6158 create(char *path, short type, short major, short minor)
6159 {
6160   uint off;
6161   struct inode *ip, *dp;
6162   char name[DIRSIZ];
6163 
6164   if((dp = nameiparent(path, name)) == 0)
6165     return 0;
6166   ilock(dp);
6167 
6168   if((ip = dirlookup(dp, name, &off)) != 0){
6169     iunlockput(dp);
6170     ilock(ip);
6171     if(type == T_FILE && ip->type == T_FILE)
6172       return ip;
6173     iunlockput(ip);
6174     return 0;
6175   }
6176 
6177   if((ip = ialloc(dp->prt, type)) == 0)
6178     panic("create: ialloc");
6179   ilock(ip);
6180   ip->major = major;
6181   ip->minor = minor;
6182   ip->nlink = 1;
6183   iupdate(ip);
6184 
6185   if(type == T_DIR){  // Create . and .. entries.
6186     dp->nlink++;  // for ".."
6187     iupdate(dp);
6188     // No ip->nlink++ for ".": avoid cyclic ref count.
6189     if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
6190       panic("create dots");
6191   }
6192 
6193   if(dirlink(dp, name, ip->inum) < 0)
6194     panic("create: dirlink");
6195 
6196   iunlockput(dp);
6197 
6198   return ip;
6199 }
6200 int
6201 sys_open(void)
6202 {
6203   char *path;
6204   int fd, omode;
6205   struct file *f;
6206   struct inode *ip;
6207 
6208   if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
6209     return -1;
6210 
6211   begin_op();
6212 
6213   if(omode & O_CREATE){
6214     ip = create(path, T_FILE, 0, 0);
6215     if(ip == 0){
6216       end_op();
6217       return -1;
6218     }
6219   } else {
6220     if((ip = namei(path)) == 0){
6221       end_op();
6222       return -1;
6223     }
6224     ilock(ip);
6225     if(ip->type == T_DIR && omode != O_RDONLY){
6226       iunlockput(ip);
6227       end_op();
6228       return -1;
6229     }
6230   }
6231 
6232   if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
6233     if(f)
6234       fileclose(f);
6235     iunlockput(ip);
6236     end_op();
6237     return -1;
6238   }
6239   iunlock(ip);
6240   end_op();
6241 
6242   f->type = FD_INODE;
6243   f->ip = ip;
6244   f->off = 0;
6245   f->readable = !(omode & O_WRONLY);
6246   f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
6247   return fd;
6248 }
6249 
6250 int
6251 sys_mkdir(void)
6252 {
6253   char *path;
6254   struct inode *ip;
6255 
6256   begin_op();
6257   if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
6258     end_op();
6259     return -1;
6260   }
6261   iunlockput(ip);
6262   end_op();
6263   return 0;
6264 }
6265 
6266 int
6267 sys_mknod(void)
6268 {
6269   struct inode *ip;
6270   char *path;
6271   int len;
6272   int major, minor;
6273 
6274   begin_op();
6275   if((len=argstr(0, &path)) < 0 ||
6276      argint(1, &major) < 0 ||
6277      argint(2, &minor) < 0 ||
6278      (ip = create(path, T_DEV, major, minor)) == 0){
6279     end_op();
6280     return -1;
6281   }
6282   iunlockput(ip);
6283   end_op();
6284   return 0;
6285 }
6286 
6287 
6288 
6289 
6290 
6291 
6292 
6293 
6294 
6295 
6296 
6297 
6298 
6299 
6300 int
6301 sys_chdir(void)
6302 {
6303   char *path;
6304   struct inode *ip;
6305 
6306   begin_op();
6307   if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
6308     end_op();
6309     return -1;
6310   }
6311   ilock(ip);
6312   if(ip->type != T_DIR){
6313     iunlockput(ip);
6314     end_op();
6315     return -1;
6316   }
6317   iunlock(ip);
6318   iput(proc->cwd);
6319   end_op();
6320   proc->cwd = ip;
6321   return 0;
6322 }
6323 
6324 int
6325 sys_exec(void)
6326 {
6327   char *path, *argv[MAXARG];
6328   int i;
6329   uint uargv, uarg;
6330 
6331   if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
6332     return -1;
6333   }
6334   memset(argv, 0, sizeof(argv));
6335   for(i=0;; i++){
6336     if(i >= NELEM(argv))
6337       return -1;
6338     if(fetchint(uargv+4*i, (int*)&uarg) < 0)
6339       return -1;
6340     if(uarg == 0){
6341       argv[i] = 0;
6342       break;
6343     }
6344     if(fetchstr(uarg, &argv[i]) < 0)
6345       return -1;
6346   }
6347   return exec(path, argv);
6348 }
6349 
6350 int
6351 sys_pipe(void)
6352 {
6353   int *fd;
6354   struct file *rf, *wf;
6355   int fd0, fd1;
6356 
6357   if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
6358     return -1;
6359   if(pipealloc(&rf, &wf) < 0)
6360     return -1;
6361   fd0 = -1;
6362   if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
6363     if(fd0 >= 0)
6364       proc->ofile[fd0] = 0;
6365     fileclose(rf);
6366     fileclose(wf);
6367     return -1;
6368   }
6369   fd[0] = fd0;
6370   fd[1] = fd1;
6371   return 0;
6372 }
6373 
6374 
6375 
6376 
6377 
6378 
6379 
6380 
6381 
6382 
6383 
6384 
6385 
6386 
6387 
6388 
6389 
6390 
6391 
6392 
6393 
6394 
6395 
6396 
6397 
6398 
6399 
