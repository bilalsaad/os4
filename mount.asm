
_mount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fcntl.h"
#define d2 printf(1, "%d %s \n", __LINE__, __func__)
#define DIRSZ 14
int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  //char buffer[DIRSZ];
  printf(1, "argv1 %s argv2 %s \n", argv[1], argv[2]);
   9:	8b 45 0c             	mov    0xc(%ebp),%eax
   c:	83 c0 08             	add    $0x8,%eax
   f:	8b 10                	mov    (%eax),%edx
  11:	8b 45 0c             	mov    0xc(%ebp),%eax
  14:	83 c0 04             	add    $0x4,%eax
  17:	8b 00                	mov    (%eax),%eax
  19:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  21:	c7 44 24 04 48 08 00 	movl   $0x848,0x4(%esp)
  28:	00 
  29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  30:	e8 47 04 00 00       	call   47c <printf>
  if (mount(argv[1], atoi(argv[2])) < 0)
  35:	8b 45 0c             	mov    0xc(%ebp),%eax
  38:	83 c0 08             	add    $0x8,%eax
  3b:	8b 00                	mov    (%eax),%eax
  3d:	89 04 24             	mov    %eax,(%esp)
  40:	e8 1d 02 00 00       	call   262 <atoi>
  45:	8b 55 0c             	mov    0xc(%ebp),%edx
  48:	83 c2 04             	add    $0x4,%edx
  4b:	8b 12                	mov    (%edx),%edx
  4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  51:	89 14 24             	mov    %edx,(%esp)
  54:	e8 3b 03 00 00       	call   394 <mount>
  59:	85 c0                	test   %eax,%eax
  5b:	79 16                	jns    73 <main+0x73>
    printf(1, "mount failed \n");
  5d:	c7 44 24 04 5c 08 00 	movl   $0x85c,0x4(%esp)
  64:	00 
  65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6c:	e8 0b 04 00 00       	call   47c <printf>
  71:	eb 14                	jmp    87 <main+0x87>
  else 
    printf(1, "mount succeeded \n");
  73:	c7 44 24 04 6b 08 00 	movl   $0x86b,0x4(%esp)
  7a:	00 
  7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  82:	e8 f5 03 00 00       	call   47c <printf>

  exit();
  87:	e8 68 02 00 00       	call   2f4 <exit>

0000008c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  8c:	55                   	push   %ebp
  8d:	89 e5                	mov    %esp,%ebp
  8f:	57                   	push   %edi
  90:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  94:	8b 55 10             	mov    0x10(%ebp),%edx
  97:	8b 45 0c             	mov    0xc(%ebp),%eax
  9a:	89 cb                	mov    %ecx,%ebx
  9c:	89 df                	mov    %ebx,%edi
  9e:	89 d1                	mov    %edx,%ecx
  a0:	fc                   	cld    
  a1:	f3 aa                	rep stos %al,%es:(%edi)
  a3:	89 ca                	mov    %ecx,%edx
  a5:	89 fb                	mov    %edi,%ebx
  a7:	89 5d 08             	mov    %ebx,0x8(%ebp)
  aa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  ad:	5b                   	pop    %ebx
  ae:	5f                   	pop    %edi
  af:	5d                   	pop    %ebp
  b0:	c3                   	ret    

000000b1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  b1:	55                   	push   %ebp
  b2:	89 e5                	mov    %esp,%ebp
  b4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  b7:	8b 45 08             	mov    0x8(%ebp),%eax
  ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  bd:	90                   	nop
  be:	8b 45 08             	mov    0x8(%ebp),%eax
  c1:	8d 50 01             	lea    0x1(%eax),%edx
  c4:	89 55 08             	mov    %edx,0x8(%ebp)
  c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  cd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  d0:	0f b6 12             	movzbl (%edx),%edx
  d3:	88 10                	mov    %dl,(%eax)
  d5:	0f b6 00             	movzbl (%eax),%eax
  d8:	84 c0                	test   %al,%al
  da:	75 e2                	jne    be <strcpy+0xd>
    ;
  return os;
  dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  df:	c9                   	leave  
  e0:	c3                   	ret    

