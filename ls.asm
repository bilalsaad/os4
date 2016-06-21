
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	8b 45 08             	mov    0x8(%ebp),%eax
   a:	89 04 24             	mov    %eax,(%esp)
   d:	e8 1d 04 00 00       	call   42f <strlen>
  12:	8b 55 08             	mov    0x8(%ebp),%edx
  15:	01 d0                	add    %edx,%eax
  17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1a:	eb 04                	jmp    20 <fmtname+0x20>
  1c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  23:	3b 45 08             	cmp    0x8(%ebp),%eax
  26:	72 0a                	jb     32 <fmtname+0x32>
  28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2b:	0f b6 00             	movzbl (%eax),%eax
  2e:	3c 2f                	cmp    $0x2f,%al
  30:	75 ea                	jne    1c <fmtname+0x1c>
    ;
  p++;
  32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  39:	89 04 24             	mov    %eax,(%esp)
  3c:	e8 ee 03 00 00       	call   42f <strlen>
  41:	83 f8 0d             	cmp    $0xd,%eax
  44:	76 05                	jbe    4b <fmtname+0x4b>
    return p;
  46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  49:	eb 5f                	jmp    aa <fmtname+0xaa>
  memmove(buf, p, strlen(p));
  4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4e:	89 04 24             	mov    %eax,(%esp)
  51:	e8 d9 03 00 00       	call   42f <strlen>
  56:	89 44 24 08          	mov    %eax,0x8(%esp)
  5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  61:	c7 04 24 8c 0e 00 00 	movl   $0xe8c,(%esp)
  68:	e8 51 05 00 00       	call   5be <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  70:	89 04 24             	mov    %eax,(%esp)
  73:	e8 b7 03 00 00       	call   42f <strlen>
  78:	ba 0e 00 00 00       	mov    $0xe,%edx
  7d:	89 d3                	mov    %edx,%ebx
  7f:	29 c3                	sub    %eax,%ebx
  81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  84:	89 04 24             	mov    %eax,(%esp)
  87:	e8 a3 03 00 00       	call   42f <strlen>
  8c:	05 8c 0e 00 00       	add    $0xe8c,%eax
  91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  95:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  9c:	00 
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 b1 03 00 00       	call   456 <memset>
  return buf;
  a5:	b8 8c 0e 00 00       	mov    $0xe8c,%eax
}
  aa:	83 c4 24             	add    $0x24,%esp
  ad:	5b                   	pop    %ebx
  ae:	5d                   	pop    %ebp
  af:	c3                   	ret    

000000b0 <ls>:

void
ls(char *path)
{
  b0:	55                   	push   %ebp
  b1:	89 e5                	mov    %esp,%ebp
  b3:	57                   	push   %edi
  b4:	56                   	push   %esi
  b5:	53                   	push   %ebx
  b6:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
  bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c3:	00 
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	89 04 24             	mov    %eax,(%esp)
  ca:	e8 74 05 00 00       	call   643 <open>
  cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d6:	79 20                	jns    f8 <ls+0x48>
    printf(2, "ls: cannot open %s\n", path);
  d8:	8b 45 08             	mov    0x8(%ebp),%eax
  db:	89 44 24 08          	mov    %eax,0x8(%esp)
  df:	c7 44 24 04 58 0b 00 	movl   $0xb58,0x4(%esp)
  e6:	00 
  e7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ee:	e8 98 06 00 00       	call   78b <printf>
    return;
  f3:	e9 41 02 00 00       	jmp    339 <ls+0x289>
  }
  
  if(fstat(fd, &st) < 0){
  f8:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
  fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 105:	89 04 24             	mov    %eax,(%esp)
 108:	e8 4e 05 00 00       	call   65b <fstat>
 10d:	85 c0                	test   %eax,%eax
 10f:	79 2b                	jns    13c <ls+0x8c>
    printf(2, "ls: cannot stat %s\n", path);
 111:	8b 45 08             	mov    0x8(%ebp),%eax
 114:	89 44 24 08          	mov    %eax,0x8(%esp)
 118:	c7 44 24 04 6c 0b 00 	movl   $0xb6c,0x4(%esp)
 11f:	00 
 120:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 127:	e8 5f 06 00 00       	call   78b <printf>
    close(fd);
 12c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 12f:	89 04 24             	mov    %eax,(%esp)
 132:	e8 f4 04 00 00       	call   62b <close>
    return;
 137:	e9 fd 01 00 00       	jmp    339 <ls+0x289>
  }
  printf(1,"--- name --- type --- inum --- sz --- prti --- \n");  
 13c:	c7 44 24 04 80 0b 00 	movl   $0xb80,0x4(%esp)
 143:	00 
 144:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 14b:	e8 3b 06 00 00       	call   78b <printf>
  switch(st.type){
 150:	0f b7 85 b8 fd ff ff 	movzwl -0x248(%ebp),%eax
 157:	98                   	cwtl   
 158:	83 f8 01             	cmp    $0x1,%eax
 15b:	74 69                	je     1c6 <ls+0x116>
 15d:	83 f8 02             	cmp    $0x2,%eax
 160:	0f 85 c8 01 00 00    	jne    32e <ls+0x27e>
  case T_FILE:
    printf(1, "%s %d %d %d %d\n",
 166:	8b 85 cc fd ff ff    	mov    -0x234(%ebp),%eax
 16c:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
 172:	8b bd c8 fd ff ff    	mov    -0x238(%ebp),%edi
 178:	8b b5 c0 fd ff ff    	mov    -0x240(%ebp),%esi
        fmtname(path), st.type, st.ino, st.size, st.prti);
 17e:	0f b7 85 b8 fd ff ff 	movzwl -0x248(%ebp),%eax
    return;
  }
  printf(1,"--- name --- type --- inum --- sz --- prti --- \n");  
  switch(st.type){
  case T_FILE:
    printf(1, "%s %d %d %d %d\n",
 185:	0f bf d8             	movswl %ax,%ebx
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	89 04 24             	mov    %eax,(%esp)
 18e:	e8 6d fe ff ff       	call   0 <fmtname>
 193:	8b 8d b4 fd ff ff    	mov    -0x24c(%ebp),%ecx
 199:	89 4c 24 18          	mov    %ecx,0x18(%esp)
 19d:	89 7c 24 14          	mov    %edi,0x14(%esp)
 1a1:	89 74 24 10          	mov    %esi,0x10(%esp)
 1a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 1a9:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ad:	c7 44 24 04 b1 0b 00 	movl   $0xbb1,0x4(%esp)
 1b4:	00 
 1b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bc:	e8 ca 05 00 00       	call   78b <printf>
        fmtname(path), st.type, st.ino, st.size, st.prti);
    break;
 1c1:	e9 68 01 00 00       	jmp    32e <ls+0x27e>
  
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 1c6:	8b 45 08             	mov    0x8(%ebp),%eax
 1c9:	89 04 24             	mov    %eax,(%esp)
 1cc:	e8 5e 02 00 00       	call   42f <strlen>
 1d1:	83 c0 10             	add    $0x10,%eax
 1d4:	3d 00 02 00 00       	cmp    $0x200,%eax
 1d9:	76 19                	jbe    1f4 <ls+0x144>
      printf(1, "ls: path too long\n");
 1db:	c7 44 24 04 c1 0b 00 	movl   $0xbc1,0x4(%esp)
 1e2:	00 
 1e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ea:	e8 9c 05 00 00       	call   78b <printf>
      break;
 1ef:	e9 3a 01 00 00       	jmp    32e <ls+0x27e>
    }
    strcpy(buf, path);
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
 1f7:	89 44 24 04          	mov    %eax,0x4(%esp)
 1fb:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 201:	89 04 24             	mov    %eax,(%esp)
 204:	e8 b7 01 00 00       	call   3c0 <strcpy>
    p = buf+strlen(buf);
 209:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 20f:	89 04 24             	mov    %eax,(%esp)
 212:	e8 18 02 00 00       	call   42f <strlen>
 217:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 21d:	01 d0                	add    %edx,%eax
 21f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 222:	8b 45 e0             	mov    -0x20(%ebp),%eax
 225:	8d 50 01             	lea    0x1(%eax),%edx
 228:	89 55 e0             	mov    %edx,-0x20(%ebp)
 22b:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 22e:	e9 d4 00 00 00       	jmp    307 <ls+0x257>
      if(de.inum == 0)
 233:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 23a:	66 85 c0             	test   %ax,%ax
 23d:	75 05                	jne    244 <ls+0x194>
        continue;
 23f:	e9 c3 00 00 00       	jmp    307 <ls+0x257>
      memmove(p, de.name, DIRSIZ);
 244:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 24b:	00 
 24c:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 252:	83 c0 02             	add    $0x2,%eax
 255:	89 44 24 04          	mov    %eax,0x4(%esp)
 259:	8b 45 e0             	mov    -0x20(%ebp),%eax
 25c:	89 04 24             	mov    %eax,(%esp)
 25f:	e8 5a 03 00 00       	call   5be <memmove>
      p[DIRSIZ] = 0;
 264:	8b 45 e0             	mov    -0x20(%ebp),%eax
 267:	83 c0 0e             	add    $0xe,%eax
 26a:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 26d:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
 273:	89 44 24 04          	mov    %eax,0x4(%esp)
 277:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 27d:	89 04 24             	mov    %eax,(%esp)
 280:	e8 9e 02 00 00       	call   523 <stat>
 285:	85 c0                	test   %eax,%eax
 287:	79 20                	jns    2a9 <ls+0x1f9>
        printf(1, "ls: cannot stat %s\n", buf);
 289:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 28f:	89 44 24 08          	mov    %eax,0x8(%esp)
 293:	c7 44 24 04 6c 0b 00 	movl   $0xb6c,0x4(%esp)
 29a:	00 
 29b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2a2:	e8 e4 04 00 00       	call   78b <printf>
        continue;
 2a7:	eb 5e                	jmp    307 <ls+0x257>
      }
      printf(1, "%s %d %d %d %d\n",
 2a9:	8b 85 cc fd ff ff    	mov    -0x234(%ebp),%eax
 2af:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
 2b5:	8b bd c8 fd ff ff    	mov    -0x238(%ebp),%edi
 2bb:	8b b5 c0 fd ff ff    	mov    -0x240(%ebp),%esi
          fmtname(buf), st.type, st.ino, st.size, st.prti);
 2c1:	0f b7 85 b8 fd ff ff 	movzwl -0x248(%ebp),%eax
      p[DIRSIZ] = 0;
      if(stat(buf, &st) < 0){
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d %d\n",
 2c8:	0f bf d8             	movswl %ax,%ebx
 2cb:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 2d1:	89 04 24             	mov    %eax,(%esp)
 2d4:	e8 27 fd ff ff       	call   0 <fmtname>
 2d9:	8b 8d b4 fd ff ff    	mov    -0x24c(%ebp),%ecx
 2df:	89 4c 24 18          	mov    %ecx,0x18(%esp)
 2e3:	89 7c 24 14          	mov    %edi,0x14(%esp)
 2e7:	89 74 24 10          	mov    %esi,0x10(%esp)
 2eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2ef:	89 44 24 08          	mov    %eax,0x8(%esp)
 2f3:	c7 44 24 04 b1 0b 00 	movl   $0xbb1,0x4(%esp)
 2fa:	00 
 2fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 302:	e8 84 04 00 00       	call   78b <printf>
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 307:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 30e:	00 
 30f:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 315:	89 44 24 04          	mov    %eax,0x4(%esp)
 319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 31c:	89 04 24             	mov    %eax,(%esp)
 31f:	e8 f7 02 00 00       	call   61b <read>
 324:	83 f8 10             	cmp    $0x10,%eax
 327:	0f 84 06 ff ff ff    	je     233 <ls+0x183>
        continue;
      }
      printf(1, "%s %d %d %d %d\n",
          fmtname(buf), st.type, st.ino, st.size, st.prti);
    }
    break;
 32d:	90                   	nop
  }
  close(fd);
 32e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 331:	89 04 24             	mov    %eax,(%esp)
 334:	e8 f2 02 00 00       	call   62b <close>
}
 339:	81 c4 5c 02 00 00    	add    $0x25c,%esp
 33f:	5b                   	pop    %ebx
 340:	5e                   	pop    %esi
 341:	5f                   	pop    %edi
 342:	5d                   	pop    %ebp
 343:	c3                   	ret    