000000e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e1:	55                   	push   %ebp
  e2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e4:	eb 08                	jmp    ee <strcmp+0xd>
    p++, q++;
  e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ea:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ee:	8b 45 08             	mov    0x8(%ebp),%eax
  f1:	0f b6 00             	movzbl (%eax),%eax
  f4:	84 c0                	test   %al,%al
  f6:	74 10                	je     108 <strcmp+0x27>
  f8:	8b 45 08             	mov    0x8(%ebp),%eax
  fb:	0f b6 10             	movzbl (%eax),%edx
  fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 101:	0f b6 00             	movzbl (%eax),%eax
 104:	38 c2                	cmp    %al,%dl
 106:	74 de                	je     e6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	0f b6 00             	movzbl (%eax),%eax
 10e:	0f b6 d0             	movzbl %al,%edx
 111:	8b 45 0c             	mov    0xc(%ebp),%eax
 114:	0f b6 00             	movzbl (%eax),%eax
 117:	0f b6 c0             	movzbl %al,%eax
 11a:	29 c2                	sub    %eax,%edx
 11c:	89 d0                	mov    %edx,%eax
}
 11e:	5d                   	pop    %ebp
 11f:	c3                   	ret    

00000120 <strlen>:

uint
strlen(char *s)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 126:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 12d:	eb 04                	jmp    133 <strlen+0x13>
 12f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 133:	8b 55 fc             	mov    -0x4(%ebp),%edx
 136:	8b 45 08             	mov    0x8(%ebp),%eax
 139:	01 d0                	add    %edx,%eax
 13b:	0f b6 00             	movzbl (%eax),%eax
 13e:	84 c0                	test   %al,%al
 140:	75 ed                	jne    12f <strlen+0xf>
    ;
  return n;
 142:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 145:	c9                   	leave  
 146:	c3                   	ret    

00000147 <memset>:

void*
memset(void *dst, int c, uint n)
{
 147:	55                   	push   %ebp
 148:	89 e5                	mov    %esp,%ebp
 14a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 14d:	8b 45 10             	mov    0x10(%ebp),%eax
 150:	89 44 24 08          	mov    %eax,0x8(%esp)
 154:	8b 45 0c             	mov    0xc(%ebp),%eax
 157:	89 44 24 04          	mov    %eax,0x4(%esp)
 15b:	8b 45 08             	mov    0x8(%ebp),%eax
 15e:	89 04 24             	mov    %eax,(%esp)
 161:	e8 26 ff ff ff       	call   8c <stosb>
  return dst;
 166:	8b 45 08             	mov    0x8(%ebp),%eax
}
 169:	c9                   	leave  
 16a:	c3                   	ret    

0000016b <strchr>:

char*
strchr(const char *s, char c)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	83 ec 04             	sub    $0x4,%esp
 171:	8b 45 0c             	mov    0xc(%ebp),%eax
 174:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 177:	eb 14                	jmp    18d <strchr+0x22>
    if(*s == c)
 179:	8b 45 08             	mov    0x8(%ebp),%eax
 17c:	0f b6 00             	movzbl (%eax),%eax
 17f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 182:	75 05                	jne    189 <strchr+0x1e>
      return (char*)s;
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	eb 13                	jmp    19c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 189:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
 190:	0f b6 00             	movzbl (%eax),%eax
 193:	84 c0                	test   %al,%al
 195:	75 e2                	jne    179 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 197:	b8 00 00 00 00       	mov    $0x0,%eax
}
 19c:	c9                   	leave  
 19d:	c3                   	ret    

0000019e <gets>:

char*
gets(char *buf, int max)
{
 19e:	55                   	push   %ebp
 19f:	89 e5                	mov    %esp,%ebp
 1a1:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1ab:	eb 4c                	jmp    1f9 <gets+0x5b>
    cc = read(0, &c, 1);
 1ad:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1b4:	00 
 1b5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1c3:	e8 44 01 00 00       	call   30c <read>
 1c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1cf:	7f 02                	jg     1d3 <gets+0x35>
      break;
 1d1:	eb 31                	jmp    204 <gets+0x66>
    buf[i++] = c;
 1d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d6:	8d 50 01             	lea    0x1(%eax),%edx
 1d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1dc:	89 c2                	mov    %eax,%edx
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	01 c2                	add    %eax,%edx
 1e3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1e9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ed:	3c 0a                	cmp    $0xa,%al
 1ef:	74 13                	je     204 <gets+0x66>
 1f1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f5:	3c 0d                	cmp    $0xd,%al
 1f7:	74 0b                	je     204 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fc:	83 c0 01             	add    $0x1,%eax
 1ff:	3b 45 0c             	cmp    0xc(%ebp),%eax
 202:	7c a9                	jl     1ad <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 204:	8b 55 f4             	mov    -0xc(%ebp),%edx
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	01 d0                	add    %edx,%eax
 20c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 212:	c9                   	leave  
 213:	c3                   	ret    

00000214 <stat>:

int
stat(char *n, struct stat *st)
{
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 221:	00 
 222:	8b 45 08             	mov    0x8(%ebp),%eax
 225:	89 04 24             	mov    %eax,(%esp)
 228:	e8 07 01 00 00       	call   334 <open>
 22d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 230:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 234:	79 07                	jns    23d <stat+0x29>
    return -1;
 236:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 23b:	eb 23                	jmp    260 <stat+0x4c>
  r = fstat(fd, st);
 23d:	8b 45 0c             	mov    0xc(%ebp),%eax
 240:	89 44 24 04          	mov    %eax,0x4(%esp)
 244:	8b 45 f4             	mov    -0xc(%ebp),%eax
 247:	89 04 24             	mov    %eax,(%esp)
 24a:	e8 fd 00 00 00       	call   34c <fstat>
 24f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 252:	8b 45 f4             	mov    -0xc(%ebp),%eax
 255:	89 04 24             	mov    %eax,(%esp)
 258:	e8 bf 00 00 00       	call   31c <close>
  return r;
 25d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 260:	c9                   	leave  
 261:	c3                   	ret    

00000262 <atoi>:

int
atoi(const char *s)
{
 262:	55                   	push   %ebp
 263:	89 e5                	mov    %esp,%ebp
 265:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 268:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26f:	eb 25                	jmp    296 <atoi+0x34>
    n = n*10 + *s++ - '0';
 271:	8b 55 fc             	mov    -0x4(%ebp),%edx
 274:	89 d0                	mov    %edx,%eax
 276:	c1 e0 02             	shl    $0x2,%eax
 279:	01 d0                	add    %edx,%eax
 27b:	01 c0                	add    %eax,%eax
 27d:	89 c1                	mov    %eax,%ecx
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	8d 50 01             	lea    0x1(%eax),%edx
 285:	89 55 08             	mov    %edx,0x8(%ebp)
 288:	0f b6 00             	movzbl (%eax),%eax
 28b:	0f be c0             	movsbl %al,%eax
 28e:	01 c8                	add    %ecx,%eax
 290:	83 e8 30             	sub    $0x30,%eax
 293:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 296:	8b 45 08             	mov    0x8(%ebp),%eax
 299:	0f b6 00             	movzbl (%eax),%eax
 29c:	3c 2f                	cmp    $0x2f,%al
 29e:	7e 0a                	jle    2aa <atoi+0x48>
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
 2a3:	0f b6 00             	movzbl (%eax),%eax
 2a6:	3c 39                	cmp    $0x39,%al
 2a8:	7e c7                	jle    271 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ad:	c9                   	leave  
 2ae:	c3                   	ret    

000002af <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2af:	55                   	push   %ebp
 2b0:	89 e5                	mov    %esp,%ebp
 2b2:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2bb:	8b 45 0c             	mov    0xc(%ebp),%eax
 2be:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c1:	eb 17                	jmp    2da <memmove+0x2b>
    *dst++ = *src++;
 2c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2c6:	8d 50 01             	lea    0x1(%eax),%edx
 2c9:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2cc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2cf:	8d 4a 01             	lea    0x1(%edx),%ecx
 2d2:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2d5:	0f b6 12             	movzbl (%edx),%edx
 2d8:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2da:	8b 45 10             	mov    0x10(%ebp),%eax
 2dd:	8d 50 ff             	lea    -0x1(%eax),%edx
 2e0:	89 55 10             	mov    %edx,0x10(%ebp)
 2e3:	85 c0                	test   %eax,%eax
 2e5:	7f dc                	jg     2c3 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ea:	c9                   	leave  
 2eb:	c3                   	ret    

000002ec <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2ec:	b8 01 00 00 00       	mov    $0x1,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <exit>:
SYSCALL(exit)
 2f4:	b8 02 00 00 00       	mov    $0x2,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <wait>:
SYSCALL(wait)
 2fc:	b8 03 00 00 00       	mov    $0x3,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <pipe>:
SYSCALL(pipe)
 304:	b8 04 00 00 00       	mov    $0x4,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <read>:
SYSCALL(read)
 30c:	b8 05 00 00 00       	mov    $0x5,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <write>:
SYSCALL(write)
 314:	b8 10 00 00 00       	mov    $0x10,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <close>:
SYSCALL(close)
 31c:	b8 15 00 00 00       	mov    $0x15,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <kill>:
SYSCALL(kill)
 324:	b8 06 00 00 00       	mov    $0x6,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <exec>:
SYSCALL(exec)
 32c:	b8 07 00 00 00       	mov    $0x7,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <open>:
SYSCALL(open)
 334:	b8 0f 00 00 00       	mov    $0xf,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <mknod>:
SYSCALL(mknod)
 33c:	b8 11 00 00 00       	mov    $0x11,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <unlink>:
SYSCALL(unlink)
 344:	b8 12 00 00 00       	mov    $0x12,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <fstat>:
SYSCALL(fstat)
 34c:	b8 08 00 00 00       	mov    $0x8,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <link>:
SYSCALL(link)
 354:	b8 13 00 00 00       	mov    $0x13,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <mkdir>:
SYSCALL(mkdir)
 35c:	b8 14 00 00 00       	mov    $0x14,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <chdir>:
SYSCALL(chdir)
 364:	b8 09 00 00 00       	mov    $0x9,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <dup>:
SYSCALL(dup)
 36c:	b8 0a 00 00 00       	mov    $0xa,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <getpid>:
SYSCALL(getpid)
 374:	b8 0b 00 00 00       	mov    $0xb,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <sbrk>:
SYSCALL(sbrk)
 37c:	b8 0c 00 00 00       	mov    $0xc,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <sleep>:
SYSCALL(sleep)
 384:	b8 0d 00 00 00       	mov    $0xd,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <uptime>:
SYSCALL(uptime)
 38c:	b8 0e 00 00 00       	mov    $0xe,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <mount>:
SYSCALL(mount)
 394:	b8 16 00 00 00       	mov    $0x16,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 39c:	55                   	push   %ebp
 39d:	89 e5                	mov    %esp,%ebp
 39f:	83 ec 18             	sub    $0x18,%esp
 3a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3a8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3af:	00 
 3b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 3b7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ba:	89 04 24             	mov    %eax,(%esp)
 3bd:	e8 52 ff ff ff       	call   314 <write>
}
 3c2:	c9                   	leave  
 3c3:	c3                   	ret    

000003c4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c4:	55                   	push   %ebp
 3c5:	89 e5                	mov    %esp,%ebp
 3c7:	56                   	push   %esi
 3c8:	53                   	push   %ebx
 3c9:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3d3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3d7:	74 17                	je     3f0 <printint+0x2c>
 3d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3dd:	79 11                	jns    3f0 <printint+0x2c>
    neg = 1;
 3df:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e9:	f7 d8                	neg    %eax
 3eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ee:	eb 06                	jmp    3f6 <printint+0x32>
  } else {
    x = xx;
 3f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3fd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 400:	8d 41 01             	lea    0x1(%ecx),%eax
 403:	89 45 f4             	mov    %eax,-0xc(%ebp)
 406:	8b 5d 10             	mov    0x10(%ebp),%ebx
 409:	8b 45 ec             	mov    -0x14(%ebp),%eax
 40c:	ba 00 00 00 00       	mov    $0x0,%edx
 411:	f7 f3                	div    %ebx
 413:	89 d0                	mov    %edx,%eax
 415:	0f b6 80 c8 0a 00 00 	movzbl 0xac8(%eax),%eax
 41c:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 420:	8b 75 10             	mov    0x10(%ebp),%esi
 423:	8b 45 ec             	mov    -0x14(%ebp),%eax
 426:	ba 00 00 00 00       	mov    $0x0,%edx
 42b:	f7 f6                	div    %esi
 42d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 430:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 434:	75 c7                	jne    3fd <printint+0x39>
  if(neg)
 436:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 43a:	74 10                	je     44c <printint+0x88>
    buf[i++] = '-';
 43c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43f:	8d 50 01             	lea    0x1(%eax),%edx
 442:	89 55 f4             	mov    %edx,-0xc(%ebp)
 445:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 44a:	eb 1f                	jmp    46b <printint+0xa7>
 44c:	eb 1d                	jmp    46b <printint+0xa7>
    putc(fd, buf[i]);
 44e:	8d 55 dc             	lea    -0x24(%ebp),%edx
 451:	8b 45 f4             	mov    -0xc(%ebp),%eax
 454:	01 d0                	add    %edx,%eax
 456:	0f b6 00             	movzbl (%eax),%eax
 459:	0f be c0             	movsbl %al,%eax
 45c:	89 44 24 04          	mov    %eax,0x4(%esp)
 460:	8b 45 08             	mov    0x8(%ebp),%eax
 463:	89 04 24             	mov    %eax,(%esp)
 466:	e8 31 ff ff ff       	call   39c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 46b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 46f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 473:	79 d9                	jns    44e <printint+0x8a>
    putc(fd, buf[i]);
}
 475:	83 c4 30             	add    $0x30,%esp
 478:	5b                   	pop    %ebx
 479:	5e                   	pop    %esi
 47a:	5d                   	pop    %ebp
 47b:	c3                   	ret    

0000047c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 482:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 489:	8d 45 0c             	lea    0xc(%ebp),%eax
 48c:	83 c0 04             	add    $0x4,%eax
 48f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 492:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 499:	e9 7c 01 00 00       	jmp    61a <printf+0x19e>
    c = fmt[i] & 0xff;
 49e:	8b 55 0c             	mov    0xc(%ebp),%edx
 4a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4a4:	01 d0                	add    %edx,%eax
 4a6:	0f b6 00             	movzbl (%eax),%eax
 4a9:	0f be c0             	movsbl %al,%eax
 4ac:	25 ff 00 00 00       	and    $0xff,%eax
 4b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4b8:	75 2c                	jne    4e6 <printf+0x6a>
      if(c == '%'){
 4ba:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4be:	75 0c                	jne    4cc <printf+0x50>
        state = '%';
 4c0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4c7:	e9 4a 01 00 00       	jmp    616 <printf+0x19a>
      } else {
        putc(fd, c);
 4cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4cf:	0f be c0             	movsbl %al,%eax
 4d2:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d6:	8b 45 08             	mov    0x8(%ebp),%eax
 4d9:	89 04 24             	mov    %eax,(%esp)
 4dc:	e8 bb fe ff ff       	call   39c <putc>
 4e1:	e9 30 01 00 00       	jmp    616 <printf+0x19a>
      }
    } else if(state == '%'){
 4e6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ea:	0f 85 26 01 00 00    	jne    616 <printf+0x19a>
      if(c == 'd'){
 4f0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4f4:	75 2d                	jne    523 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f9:	8b 00                	mov    (%eax),%eax
 4fb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 502:	00 
 503:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 50a:	00 
 50b:	89 44 24 04          	mov    %eax,0x4(%esp)
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
 512:	89 04 24             	mov    %eax,(%esp)
 515:	e8 aa fe ff ff       	call   3c4 <printint>
        ap++;
 51a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 51e:	e9 ec 00 00 00       	jmp    60f <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 523:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 527:	74 06                	je     52f <printf+0xb3>
 529:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 52d:	75 2d                	jne    55c <printf+0xe0>
        printint(fd, *ap, 16, 0);
 52f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 532:	8b 00                	mov    (%eax),%eax
 534:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 53b:	00 
 53c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 543:	00 
 544:	89 44 24 04          	mov    %eax,0x4(%esp)
 548:	8b 45 08             	mov    0x8(%ebp),%eax
 54b:	89 04 24             	mov    %eax,(%esp)
 54e:	e8 71 fe ff ff       	call   3c4 <printint>
        ap++;
 553:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 557:	e9 b3 00 00 00       	jmp    60f <printf+0x193>
      } else if(c == 's'){
 55c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 560:	75 45                	jne    5a7 <printf+0x12b>
        s = (char*)*ap;
 562:	8b 45 e8             	mov    -0x18(%ebp),%eax
 565:	8b 00                	mov    (%eax),%eax
 567:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 56a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 56e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 572:	75 09                	jne    57d <printf+0x101>
          s = "(null)";
 574:	c7 45 f4 7d 08 00 00 	movl   $0x87d,-0xc(%ebp)
        while(*s != 0){
 57b:	eb 1e                	jmp    59b <printf+0x11f>
 57d:	eb 1c                	jmp    59b <printf+0x11f>
          putc(fd, *s);
 57f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 582:	0f b6 00             	movzbl (%eax),%eax
 585:	0f be c0             	movsbl %al,%eax
 588:	89 44 24 04          	mov    %eax,0x4(%esp)
 58c:	8b 45 08             	mov    0x8(%ebp),%eax
 58f:	89 04 24             	mov    %eax,(%esp)
 592:	e8 05 fe ff ff       	call   39c <putc>
          s++;
 597:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 59b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59e:	0f b6 00             	movzbl (%eax),%eax
 5a1:	84 c0                	test   %al,%al
 5a3:	75 da                	jne    57f <printf+0x103>
 5a5:	eb 68                	jmp    60f <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5a7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5ab:	75 1d                	jne    5ca <printf+0x14e>
        putc(fd, *ap);
 5ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b0:	8b 00                	mov    (%eax),%eax
 5b2:	0f be c0             	movsbl %al,%eax
 5b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b9:	8b 45 08             	mov    0x8(%ebp),%eax
 5bc:	89 04 24             	mov    %eax,(%esp)
 5bf:	e8 d8 fd ff ff       	call   39c <putc>
        ap++;
 5c4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c8:	eb 45                	jmp    60f <printf+0x193>
      } else if(c == '%'){
 5ca:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5ce:	75 17                	jne    5e7 <printf+0x16b>
        putc(fd, c);
 5d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d3:	0f be c0             	movsbl %al,%eax
 5d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5da:	8b 45 08             	mov    0x8(%ebp),%eax
 5dd:	89 04 24             	mov    %eax,(%esp)
 5e0:	e8 b7 fd ff ff       	call   39c <putc>
 5e5:	eb 28                	jmp    60f <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5e7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5ee:	00 
 5ef:	8b 45 08             	mov    0x8(%ebp),%eax
 5f2:	89 04 24             	mov    %eax,(%esp)
 5f5:	e8 a2 fd ff ff       	call   39c <putc>
        putc(fd, c);
 5fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fd:	0f be c0             	movsbl %al,%eax
 600:	89 44 24 04          	mov    %eax,0x4(%esp)
 604:	8b 45 08             	mov    0x8(%ebp),%eax
 607:	89 04 24             	mov    %eax,(%esp)
 60a:	e8 8d fd ff ff       	call   39c <putc>
      }
      state = 0;
 60f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 616:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 61a:	8b 55 0c             	mov    0xc(%ebp),%edx
 61d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 620:	01 d0                	add    %edx,%eax
 622:	0f b6 00             	movzbl (%eax),%eax
 625:	84 c0                	test   %al,%al
 627:	0f 85 71 fe ff ff    	jne    49e <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 62d:	c9                   	leave  
 62e:	c3                   	ret    

0000062f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 62f:	55                   	push   %ebp
 630:	89 e5                	mov    %esp,%ebp
 632:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 635:	8b 45 08             	mov    0x8(%ebp),%eax
 638:	83 e8 08             	sub    $0x8,%eax
 63b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 63e:	a1 e4 0a 00 00       	mov    0xae4,%eax
 643:	89 45 fc             	mov    %eax,-0x4(%ebp)
 646:	eb 24                	jmp    66c <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 648:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64b:	8b 00                	mov    (%eax),%eax
 64d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 650:	77 12                	ja     664 <free+0x35>
 652:	8b 45 f8             	mov    -0x8(%ebp),%eax
 655:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 658:	77 24                	ja     67e <free+0x4f>
 65a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65d:	8b 00                	mov    (%eax),%eax
 65f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 662:	77 1a                	ja     67e <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 664:	8b 45 fc             	mov    -0x4(%ebp),%eax
 667:	8b 00                	mov    (%eax),%eax
 669:	89 45 fc             	mov    %eax,-0x4(%ebp)
 66c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 672:	76 d4                	jbe    648 <free+0x19>
 674:	8b 45 fc             	mov    -0x4(%ebp),%eax
 677:	8b 00                	mov    (%eax),%eax
 679:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 67c:	76 ca                	jbe    648 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 67e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 681:	8b 40 04             	mov    0x4(%eax),%eax
 684:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 68b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68e:	01 c2                	add    %eax,%edx
 690:	8b 45 fc             	mov    -0x4(%ebp),%eax
 693:	8b 00                	mov    (%eax),%eax
 695:	39 c2                	cmp    %eax,%edx
 697:	75 24                	jne    6bd <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 699:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69c:	8b 50 04             	mov    0x4(%eax),%edx
 69f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a2:	8b 00                	mov    (%eax),%eax
 6a4:	8b 40 04             	mov    0x4(%eax),%eax
 6a7:	01 c2                	add    %eax,%edx
 6a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ac:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b2:	8b 00                	mov    (%eax),%eax
 6b4:	8b 10                	mov    (%eax),%edx
 6b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b9:	89 10                	mov    %edx,(%eax)
 6bb:	eb 0a                	jmp    6c7 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8b 10                	mov    (%eax),%edx
 6c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c5:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ca:	8b 40 04             	mov    0x4(%eax),%eax
 6cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d7:	01 d0                	add    %edx,%eax
 6d9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6dc:	75 20                	jne    6fe <free+0xcf>
    p->s.size += bp->s.size;
 6de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e1:	8b 50 04             	mov    0x4(%eax),%edx
 6e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e7:	8b 40 04             	mov    0x4(%eax),%eax
 6ea:	01 c2                	add    %eax,%edx
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f5:	8b 10                	mov    (%eax),%edx
 6f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fa:	89 10                	mov    %edx,(%eax)
 6fc:	eb 08                	jmp    706 <free+0xd7>
  } else
    p->s.ptr = bp;
 6fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 701:	8b 55 f8             	mov    -0x8(%ebp),%edx
 704:	89 10                	mov    %edx,(%eax)
  freep = p;
 706:	8b 45 fc             	mov    -0x4(%ebp),%eax
 709:	a3 e4 0a 00 00       	mov    %eax,0xae4
}
 70e:	c9                   	leave  
 70f:	c3                   	ret    

00000710 <morecore>:

static Header*
morecore(uint nu)
{
 710:	55                   	push   %ebp
 711:	89 e5                	mov    %esp,%ebp
 713:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 716:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 71d:	77 07                	ja     726 <morecore+0x16>
    nu = 4096;
 71f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	c1 e0 03             	shl    $0x3,%eax
 72c:	89 04 24             	mov    %eax,(%esp)
 72f:	e8 48 fc ff ff       	call   37c <sbrk>
 734:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 737:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 73b:	75 07                	jne    744 <morecore+0x34>
    return 0;
 73d:	b8 00 00 00 00       	mov    $0x0,%eax
 742:	eb 22                	jmp    766 <morecore+0x56>
  hp = (Header*)p;
 744:	8b 45 f4             	mov    -0xc(%ebp),%eax
 747:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 74a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74d:	8b 55 08             	mov    0x8(%ebp),%edx
 750:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 753:	8b 45 f0             	mov    -0x10(%ebp),%eax
 756:	83 c0 08             	add    $0x8,%eax
 759:	89 04 24             	mov    %eax,(%esp)
 75c:	e8 ce fe ff ff       	call   62f <free>
  return freep;
 761:	a1 e4 0a 00 00       	mov    0xae4,%eax
}
 766:	c9                   	leave  
 767:	c3                   	ret    