00000344 <main>:

int
main(int argc, char *argv[])
{
 344:	55                   	push   %ebp
 345:	89 e5                	mov    %esp,%ebp
 347:	83 e4 f0             	and    $0xfffffff0,%esp
 34a:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
 34d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 351:	7f 11                	jg     364 <main+0x20>
    ls(".");
 353:	c7 04 24 d4 0b 00 00 	movl   $0xbd4,(%esp)
 35a:	e8 51 fd ff ff       	call   b0 <ls>
    exit();
 35f:	e8 9f 02 00 00       	call   603 <exit>
  }
  for(i=1; i<argc; i++)
 364:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 36b:	00 
 36c:	eb 1f                	jmp    38d <main+0x49>
    ls(argv[i]);
 36e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 372:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 379:	8b 45 0c             	mov    0xc(%ebp),%eax
 37c:	01 d0                	add    %edx,%eax
 37e:	8b 00                	mov    (%eax),%eax
 380:	89 04 24             	mov    %eax,(%esp)
 383:	e8 28 fd ff ff       	call   b0 <ls>

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 388:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 38d:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 391:	3b 45 08             	cmp    0x8(%ebp),%eax
 394:	7c d8                	jl     36e <main+0x2a>
    ls(argv[i]);
  exit();
 396:	e8 68 02 00 00       	call   603 <exit>

0000039b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 39b:	55                   	push   %ebp
 39c:	89 e5                	mov    %esp,%ebp
 39e:	57                   	push   %edi
 39f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3a3:	8b 55 10             	mov    0x10(%ebp),%edx
 3a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a9:	89 cb                	mov    %ecx,%ebx
 3ab:	89 df                	mov    %ebx,%edi
 3ad:	89 d1                	mov    %edx,%ecx
 3af:	fc                   	cld    
 3b0:	f3 aa                	rep stos %al,%es:(%edi)
 3b2:	89 ca                	mov    %ecx,%edx
 3b4:	89 fb                	mov    %edi,%ebx
 3b6:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3b9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3bc:	5b                   	pop    %ebx
 3bd:	5f                   	pop    %edi
 3be:	5d                   	pop    %ebp
 3bf:	c3                   	ret    

000003c0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3c0:	55                   	push   %ebp
 3c1:	89 e5                	mov    %esp,%ebp
 3c3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3c6:	8b 45 08             	mov    0x8(%ebp),%eax
 3c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3cc:	90                   	nop
 3cd:	8b 45 08             	mov    0x8(%ebp),%eax
 3d0:	8d 50 01             	lea    0x1(%eax),%edx
 3d3:	89 55 08             	mov    %edx,0x8(%ebp)
 3d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 3d9:	8d 4a 01             	lea    0x1(%edx),%ecx
 3dc:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 3df:	0f b6 12             	movzbl (%edx),%edx
 3e2:	88 10                	mov    %dl,(%eax)
 3e4:	0f b6 00             	movzbl (%eax),%eax
 3e7:	84 c0                	test   %al,%al
 3e9:	75 e2                	jne    3cd <strcpy+0xd>
    ;
  return os;
 3eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ee:	c9                   	leave  
 3ef:	c3                   	ret    

000003f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3f3:	eb 08                	jmp    3fd <strcmp+0xd>
    p++, q++;
 3f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3f9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3fd:	8b 45 08             	mov    0x8(%ebp),%eax
 400:	0f b6 00             	movzbl (%eax),%eax
 403:	84 c0                	test   %al,%al
 405:	74 10                	je     417 <strcmp+0x27>
 407:	8b 45 08             	mov    0x8(%ebp),%eax
 40a:	0f b6 10             	movzbl (%eax),%edx
 40d:	8b 45 0c             	mov    0xc(%ebp),%eax
 410:	0f b6 00             	movzbl (%eax),%eax
 413:	38 c2                	cmp    %al,%dl
 415:	74 de                	je     3f5 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 417:	8b 45 08             	mov    0x8(%ebp),%eax
 41a:	0f b6 00             	movzbl (%eax),%eax
 41d:	0f b6 d0             	movzbl %al,%edx
 420:	8b 45 0c             	mov    0xc(%ebp),%eax
 423:	0f b6 00             	movzbl (%eax),%eax
 426:	0f b6 c0             	movzbl %al,%eax
 429:	29 c2                	sub    %eax,%edx
 42b:	89 d0                	mov    %edx,%eax
}
 42d:	5d                   	pop    %ebp
 42e:	c3                   	ret    

0000042f <strlen>:

uint
strlen(char *s)
{
 42f:	55                   	push   %ebp
 430:	89 e5                	mov    %esp,%ebp
 432:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 435:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 43c:	eb 04                	jmp    442 <strlen+0x13>
 43e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 442:	8b 55 fc             	mov    -0x4(%ebp),%edx
 445:	8b 45 08             	mov    0x8(%ebp),%eax
 448:	01 d0                	add    %edx,%eax
 44a:	0f b6 00             	movzbl (%eax),%eax
 44d:	84 c0                	test   %al,%al
 44f:	75 ed                	jne    43e <strlen+0xf>
    ;
  return n;
 451:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 454:	c9                   	leave  
 455:	c3                   	ret    

00000456 <memset>:

void*
memset(void *dst, int c, uint n)
{
 456:	55                   	push   %ebp
 457:	89 e5                	mov    %esp,%ebp
 459:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 45c:	8b 45 10             	mov    0x10(%ebp),%eax
 45f:	89 44 24 08          	mov    %eax,0x8(%esp)
 463:	8b 45 0c             	mov    0xc(%ebp),%eax
 466:	89 44 24 04          	mov    %eax,0x4(%esp)
 46a:	8b 45 08             	mov    0x8(%ebp),%eax
 46d:	89 04 24             	mov    %eax,(%esp)
 470:	e8 26 ff ff ff       	call   39b <stosb>
  return dst;
 475:	8b 45 08             	mov    0x8(%ebp),%eax
}
 478:	c9                   	leave  
 479:	c3                   	ret    

0000047a <strchr>:

char*
strchr(const char *s, char c)
{
 47a:	55                   	push   %ebp
 47b:	89 e5                	mov    %esp,%ebp
 47d:	83 ec 04             	sub    $0x4,%esp
 480:	8b 45 0c             	mov    0xc(%ebp),%eax
 483:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 486:	eb 14                	jmp    49c <strchr+0x22>
    if(*s == c)
 488:	8b 45 08             	mov    0x8(%ebp),%eax
 48b:	0f b6 00             	movzbl (%eax),%eax
 48e:	3a 45 fc             	cmp    -0x4(%ebp),%al
 491:	75 05                	jne    498 <strchr+0x1e>
      return (char*)s;
 493:	8b 45 08             	mov    0x8(%ebp),%eax
 496:	eb 13                	jmp    4ab <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 498:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 49c:	8b 45 08             	mov    0x8(%ebp),%eax
 49f:	0f b6 00             	movzbl (%eax),%eax
 4a2:	84 c0                	test   %al,%al
 4a4:	75 e2                	jne    488 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 4a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4ab:	c9                   	leave  
 4ac:	c3                   	ret    

000004ad <gets>:

char*
gets(char *buf, int max)
{
 4ad:	55                   	push   %ebp
 4ae:	89 e5                	mov    %esp,%ebp
 4b0:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4ba:	eb 4c                	jmp    508 <gets+0x5b>
    cc = read(0, &c, 1);
 4bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4c3:	00 
 4c4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4d2:	e8 44 01 00 00       	call   61b <read>
 4d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4de:	7f 02                	jg     4e2 <gets+0x35>
      break;
 4e0:	eb 31                	jmp    513 <gets+0x66>
    buf[i++] = c;
 4e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e5:	8d 50 01             	lea    0x1(%eax),%edx
 4e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4eb:	89 c2                	mov    %eax,%edx
 4ed:	8b 45 08             	mov    0x8(%ebp),%eax
 4f0:	01 c2                	add    %eax,%edx
 4f2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4f6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4f8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4fc:	3c 0a                	cmp    $0xa,%al
 4fe:	74 13                	je     513 <gets+0x66>
 500:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 504:	3c 0d                	cmp    $0xd,%al
 506:	74 0b                	je     513 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 508:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50b:	83 c0 01             	add    $0x1,%eax
 50e:	3b 45 0c             	cmp    0xc(%ebp),%eax
 511:	7c a9                	jl     4bc <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 513:	8b 55 f4             	mov    -0xc(%ebp),%edx
 516:	8b 45 08             	mov    0x8(%ebp),%eax
 519:	01 d0                	add    %edx,%eax
 51b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 51e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 521:	c9                   	leave  
 522:	c3                   	ret    

00000523 <stat>:

int
stat(char *n, struct stat *st)
{
 523:	55                   	push   %ebp
 524:	89 e5                	mov    %esp,%ebp
 526:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 529:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 530:	00 
 531:	8b 45 08             	mov    0x8(%ebp),%eax
 534:	89 04 24             	mov    %eax,(%esp)
 537:	e8 07 01 00 00       	call   643 <open>
 53c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 53f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 543:	79 07                	jns    54c <stat+0x29>
    return -1;
 545:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 54a:	eb 23                	jmp    56f <stat+0x4c>
  r = fstat(fd, st);
 54c:	8b 45 0c             	mov    0xc(%ebp),%eax
 54f:	89 44 24 04          	mov    %eax,0x4(%esp)
 553:	8b 45 f4             	mov    -0xc(%ebp),%eax
 556:	89 04 24             	mov    %eax,(%esp)
 559:	e8 fd 00 00 00       	call   65b <fstat>
 55e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 561:	8b 45 f4             	mov    -0xc(%ebp),%eax
 564:	89 04 24             	mov    %eax,(%esp)
 567:	e8 bf 00 00 00       	call   62b <close>
  return r;
 56c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 56f:	c9                   	leave  
 570:	c3                   	ret    

00000571 <atoi>:

int
atoi(const char *s)
{
 571:	55                   	push   %ebp
 572:	89 e5                	mov    %esp,%ebp
 574:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 577:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 57e:	eb 25                	jmp    5a5 <atoi+0x34>
    n = n*10 + *s++ - '0';
 580:	8b 55 fc             	mov    -0x4(%ebp),%edx
 583:	89 d0                	mov    %edx,%eax
 585:	c1 e0 02             	shl    $0x2,%eax
 588:	01 d0                	add    %edx,%eax
 58a:	01 c0                	add    %eax,%eax
 58c:	89 c1                	mov    %eax,%ecx
 58e:	8b 45 08             	mov    0x8(%ebp),%eax
 591:	8d 50 01             	lea    0x1(%eax),%edx
 594:	89 55 08             	mov    %edx,0x8(%ebp)
 597:	0f b6 00             	movzbl (%eax),%eax
 59a:	0f be c0             	movsbl %al,%eax
 59d:	01 c8                	add    %ecx,%eax
 59f:	83 e8 30             	sub    $0x30,%eax
 5a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5a5:	8b 45 08             	mov    0x8(%ebp),%eax
 5a8:	0f b6 00             	movzbl (%eax),%eax
 5ab:	3c 2f                	cmp    $0x2f,%al
 5ad:	7e 0a                	jle    5b9 <atoi+0x48>
 5af:	8b 45 08             	mov    0x8(%ebp),%eax
 5b2:	0f b6 00             	movzbl (%eax),%eax
 5b5:	3c 39                	cmp    $0x39,%al
 5b7:	7e c7                	jle    580 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 5b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5bc:	c9                   	leave  
 5bd:	c3                   	ret    

000005be <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 5be:	55                   	push   %ebp
 5bf:	89 e5                	mov    %esp,%ebp
 5c1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 5c4:	8b 45 08             	mov    0x8(%ebp),%eax
 5c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 5cd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5d0:	eb 17                	jmp    5e9 <memmove+0x2b>
    *dst++ = *src++;
 5d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d5:	8d 50 01             	lea    0x1(%eax),%edx
 5d8:	89 55 fc             	mov    %edx,-0x4(%ebp)
 5db:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5de:	8d 4a 01             	lea    0x1(%edx),%ecx
 5e1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 5e4:	0f b6 12             	movzbl (%edx),%edx
 5e7:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5e9:	8b 45 10             	mov    0x10(%ebp),%eax
 5ec:	8d 50 ff             	lea    -0x1(%eax),%edx
 5ef:	89 55 10             	mov    %edx,0x10(%ebp)
 5f2:	85 c0                	test   %eax,%eax
 5f4:	7f dc                	jg     5d2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5f6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5f9:	c9                   	leave  
 5fa:	c3                   	ret    

000005fb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5fb:	b8 01 00 00 00       	mov    $0x1,%eax
 600:	cd 40                	int    $0x40
 602:	c3                   	ret    

00000603 <exit>:
SYSCALL(exit)
 603:	b8 02 00 00 00       	mov    $0x2,%eax
 608:	cd 40                	int    $0x40
 60a:	c3                   	ret    

0000060b <wait>:
SYSCALL(wait)
 60b:	b8 03 00 00 00       	mov    $0x3,%eax
 610:	cd 40                	int    $0x40
 612:	c3                   	ret    

00000613 <pipe>:
SYSCALL(pipe)
 613:	b8 04 00 00 00       	mov    $0x4,%eax
 618:	cd 40                	int    $0x40
 61a:	c3                   	ret    

0000061b <read>:
SYSCALL(read)
 61b:	b8 05 00 00 00       	mov    $0x5,%eax
 620:	cd 40                	int    $0x40
 622:	c3                   	ret    

00000623 <write>:
SYSCALL(write)
 623:	b8 10 00 00 00       	mov    $0x10,%eax
 628:	cd 40                	int    $0x40
 62a:	c3                   	ret    

0000062b <close>:
SYSCALL(close)
 62b:	b8 15 00 00 00       	mov    $0x15,%eax
 630:	cd 40                	int    $0x40
 632:	c3                   	ret    

00000633 <kill>:
SYSCALL(kill)
 633:	b8 06 00 00 00       	mov    $0x6,%eax
 638:	cd 40                	int    $0x40
 63a:	c3                   	ret    

0000063b <exec>:
SYSCALL(exec)
 63b:	b8 07 00 00 00       	mov    $0x7,%eax
 640:	cd 40                	int    $0x40
 642:	c3                   	ret    

00000643 <open>:
SYSCALL(open)
 643:	b8 0f 00 00 00       	mov    $0xf,%eax
 648:	cd 40                	int    $0x40
 64a:	c3                   	ret    

0000064b <mknod>:
SYSCALL(mknod)
 64b:	b8 11 00 00 00       	mov    $0x11,%eax
 650:	cd 40                	int    $0x40
 652:	c3                   	ret    

00000653 <unlink>:
SYSCALL(unlink)
 653:	b8 12 00 00 00       	mov    $0x12,%eax
 658:	cd 40                	int    $0x40
 65a:	c3                   	ret    

0000065b <fstat>:
SYSCALL(fstat)
 65b:	b8 08 00 00 00       	mov    $0x8,%eax
 660:	cd 40                	int    $0x40
 662:	c3                   	ret    

00000663 <link>:
SYSCALL(link)
 663:	b8 13 00 00 00       	mov    $0x13,%eax
 668:	cd 40                	int    $0x40
 66a:	c3                   	ret    

0000066b <mkdir>:
SYSCALL(mkdir)
 66b:	b8 14 00 00 00       	mov    $0x14,%eax
 670:	cd 40                	int    $0x40
 672:	c3                   	ret    

00000673 <chdir>:
SYSCALL(chdir)
 673:	b8 09 00 00 00       	mov    $0x9,%eax
 678:	cd 40                	int    $0x40
 67a:	c3                   	ret    

0000067b <dup>:
SYSCALL(dup)
 67b:	b8 0a 00 00 00       	mov    $0xa,%eax
 680:	cd 40                	int    $0x40
 682:	c3                   	ret    

00000683 <getpid>:
SYSCALL(getpid)
 683:	b8 0b 00 00 00       	mov    $0xb,%eax
 688:	cd 40                	int    $0x40
 68a:	c3                   	ret    

0000068b <sbrk>:
SYSCALL(sbrk)
 68b:	b8 0c 00 00 00       	mov    $0xc,%eax
 690:	cd 40                	int    $0x40
 692:	c3                   	ret    

00000693 <sleep>:
SYSCALL(sleep)
 693:	b8 0d 00 00 00       	mov    $0xd,%eax
 698:	cd 40                	int    $0x40
 69a:	c3                   	ret    

0000069b <uptime>:
SYSCALL(uptime)
 69b:	b8 0e 00 00 00       	mov    $0xe,%eax
 6a0:	cd 40                	int    $0x40
 6a2:	c3                   	ret    

000006a3 <mount>:
SYSCALL(mount)
 6a3:	b8 16 00 00 00       	mov    $0x16,%eax
 6a8:	cd 40                	int    $0x40
 6aa:	c3                   	ret    

000006ab <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6ab:	55                   	push   %ebp
 6ac:	89 e5                	mov    %esp,%ebp
 6ae:	83 ec 18             	sub    $0x18,%esp
 6b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b4:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6b7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6be:	00 
 6bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c6:	8b 45 08             	mov    0x8(%ebp),%eax
 6c9:	89 04 24             	mov    %eax,(%esp)
 6cc:	e8 52 ff ff ff       	call   623 <write>
}
 6d1:	c9                   	leave  
 6d2:	c3                   	ret    

000006d3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6d3:	55                   	push   %ebp
 6d4:	89 e5                	mov    %esp,%ebp
 6d6:	56                   	push   %esi
 6d7:	53                   	push   %ebx
 6d8:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6db:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6e2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6e6:	74 17                	je     6ff <printint+0x2c>
 6e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6ec:	79 11                	jns    6ff <printint+0x2c>
    neg = 1;
 6ee:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 6f8:	f7 d8                	neg    %eax
 6fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6fd:	eb 06                	jmp    705 <printint+0x32>
  } else {
    x = xx;
 6ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 705:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 70c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 70f:	8d 41 01             	lea    0x1(%ecx),%eax
 712:	89 45 f4             	mov    %eax,-0xc(%ebp)
 715:	8b 5d 10             	mov    0x10(%ebp),%ebx
 718:	8b 45 ec             	mov    -0x14(%ebp),%eax
 71b:	ba 00 00 00 00       	mov    $0x0,%edx
 720:	f7 f3                	div    %ebx
 722:	89 d0                	mov    %edx,%eax
 724:	0f b6 80 78 0e 00 00 	movzbl 0xe78(%eax),%eax
 72b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 72f:	8b 75 10             	mov    0x10(%ebp),%esi
 732:	8b 45 ec             	mov    -0x14(%ebp),%eax
 735:	ba 00 00 00 00       	mov    $0x0,%edx
 73a:	f7 f6                	div    %esi
 73c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 73f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 743:	75 c7                	jne    70c <printint+0x39>
  if(neg)
 745:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 749:	74 10                	je     75b <printint+0x88>
    buf[i++] = '-';
 74b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74e:	8d 50 01             	lea    0x1(%eax),%edx
 751:	89 55 f4             	mov    %edx,-0xc(%ebp)
 754:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 759:	eb 1f                	jmp    77a <printint+0xa7>
 75b:	eb 1d                	jmp    77a <printint+0xa7>
    putc(fd, buf[i]);
 75d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 760:	8b 45 f4             	mov    -0xc(%ebp),%eax
 763:	01 d0                	add    %edx,%eax
 765:	0f b6 00             	movzbl (%eax),%eax
 768:	0f be c0             	movsbl %al,%eax
 76b:	89 44 24 04          	mov    %eax,0x4(%esp)
 76f:	8b 45 08             	mov    0x8(%ebp),%eax
 772:	89 04 24             	mov    %eax,(%esp)
 775:	e8 31 ff ff ff       	call   6ab <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 77a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 77e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 782:	79 d9                	jns    75d <printint+0x8a>
    putc(fd, buf[i]);
}
 784:	83 c4 30             	add    $0x30,%esp
 787:	5b                   	pop    %ebx
 788:	5e                   	pop    %esi
 789:	5d                   	pop    %ebp
 78a:	c3                   	ret    

0000078b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 78b:	55                   	push   %ebp
 78c:	89 e5                	mov    %esp,%ebp
 78e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 791:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 798:	8d 45 0c             	lea    0xc(%ebp),%eax
 79b:	83 c0 04             	add    $0x4,%eax
 79e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7a8:	e9 7c 01 00 00       	jmp    929 <printf+0x19e>
    c = fmt[i] & 0xff;
 7ad:	8b 55 0c             	mov    0xc(%ebp),%edx
 7b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b3:	01 d0                	add    %edx,%eax
 7b5:	0f b6 00             	movzbl (%eax),%eax
 7b8:	0f be c0             	movsbl %al,%eax
 7bb:	25 ff 00 00 00       	and    $0xff,%eax
 7c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7c7:	75 2c                	jne    7f5 <printf+0x6a>
      if(c == '%'){
 7c9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7cd:	75 0c                	jne    7db <printf+0x50>
        state = '%';
 7cf:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7d6:	e9 4a 01 00 00       	jmp    925 <printf+0x19a>
      } else {
        putc(fd, c);
 7db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7de:	0f be c0             	movsbl %al,%eax
 7e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e5:	8b 45 08             	mov    0x8(%ebp),%eax
 7e8:	89 04 24             	mov    %eax,(%esp)
 7eb:	e8 bb fe ff ff       	call   6ab <putc>
 7f0:	e9 30 01 00 00       	jmp    925 <printf+0x19a>
      }
    } else if(state == '%'){
 7f5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7f9:	0f 85 26 01 00 00    	jne    925 <printf+0x19a>
      if(c == 'd'){
 7ff:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 803:	75 2d                	jne    832 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 805:	8b 45 e8             	mov    -0x18(%ebp),%eax
 808:	8b 00                	mov    (%eax),%eax
 80a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 811:	00 
 812:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 819:	00 
 81a:	89 44 24 04          	mov    %eax,0x4(%esp)
 81e:	8b 45 08             	mov    0x8(%ebp),%eax
 821:	89 04 24             	mov    %eax,(%esp)
 824:	e8 aa fe ff ff       	call   6d3 <printint>
        ap++;
 829:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 82d:	e9 ec 00 00 00       	jmp    91e <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 832:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 836:	74 06                	je     83e <printf+0xb3>
 838:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 83c:	75 2d                	jne    86b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 83e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 841:	8b 00                	mov    (%eax),%eax
 843:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 84a:	00 
 84b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 852:	00 
 853:	89 44 24 04          	mov    %eax,0x4(%esp)
 857:	8b 45 08             	mov    0x8(%ebp),%eax
 85a:	89 04 24             	mov    %eax,(%esp)
 85d:	e8 71 fe ff ff       	call   6d3 <printint>
        ap++;
 862:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 866:	e9 b3 00 00 00       	jmp    91e <printf+0x193>
      } else if(c == 's'){
 86b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 86f:	75 45                	jne    8b6 <printf+0x12b>
        s = (char*)*ap;
 871:	8b 45 e8             	mov    -0x18(%ebp),%eax
 874:	8b 00                	mov    (%eax),%eax
 876:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 879:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 87d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 881:	75 09                	jne    88c <printf+0x101>
          s = "(null)";
 883:	c7 45 f4 d6 0b 00 00 	movl   $0xbd6,-0xc(%ebp)
        while(*s != 0){
 88a:	eb 1e                	jmp    8aa <printf+0x11f>
 88c:	eb 1c                	jmp    8aa <printf+0x11f>
          putc(fd, *s);
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	0f b6 00             	movzbl (%eax),%eax
 894:	0f be c0             	movsbl %al,%eax
 897:	89 44 24 04          	mov    %eax,0x4(%esp)
 89b:	8b 45 08             	mov    0x8(%ebp),%eax
 89e:	89 04 24             	mov    %eax,(%esp)
 8a1:	e8 05 fe ff ff       	call   6ab <putc>
          s++;
 8a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 8aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ad:	0f b6 00             	movzbl (%eax),%eax
 8b0:	84 c0                	test   %al,%al
 8b2:	75 da                	jne    88e <printf+0x103>
 8b4:	eb 68                	jmp    91e <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8b6:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8ba:	75 1d                	jne    8d9 <printf+0x14e>
        putc(fd, *ap);
 8bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8bf:	8b 00                	mov    (%eax),%eax
 8c1:	0f be c0             	movsbl %al,%eax
 8c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 8c8:	8b 45 08             	mov    0x8(%ebp),%eax
 8cb:	89 04 24             	mov    %eax,(%esp)
 8ce:	e8 d8 fd ff ff       	call   6ab <putc>
        ap++;
 8d3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8d7:	eb 45                	jmp    91e <printf+0x193>
      } else if(c == '%'){
 8d9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8dd:	75 17                	jne    8f6 <printf+0x16b>
        putc(fd, c);
 8df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8e2:	0f be c0             	movsbl %al,%eax
 8e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 8e9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ec:	89 04 24             	mov    %eax,(%esp)
 8ef:	e8 b7 fd ff ff       	call   6ab <putc>
 8f4:	eb 28                	jmp    91e <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8f6:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8fd:	00 
 8fe:	8b 45 08             	mov    0x8(%ebp),%eax
 901:	89 04 24             	mov    %eax,(%esp)
 904:	e8 a2 fd ff ff       	call   6ab <putc>
        putc(fd, c);
 909:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 90c:	0f be c0             	movsbl %al,%eax
 90f:	89 44 24 04          	mov    %eax,0x4(%esp)
 913:	8b 45 08             	mov    0x8(%ebp),%eax
 916:	89 04 24             	mov    %eax,(%esp)
 919:	e8 8d fd ff ff       	call   6ab <putc>
      }
      state = 0;
 91e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 925:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 929:	8b 55 0c             	mov    0xc(%ebp),%edx
 92c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92f:	01 d0                	add    %edx,%eax
 931:	0f b6 00             	movzbl (%eax),%eax
 934:	84 c0                	test   %al,%al
 936:	0f 85 71 fe ff ff    	jne    7ad <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 93c:	c9                   	leave  
 93d:	c3                   	ret    

0000093e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 93e:	55                   	push   %ebp
 93f:	89 e5                	mov    %esp,%ebp
 941:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 944:	8b 45 08             	mov    0x8(%ebp),%eax
 947:	83 e8 08             	sub    $0x8,%eax
 94a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 94d:	a1 a4 0e 00 00       	mov    0xea4,%eax
 952:	89 45 fc             	mov    %eax,-0x4(%ebp)
 955:	eb 24                	jmp    97b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 957:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95a:	8b 00                	mov    (%eax),%eax
 95c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 95f:	77 12                	ja     973 <free+0x35>
 961:	8b 45 f8             	mov    -0x8(%ebp),%eax
 964:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 967:	77 24                	ja     98d <free+0x4f>
 969:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96c:	8b 00                	mov    (%eax),%eax
 96e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 971:	77 1a                	ja     98d <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 973:	8b 45 fc             	mov    -0x4(%ebp),%eax
 976:	8b 00                	mov    (%eax),%eax
 978:	89 45 fc             	mov    %eax,-0x4(%ebp)
 97b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 981:	76 d4                	jbe    957 <free+0x19>
 983:	8b 45 fc             	mov    -0x4(%ebp),%eax
 986:	8b 00                	mov    (%eax),%eax
 988:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 98b:	76 ca                	jbe    957 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 98d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 990:	8b 40 04             	mov    0x4(%eax),%eax
 993:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 99a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99d:	01 c2                	add    %eax,%edx
 99f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a2:	8b 00                	mov    (%eax),%eax
 9a4:	39 c2                	cmp    %eax,%edx
 9a6:	75 24                	jne    9cc <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ab:	8b 50 04             	mov    0x4(%eax),%edx
 9ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b1:	8b 00                	mov    (%eax),%eax
 9b3:	8b 40 04             	mov    0x4(%eax),%eax
 9b6:	01 c2                	add    %eax,%edx
 9b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bb:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c1:	8b 00                	mov    (%eax),%eax
 9c3:	8b 10                	mov    (%eax),%edx
 9c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c8:	89 10                	mov    %edx,(%eax)
 9ca:	eb 0a                	jmp    9d6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cf:	8b 10                	mov    (%eax),%edx
 9d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d9:	8b 40 04             	mov    0x4(%eax),%eax
 9dc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e6:	01 d0                	add    %edx,%eax
 9e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9eb:	75 20                	jne    a0d <free+0xcf>
    p->s.size += bp->s.size;
 9ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f0:	8b 50 04             	mov    0x4(%eax),%edx
 9f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f6:	8b 40 04             	mov    0x4(%eax),%eax
 9f9:	01 c2                	add    %eax,%edx
 9fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fe:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a01:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a04:	8b 10                	mov    (%eax),%edx
 a06:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a09:	89 10                	mov    %edx,(%eax)
 a0b:	eb 08                	jmp    a15 <free+0xd7>
  } else
    p->s.ptr = bp;
 a0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a10:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a13:	89 10                	mov    %edx,(%eax)
  freep = p;
 a15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a18:	a3 a4 0e 00 00       	mov    %eax,0xea4
}
 a1d:	c9                   	leave  
 a1e:	c3                   	ret    

00000a1f <morecore>:

static Header*
morecore(uint nu)
{
 a1f:	55                   	push   %ebp
 a20:	89 e5                	mov    %esp,%ebp
 a22:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a25:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a2c:	77 07                	ja     a35 <morecore+0x16>
    nu = 4096;
 a2e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a35:	8b 45 08             	mov    0x8(%ebp),%eax
 a38:	c1 e0 03             	shl    $0x3,%eax
 a3b:	89 04 24             	mov    %eax,(%esp)
 a3e:	e8 48 fc ff ff       	call   68b <sbrk>
 a43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a46:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a4a:	75 07                	jne    a53 <morecore+0x34>
    return 0;
 a4c:	b8 00 00 00 00       	mov    $0x0,%eax
 a51:	eb 22                	jmp    a75 <morecore+0x56>
  hp = (Header*)p;
 a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5c:	8b 55 08             	mov    0x8(%ebp),%edx
 a5f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a65:	83 c0 08             	add    $0x8,%eax
 a68:	89 04 24             	mov    %eax,(%esp)
 a6b:	e8 ce fe ff ff       	call   93e <free>
  return freep;
 a70:	a1 a4 0e 00 00       	mov    0xea4,%eax
}
 a75:	c9                   	leave  
 a76:	c3                   	ret    

00000a77 <malloc>:

void*
malloc(uint nbytes)
{
 a77:	55                   	push   %ebp
 a78:	89 e5                	mov    %esp,%ebp
 a7a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a7d:	8b 45 08             	mov    0x8(%ebp),%eax
 a80:	83 c0 07             	add    $0x7,%eax
 a83:	c1 e8 03             	shr    $0x3,%eax
 a86:	83 c0 01             	add    $0x1,%eax
 a89:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a8c:	a1 a4 0e 00 00       	mov    0xea4,%eax
 a91:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a94:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a98:	75 23                	jne    abd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a9a:	c7 45 f0 9c 0e 00 00 	movl   $0xe9c,-0x10(%ebp)
 aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa4:	a3 a4 0e 00 00       	mov    %eax,0xea4
 aa9:	a1 a4 0e 00 00       	mov    0xea4,%eax
 aae:	a3 9c 0e 00 00       	mov    %eax,0xe9c
    base.s.size = 0;
 ab3:	c7 05 a0 0e 00 00 00 	movl   $0x0,0xea0
 aba:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac0:	8b 00                	mov    (%eax),%eax
 ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac8:	8b 40 04             	mov    0x4(%eax),%eax
 acb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ace:	72 4d                	jb     b1d <malloc+0xa6>
      if(p->s.size == nunits)
 ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad3:	8b 40 04             	mov    0x4(%eax),%eax
 ad6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ad9:	75 0c                	jne    ae7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ade:	8b 10                	mov    (%eax),%edx
 ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae3:	89 10                	mov    %edx,(%eax)
 ae5:	eb 26                	jmp    b0d <malloc+0x96>
      else {
        p->s.size -= nunits;
 ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aea:	8b 40 04             	mov    0x4(%eax),%eax
 aed:	2b 45 ec             	sub    -0x14(%ebp),%eax
 af0:	89 c2                	mov    %eax,%edx
 af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afb:	8b 40 04             	mov    0x4(%eax),%eax
 afe:	c1 e0 03             	shl    $0x3,%eax
 b01:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b07:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b0a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b10:	a3 a4 0e 00 00       	mov    %eax,0xea4
      return (void*)(p + 1);
 b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b18:	83 c0 08             	add    $0x8,%eax
 b1b:	eb 38                	jmp    b55 <malloc+0xde>
    }
    if(p == freep)
 b1d:	a1 a4 0e 00 00       	mov    0xea4,%eax
 b22:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b25:	75 1b                	jne    b42 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 b27:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b2a:	89 04 24             	mov    %eax,(%esp)
 b2d:	e8 ed fe ff ff       	call   a1f <morecore>
 b32:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b39:	75 07                	jne    b42 <malloc+0xcb>
        return 0;
 b3b:	b8 00 00 00 00       	mov    $0x0,%eax
 b40:	eb 13                	jmp    b55 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b45:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4b:	8b 00                	mov    (%eax),%eax
 b4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b50:	e9 70 ff ff ff       	jmp    ac5 <malloc+0x4e>
}
 b55:	c9                   	leave  
 b56:	c3                   	ret    