00000768 <malloc>:

void*
malloc(uint nbytes)
{
 768:	55                   	push   %ebp
 769:	89 e5                	mov    %esp,%ebp
 76b:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 76e:	8b 45 08             	mov    0x8(%ebp),%eax
 771:	83 c0 07             	add    $0x7,%eax
 774:	c1 e8 03             	shr    $0x3,%eax
 777:	83 c0 01             	add    $0x1,%eax
 77a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 77d:	a1 e4 0a 00 00       	mov    0xae4,%eax
 782:	89 45 f0             	mov    %eax,-0x10(%ebp)
 785:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 789:	75 23                	jne    7ae <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 78b:	c7 45 f0 dc 0a 00 00 	movl   $0xadc,-0x10(%ebp)
 792:	8b 45 f0             	mov    -0x10(%ebp),%eax
 795:	a3 e4 0a 00 00       	mov    %eax,0xae4
 79a:	a1 e4 0a 00 00       	mov    0xae4,%eax
 79f:	a3 dc 0a 00 00       	mov    %eax,0xadc
    base.s.size = 0;
 7a4:	c7 05 e0 0a 00 00 00 	movl   $0x0,0xae0
 7ab:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b1:	8b 00                	mov    (%eax),%eax
 7b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b9:	8b 40 04             	mov    0x4(%eax),%eax
 7bc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7bf:	72 4d                	jb     80e <malloc+0xa6>
      if(p->s.size == nunits)
 7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c4:	8b 40 04             	mov    0x4(%eax),%eax
 7c7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7ca:	75 0c                	jne    7d8 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	8b 10                	mov    (%eax),%edx
 7d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d4:	89 10                	mov    %edx,(%eax)
 7d6:	eb 26                	jmp    7fe <malloc+0x96>
      else {
        p->s.size -= nunits;
 7d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7db:	8b 40 04             	mov    0x4(%eax),%eax
 7de:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7e1:	89 c2                	mov    %eax,%edx
 7e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e6:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	8b 40 04             	mov    0x4(%eax),%eax
 7ef:	c1 e0 03             	shl    $0x3,%eax
 7f2:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7fb:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 801:	a3 e4 0a 00 00       	mov    %eax,0xae4
      return (void*)(p + 1);
 806:	8b 45 f4             	mov    -0xc(%ebp),%eax
 809:	83 c0 08             	add    $0x8,%eax
 80c:	eb 38                	jmp    846 <malloc+0xde>
    }
    if(p == freep)
 80e:	a1 e4 0a 00 00       	mov    0xae4,%eax
 813:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 816:	75 1b                	jne    833 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 818:	8b 45 ec             	mov    -0x14(%ebp),%eax
 81b:	89 04 24             	mov    %eax,(%esp)
 81e:	e8 ed fe ff ff       	call   710 <morecore>
 823:	89 45 f4             	mov    %eax,-0xc(%ebp)
 826:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 82a:	75 07                	jne    833 <malloc+0xcb>
        return 0;
 82c:	b8 00 00 00 00       	mov    $0x0,%eax
 831:	eb 13                	jmp    846 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 833:	8b 45 f4             	mov    -0xc(%ebp),%eax
 836:	89 45 f0             	mov    %eax,-0x10(%ebp)
 839:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83c:	8b 00                	mov    (%eax),%eax
 83e:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 841:	e9 70 ff ff ff       	jmp    7b6 <malloc+0x4e>
}
 846:	c9                   	leave  
 847:	c3                   	ret    
