
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fcntl.h"
#define d2 printf(1, "%d %s \n", __LINE__, __func__)

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 20 02 00 00    	sub    $0x220,%esp
  int i;
  int fd = open("blal", O_CREATE | O_RDWR);
   c:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  13:	00 
  14:	c7 04 24 27 09 00 00 	movl   $0x927,(%esp)
  1b:	e8 f3 03 00 00       	call   413 <open>
  20:	89 84 24 18 02 00 00 	mov    %eax,0x218(%esp)
  int fd2 = open("blal2", O_CREATE | O_RDWR);
  27:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  2e:	00 
  2f:	c7 04 24 2c 09 00 00 	movl   $0x92c,(%esp)
  36:	e8 d8 03 00 00       	call   413 <open>
  3b:	89 84 24 14 02 00 00 	mov    %eax,0x214(%esp)
  d2;
  42:	c7 44 24 0c 66 09 00 	movl   $0x966,0xc(%esp)
  49:	00 
  4a:	c7 44 24 08 0d 00 00 	movl   $0xd,0x8(%esp)
  51:	00 
  52:	c7 44 24 04 32 09 00 	movl   $0x932,0x4(%esp)
  59:	00 
  5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  61:	e8 f5 04 00 00       	call   55b <printf>

  char data[512];
  memset(data, 'b', sizeof(data));
  66:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  6d:	00 
  6e:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  75:	00 
  76:	8d 44 24 14          	lea    0x14(%esp),%eax
  7a:	89 04 24             	mov    %eax,(%esp)
  7d:	e8 a4 01 00 00       	call   226 <memset>
  for(i = 0 ; i < 100; ++i) {
  82:	c7 84 24 1c 02 00 00 	movl   $0x0,0x21c(%esp)
  89:	00 00 00 00 
  8d:	e9 9c 00 00 00       	jmp    12e <main+0x12e>
    if(write(fd, data, sizeof(data)) != sizeof(data)) {
  92:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  99:	00 
  9a:	8d 44 24 14          	lea    0x14(%esp),%eax
  9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  a2:	8b 84 24 18 02 00 00 	mov    0x218(%esp),%eax
  a9:	89 04 24             	mov    %eax,(%esp)
  ac:	e8 42 03 00 00       	call   3f3 <write>
  b1:	3d 00 02 00 00       	cmp    $0x200,%eax
  b6:	74 24                	je     dc <main+0xdc>
      printf(1, "1 bad write iter %d \n", i);
  b8:	8b 84 24 1c 02 00 00 	mov    0x21c(%esp),%eax
  bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  c3:	c7 44 24 04 3a 09 00 	movl   $0x93a,0x4(%esp)
  ca:	00 
  cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d2:	e8 84 04 00 00       	call   55b <printf>
      exit();
  d7:	e8 f7 02 00 00       	call   3d3 <exit>
    }
    if(write(fd2, data, sizeof(data)) != sizeof(data)) {
  dc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  e3:	00 
  e4:	8d 44 24 14          	lea    0x14(%esp),%eax
  e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  ec:	8b 84 24 14 02 00 00 	mov    0x214(%esp),%eax
  f3:	89 04 24             	mov    %eax,(%esp)
  f6:	e8 f8 02 00 00       	call   3f3 <write>
  fb:	3d 00 02 00 00       	cmp    $0x200,%eax
 100:	74 24                	je     126 <main+0x126>
      printf(1, "2 bad write iter %d \n", i);
 102:	8b 84 24 1c 02 00 00 	mov    0x21c(%esp),%eax
 109:	89 44 24 08          	mov    %eax,0x8(%esp)
 10d:	c7 44 24 04 50 09 00 	movl   $0x950,0x4(%esp)
 114:	00 
 115:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 11c:	e8 3a 04 00 00       	call   55b <printf>
      exit();
 121:	e8 ad 02 00 00       	call   3d3 <exit>
  int fd2 = open("blal2", O_CREATE | O_RDWR);
  d2;

  char data[512];
  memset(data, 'b', sizeof(data));
  for(i = 0 ; i < 100; ++i) {
 126:	83 84 24 1c 02 00 00 	addl   $0x1,0x21c(%esp)
 12d:	01 
 12e:	83 bc 24 1c 02 00 00 	cmpl   $0x63,0x21c(%esp)
 135:	63 
 136:	0f 8e 56 ff ff ff    	jle    92 <main+0x92>
    if(write(fd2, data, sizeof(data)) != sizeof(data)) {
      printf(1, "2 bad write iter %d \n", i);
      exit();
    }
  }
  close(fd);
 13c:	8b 84 24 18 02 00 00 	mov    0x218(%esp),%eax
 143:	89 04 24             	mov    %eax,(%esp)
 146:	e8 b0 02 00 00       	call   3fb <close>
  close(fd2);
 14b:	8b 84 24 14 02 00 00 	mov    0x214(%esp),%eax
 152:	89 04 24             	mov    %eax,(%esp)
 155:	e8 a1 02 00 00       	call   3fb <close>
  unlink("blal");
 15a:	c7 04 24 27 09 00 00 	movl   $0x927,(%esp)
 161:	e8 bd 02 00 00       	call   423 <unlink>
  exit();
 166:	e8 68 02 00 00       	call   3d3 <exit>

0000016b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	57                   	push   %edi
 16f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 170:	8b 4d 08             	mov    0x8(%ebp),%ecx
 173:	8b 55 10             	mov    0x10(%ebp),%edx
 176:	8b 45 0c             	mov    0xc(%ebp),%eax
 179:	89 cb                	mov    %ecx,%ebx
 17b:	89 df                	mov    %ebx,%edi
 17d:	89 d1                	mov    %edx,%ecx
 17f:	fc                   	cld    
 180:	f3 aa                	rep stos %al,%es:(%edi)
 182:	89 ca                	mov    %ecx,%edx
 184:	89 fb                	mov    %edi,%ebx
 186:	89 5d 08             	mov    %ebx,0x8(%ebp)
 189:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 18c:	5b                   	pop    %ebx
 18d:	5f                   	pop    %edi
 18e:	5d                   	pop    %ebp
 18f:	c3                   	ret    

00000190 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 196:	8b 45 08             	mov    0x8(%ebp),%eax
 199:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 19c:	90                   	nop
 19d:	8b 45 08             	mov    0x8(%ebp),%eax
 1a0:	8d 50 01             	lea    0x1(%eax),%edx
 1a3:	89 55 08             	mov    %edx,0x8(%ebp)
 1a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 1a9:	8d 4a 01             	lea    0x1(%edx),%ecx
 1ac:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1af:	0f b6 12             	movzbl (%edx),%edx
 1b2:	88 10                	mov    %dl,(%eax)
 1b4:	0f b6 00             	movzbl (%eax),%eax
 1b7:	84 c0                	test   %al,%al
 1b9:	75 e2                	jne    19d <strcpy+0xd>
    ;
  return os;
 1bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1be:	c9                   	leave  
 1bf:	c3                   	ret    

000001c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1c3:	eb 08                	jmp    1cd <strcmp+0xd>
    p++, q++;
 1c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1c9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1cd:	8b 45 08             	mov    0x8(%ebp),%eax
 1d0:	0f b6 00             	movzbl (%eax),%eax
 1d3:	84 c0                	test   %al,%al
 1d5:	74 10                	je     1e7 <strcmp+0x27>
 1d7:	8b 45 08             	mov    0x8(%ebp),%eax
 1da:	0f b6 10             	movzbl (%eax),%edx
 1dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e0:	0f b6 00             	movzbl (%eax),%eax
 1e3:	38 c2                	cmp    %al,%dl
 1e5:	74 de                	je     1c5 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ea:	0f b6 00             	movzbl (%eax),%eax
 1ed:	0f b6 d0             	movzbl %al,%edx
 1f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f3:	0f b6 00             	movzbl (%eax),%eax
 1f6:	0f b6 c0             	movzbl %al,%eax
 1f9:	29 c2                	sub    %eax,%edx
 1fb:	89 d0                	mov    %edx,%eax
}
 1fd:	5d                   	pop    %ebp
 1fe:	c3                   	ret    

000001ff <strlen>:

uint
strlen(char *s)
{
 1ff:	55                   	push   %ebp
 200:	89 e5                	mov    %esp,%ebp
 202:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 205:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 20c:	eb 04                	jmp    212 <strlen+0x13>
 20e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 212:	8b 55 fc             	mov    -0x4(%ebp),%edx
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	01 d0                	add    %edx,%eax
 21a:	0f b6 00             	movzbl (%eax),%eax
 21d:	84 c0                	test   %al,%al
 21f:	75 ed                	jne    20e <strlen+0xf>
    ;
  return n;
 221:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 224:	c9                   	leave  
 225:	c3                   	ret    

00000226 <memset>:

void*
memset(void *dst, int c, uint n)
{
 226:	55                   	push   %ebp
 227:	89 e5                	mov    %esp,%ebp
 229:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 22c:	8b 45 10             	mov    0x10(%ebp),%eax
 22f:	89 44 24 08          	mov    %eax,0x8(%esp)
 233:	8b 45 0c             	mov    0xc(%ebp),%eax
 236:	89 44 24 04          	mov    %eax,0x4(%esp)
 23a:	8b 45 08             	mov    0x8(%ebp),%eax
 23d:	89 04 24             	mov    %eax,(%esp)
 240:	e8 26 ff ff ff       	call   16b <stosb>
  return dst;
 245:	8b 45 08             	mov    0x8(%ebp),%eax
}
 248:	c9                   	leave  
 249:	c3                   	ret    

0000024a <strchr>:

char*
strchr(const char *s, char c)
{
 24a:	55                   	push   %ebp
 24b:	89 e5                	mov    %esp,%ebp
 24d:	83 ec 04             	sub    $0x4,%esp
 250:	8b 45 0c             	mov    0xc(%ebp),%eax
 253:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 256:	eb 14                	jmp    26c <strchr+0x22>
    if(*s == c)
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	0f b6 00             	movzbl (%eax),%eax
 25e:	3a 45 fc             	cmp    -0x4(%ebp),%al
 261:	75 05                	jne    268 <strchr+0x1e>
      return (char*)s;
 263:	8b 45 08             	mov    0x8(%ebp),%eax
 266:	eb 13                	jmp    27b <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 268:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	0f b6 00             	movzbl (%eax),%eax
 272:	84 c0                	test   %al,%al
 274:	75 e2                	jne    258 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 276:	b8 00 00 00 00       	mov    $0x0,%eax
}
 27b:	c9                   	leave  
 27c:	c3                   	ret    

0000027d <gets>:

char*
gets(char *buf, int max)
{
 27d:	55                   	push   %ebp
 27e:	89 e5                	mov    %esp,%ebp
 280:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 283:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 28a:	eb 4c                	jmp    2d8 <gets+0x5b>
    cc = read(0, &c, 1);
 28c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 293:	00 
 294:	8d 45 ef             	lea    -0x11(%ebp),%eax
 297:	89 44 24 04          	mov    %eax,0x4(%esp)
 29b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2a2:	e8 44 01 00 00       	call   3eb <read>
 2a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2ae:	7f 02                	jg     2b2 <gets+0x35>
      break;
 2b0:	eb 31                	jmp    2e3 <gets+0x66>
    buf[i++] = c;
 2b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b5:	8d 50 01             	lea    0x1(%eax),%edx
 2b8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2bb:	89 c2                	mov    %eax,%edx
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	01 c2                	add    %eax,%edx
 2c2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2c6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2c8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2cc:	3c 0a                	cmp    $0xa,%al
 2ce:	74 13                	je     2e3 <gets+0x66>
 2d0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2d4:	3c 0d                	cmp    $0xd,%al
 2d6:	74 0b                	je     2e3 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2db:	83 c0 01             	add    $0x1,%eax
 2de:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2e1:	7c a9                	jl     28c <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2e6:	8b 45 08             	mov    0x8(%ebp),%eax
 2e9:	01 d0                	add    %edx,%eax
 2eb:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2f1:	c9                   	leave  
 2f2:	c3                   	ret    

000002f3 <stat>:

int
stat(char *n, struct stat *st)
{
 2f3:	55                   	push   %ebp
 2f4:	89 e5                	mov    %esp,%ebp
 2f6:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 300:	00 
 301:	8b 45 08             	mov    0x8(%ebp),%eax
 304:	89 04 24             	mov    %eax,(%esp)
 307:	e8 07 01 00 00       	call   413 <open>
 30c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 30f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 313:	79 07                	jns    31c <stat+0x29>
    return -1;
 315:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 31a:	eb 23                	jmp    33f <stat+0x4c>
  r = fstat(fd, st);
 31c:	8b 45 0c             	mov    0xc(%ebp),%eax
 31f:	89 44 24 04          	mov    %eax,0x4(%esp)
 323:	8b 45 f4             	mov    -0xc(%ebp),%eax
 326:	89 04 24             	mov    %eax,(%esp)
 329:	e8 fd 00 00 00       	call   42b <fstat>
 32e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 331:	8b 45 f4             	mov    -0xc(%ebp),%eax
 334:	89 04 24             	mov    %eax,(%esp)
 337:	e8 bf 00 00 00       	call   3fb <close>
  return r;
 33c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 33f:	c9                   	leave  
 340:	c3                   	ret    

00000341 <atoi>:

int
atoi(const char *s)
{
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
 344:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 347:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 34e:	eb 25                	jmp    375 <atoi+0x34>
    n = n*10 + *s++ - '0';
 350:	8b 55 fc             	mov    -0x4(%ebp),%edx
 353:	89 d0                	mov    %edx,%eax
 355:	c1 e0 02             	shl    $0x2,%eax
 358:	01 d0                	add    %edx,%eax
 35a:	01 c0                	add    %eax,%eax
 35c:	89 c1                	mov    %eax,%ecx
 35e:	8b 45 08             	mov    0x8(%ebp),%eax
 361:	8d 50 01             	lea    0x1(%eax),%edx
 364:	89 55 08             	mov    %edx,0x8(%ebp)
 367:	0f b6 00             	movzbl (%eax),%eax
 36a:	0f be c0             	movsbl %al,%eax
 36d:	01 c8                	add    %ecx,%eax
 36f:	83 e8 30             	sub    $0x30,%eax
 372:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	0f b6 00             	movzbl (%eax),%eax
 37b:	3c 2f                	cmp    $0x2f,%al
 37d:	7e 0a                	jle    389 <atoi+0x48>
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	0f b6 00             	movzbl (%eax),%eax
 385:	3c 39                	cmp    $0x39,%al
 387:	7e c7                	jle    350 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 389:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 38c:	c9                   	leave  
 38d:	c3                   	ret    

0000038e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 38e:	55                   	push   %ebp
 38f:	89 e5                	mov    %esp,%ebp
 391:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 394:	8b 45 08             	mov    0x8(%ebp),%eax
 397:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 39a:	8b 45 0c             	mov    0xc(%ebp),%eax
 39d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3a0:	eb 17                	jmp    3b9 <memmove+0x2b>
    *dst++ = *src++;
 3a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3a5:	8d 50 01             	lea    0x1(%eax),%edx
 3a8:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3ab:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3ae:	8d 4a 01             	lea    0x1(%edx),%ecx
 3b1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3b4:	0f b6 12             	movzbl (%edx),%edx
 3b7:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3b9:	8b 45 10             	mov    0x10(%ebp),%eax
 3bc:	8d 50 ff             	lea    -0x1(%eax),%edx
 3bf:	89 55 10             	mov    %edx,0x10(%ebp)
 3c2:	85 c0                	test   %eax,%eax
 3c4:	7f dc                	jg     3a2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3c6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c9:	c9                   	leave  
 3ca:	c3                   	ret    

000003cb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3cb:	b8 01 00 00 00       	mov    $0x1,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	ret    

000003d3 <exit>:
SYSCALL(exit)
 3d3:	b8 02 00 00 00       	mov    $0x2,%eax
 3d8:	cd 40                	int    $0x40
 3da:	c3                   	ret    

000003db <wait>:
SYSCALL(wait)
 3db:	b8 03 00 00 00       	mov    $0x3,%eax
 3e0:	cd 40                	int    $0x40
 3e2:	c3                   	ret    

000003e3 <pipe>:
SYSCALL(pipe)
 3e3:	b8 04 00 00 00       	mov    $0x4,%eax
 3e8:	cd 40                	int    $0x40
 3ea:	c3                   	ret    

000003eb <read>:
SYSCALL(read)
 3eb:	b8 05 00 00 00       	mov    $0x5,%eax
 3f0:	cd 40                	int    $0x40
 3f2:	c3                   	ret    

000003f3 <write>:
SYSCALL(write)
 3f3:	b8 10 00 00 00       	mov    $0x10,%eax
 3f8:	cd 40                	int    $0x40
 3fa:	c3                   	ret    

000003fb <close>:
SYSCALL(close)
 3fb:	b8 15 00 00 00       	mov    $0x15,%eax
 400:	cd 40                	int    $0x40
 402:	c3                   	ret    

00000403 <kill>:
SYSCALL(kill)
 403:	b8 06 00 00 00       	mov    $0x6,%eax
 408:	cd 40                	int    $0x40
 40a:	c3                   	ret    

0000040b <exec>:
SYSCALL(exec)
 40b:	b8 07 00 00 00       	mov    $0x7,%eax
 410:	cd 40                	int    $0x40
 412:	c3                   	ret    

00000413 <open>:
SYSCALL(open)
 413:	b8 0f 00 00 00       	mov    $0xf,%eax
 418:	cd 40                	int    $0x40
 41a:	c3                   	ret    

0000041b <mknod>:
SYSCALL(mknod)
 41b:	b8 11 00 00 00       	mov    $0x11,%eax
 420:	cd 40                	int    $0x40
 422:	c3                   	ret    

00000423 <unlink>:
SYSCALL(unlink)
 423:	b8 12 00 00 00       	mov    $0x12,%eax
 428:	cd 40                	int    $0x40
 42a:	c3                   	ret    

0000042b <fstat>:
SYSCALL(fstat)
 42b:	b8 08 00 00 00       	mov    $0x8,%eax
 430:	cd 40                	int    $0x40
 432:	c3                   	ret    

00000433 <link>:
SYSCALL(link)
 433:	b8 13 00 00 00       	mov    $0x13,%eax
 438:	cd 40                	int    $0x40
 43a:	c3                   	ret    

0000043b <mkdir>:
SYSCALL(mkdir)
 43b:	b8 14 00 00 00       	mov    $0x14,%eax
 440:	cd 40                	int    $0x40
 442:	c3                   	ret    

00000443 <chdir>:
SYSCALL(chdir)
 443:	b8 09 00 00 00       	mov    $0x9,%eax
 448:	cd 40                	int    $0x40
 44a:	c3                   	ret    

0000044b <dup>:
SYSCALL(dup)
 44b:	b8 0a 00 00 00       	mov    $0xa,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	ret    

00000453 <getpid>:
SYSCALL(getpid)
 453:	b8 0b 00 00 00       	mov    $0xb,%eax
 458:	cd 40                	int    $0x40
 45a:	c3                   	ret    

0000045b <sbrk>:
SYSCALL(sbrk)
 45b:	b8 0c 00 00 00       	mov    $0xc,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	ret    

00000463 <sleep>:
SYSCALL(sleep)
 463:	b8 0d 00 00 00       	mov    $0xd,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret    

0000046b <uptime>:
SYSCALL(uptime)
 46b:	b8 0e 00 00 00       	mov    $0xe,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret    

00000473 <mount>:
SYSCALL(mount)
 473:	b8 16 00 00 00       	mov    $0x16,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret    

0000047b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 47b:	55                   	push   %ebp
 47c:	89 e5                	mov    %esp,%ebp
 47e:	83 ec 18             	sub    $0x18,%esp
 481:	8b 45 0c             	mov    0xc(%ebp),%eax
 484:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 487:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 48e:	00 
 48f:	8d 45 f4             	lea    -0xc(%ebp),%eax
 492:	89 44 24 04          	mov    %eax,0x4(%esp)
 496:	8b 45 08             	mov    0x8(%ebp),%eax
 499:	89 04 24             	mov    %eax,(%esp)
 49c:	e8 52 ff ff ff       	call   3f3 <write>
}
 4a1:	c9                   	leave  
 4a2:	c3                   	ret    

000004a3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a3:	55                   	push   %ebp
 4a4:	89 e5                	mov    %esp,%ebp
 4a6:	56                   	push   %esi
 4a7:	53                   	push   %ebx
 4a8:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4b2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4b6:	74 17                	je     4cf <printint+0x2c>
 4b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4bc:	79 11                	jns    4cf <printint+0x2c>
    neg = 1;
 4be:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c8:	f7 d8                	neg    %eax
 4ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4cd:	eb 06                	jmp    4d5 <printint+0x32>
  } else {
    x = xx;
 4cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4dc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4df:	8d 41 01             	lea    0x1(%ecx),%eax
 4e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4eb:	ba 00 00 00 00       	mov    $0x0,%edx
 4f0:	f7 f3                	div    %ebx
 4f2:	89 d0                	mov    %edx,%eax
 4f4:	0f b6 80 b8 0b 00 00 	movzbl 0xbb8(%eax),%eax
 4fb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4ff:	8b 75 10             	mov    0x10(%ebp),%esi
 502:	8b 45 ec             	mov    -0x14(%ebp),%eax
 505:	ba 00 00 00 00       	mov    $0x0,%edx
 50a:	f7 f6                	div    %esi
 50c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 50f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 513:	75 c7                	jne    4dc <printint+0x39>
  if(neg)
 515:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 519:	74 10                	je     52b <printint+0x88>
    buf[i++] = '-';
 51b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51e:	8d 50 01             	lea    0x1(%eax),%edx
 521:	89 55 f4             	mov    %edx,-0xc(%ebp)
 524:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 529:	eb 1f                	jmp    54a <printint+0xa7>
 52b:	eb 1d                	jmp    54a <printint+0xa7>
    putc(fd, buf[i]);
 52d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 530:	8b 45 f4             	mov    -0xc(%ebp),%eax
 533:	01 d0                	add    %edx,%eax
 535:	0f b6 00             	movzbl (%eax),%eax
 538:	0f be c0             	movsbl %al,%eax
 53b:	89 44 24 04          	mov    %eax,0x4(%esp)
 53f:	8b 45 08             	mov    0x8(%ebp),%eax
 542:	89 04 24             	mov    %eax,(%esp)
 545:	e8 31 ff ff ff       	call   47b <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 54a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 54e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 552:	79 d9                	jns    52d <printint+0x8a>
    putc(fd, buf[i]);
}
 554:	83 c4 30             	add    $0x30,%esp
 557:	5b                   	pop    %ebx
 558:	5e                   	pop    %esi
 559:	5d                   	pop    %ebp
 55a:	c3                   	ret    

0000055b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 55b:	55                   	push   %ebp
 55c:	89 e5                	mov    %esp,%ebp
 55e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 561:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 568:	8d 45 0c             	lea    0xc(%ebp),%eax
 56b:	83 c0 04             	add    $0x4,%eax
 56e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 571:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 578:	e9 7c 01 00 00       	jmp    6f9 <printf+0x19e>
    c = fmt[i] & 0xff;
 57d:	8b 55 0c             	mov    0xc(%ebp),%edx
 580:	8b 45 f0             	mov    -0x10(%ebp),%eax
 583:	01 d0                	add    %edx,%eax
 585:	0f b6 00             	movzbl (%eax),%eax
 588:	0f be c0             	movsbl %al,%eax
 58b:	25 ff 00 00 00       	and    $0xff,%eax
 590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 593:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 597:	75 2c                	jne    5c5 <printf+0x6a>
      if(c == '%'){
 599:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 59d:	75 0c                	jne    5ab <printf+0x50>
        state = '%';
 59f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5a6:	e9 4a 01 00 00       	jmp    6f5 <printf+0x19a>
      } else {
        putc(fd, c);
 5ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ae:	0f be c0             	movsbl %al,%eax
 5b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b5:	8b 45 08             	mov    0x8(%ebp),%eax
 5b8:	89 04 24             	mov    %eax,(%esp)
 5bb:	e8 bb fe ff ff       	call   47b <putc>
 5c0:	e9 30 01 00 00       	jmp    6f5 <printf+0x19a>
      }
    } else if(state == '%'){
 5c5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5c9:	0f 85 26 01 00 00    	jne    6f5 <printf+0x19a>
      if(c == 'd'){
 5cf:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5d3:	75 2d                	jne    602 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d8:	8b 00                	mov    (%eax),%eax
 5da:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5e1:	00 
 5e2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5e9:	00 
 5ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ee:	8b 45 08             	mov    0x8(%ebp),%eax
 5f1:	89 04 24             	mov    %eax,(%esp)
 5f4:	e8 aa fe ff ff       	call   4a3 <printint>
        ap++;
 5f9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5fd:	e9 ec 00 00 00       	jmp    6ee <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 602:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 606:	74 06                	je     60e <printf+0xb3>
 608:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 60c:	75 2d                	jne    63b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 60e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 611:	8b 00                	mov    (%eax),%eax
 613:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 61a:	00 
 61b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 622:	00 
 623:	89 44 24 04          	mov    %eax,0x4(%esp)
 627:	8b 45 08             	mov    0x8(%ebp),%eax
 62a:	89 04 24             	mov    %eax,(%esp)
 62d:	e8 71 fe ff ff       	call   4a3 <printint>
        ap++;
 632:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 636:	e9 b3 00 00 00       	jmp    6ee <printf+0x193>
      } else if(c == 's'){
 63b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 63f:	75 45                	jne    686 <printf+0x12b>
        s = (char*)*ap;
 641:	8b 45 e8             	mov    -0x18(%ebp),%eax
 644:	8b 00                	mov    (%eax),%eax
 646:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 649:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 64d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 651:	75 09                	jne    65c <printf+0x101>
          s = "(null)";
 653:	c7 45 f4 6b 09 00 00 	movl   $0x96b,-0xc(%ebp)
        while(*s != 0){
 65a:	eb 1e                	jmp    67a <printf+0x11f>
 65c:	eb 1c                	jmp    67a <printf+0x11f>
          putc(fd, *s);
 65e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 661:	0f b6 00             	movzbl (%eax),%eax
 664:	0f be c0             	movsbl %al,%eax
 667:	89 44 24 04          	mov    %eax,0x4(%esp)
 66b:	8b 45 08             	mov    0x8(%ebp),%eax
 66e:	89 04 24             	mov    %eax,(%esp)
 671:	e8 05 fe ff ff       	call   47b <putc>
          s++;
 676:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 67a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67d:	0f b6 00             	movzbl (%eax),%eax
 680:	84 c0                	test   %al,%al
 682:	75 da                	jne    65e <printf+0x103>
 684:	eb 68                	jmp    6ee <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 686:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 68a:	75 1d                	jne    6a9 <printf+0x14e>
        putc(fd, *ap);
 68c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68f:	8b 00                	mov    (%eax),%eax
 691:	0f be c0             	movsbl %al,%eax
 694:	89 44 24 04          	mov    %eax,0x4(%esp)
 698:	8b 45 08             	mov    0x8(%ebp),%eax
 69b:	89 04 24             	mov    %eax,(%esp)
 69e:	e8 d8 fd ff ff       	call   47b <putc>
        ap++;
 6a3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a7:	eb 45                	jmp    6ee <printf+0x193>
      } else if(c == '%'){
 6a9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6ad:	75 17                	jne    6c6 <printf+0x16b>
        putc(fd, c);
 6af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b2:	0f be c0             	movsbl %al,%eax
 6b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b9:	8b 45 08             	mov    0x8(%ebp),%eax
 6bc:	89 04 24             	mov    %eax,(%esp)
 6bf:	e8 b7 fd ff ff       	call   47b <putc>
 6c4:	eb 28                	jmp    6ee <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6c6:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6cd:	00 
 6ce:	8b 45 08             	mov    0x8(%ebp),%eax
 6d1:	89 04 24             	mov    %eax,(%esp)
 6d4:	e8 a2 fd ff ff       	call   47b <putc>
        putc(fd, c);
 6d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6dc:	0f be c0             	movsbl %al,%eax
 6df:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e3:	8b 45 08             	mov    0x8(%ebp),%eax
 6e6:	89 04 24             	mov    %eax,(%esp)
 6e9:	e8 8d fd ff ff       	call   47b <putc>
      }
      state = 0;
 6ee:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6f5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6f9:	8b 55 0c             	mov    0xc(%ebp),%edx
 6fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ff:	01 d0                	add    %edx,%eax
 701:	0f b6 00             	movzbl (%eax),%eax
 704:	84 c0                	test   %al,%al
 706:	0f 85 71 fe ff ff    	jne    57d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 70c:	c9                   	leave  
 70d:	c3                   	ret    

0000070e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 70e:	55                   	push   %ebp
 70f:	89 e5                	mov    %esp,%ebp
 711:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 714:	8b 45 08             	mov    0x8(%ebp),%eax
 717:	83 e8 08             	sub    $0x8,%eax
 71a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71d:	a1 d4 0b 00 00       	mov    0xbd4,%eax
 722:	89 45 fc             	mov    %eax,-0x4(%ebp)
 725:	eb 24                	jmp    74b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 727:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72a:	8b 00                	mov    (%eax),%eax
 72c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72f:	77 12                	ja     743 <free+0x35>
 731:	8b 45 f8             	mov    -0x8(%ebp),%eax
 734:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 737:	77 24                	ja     75d <free+0x4f>
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 741:	77 1a                	ja     75d <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 743:	8b 45 fc             	mov    -0x4(%ebp),%eax
 746:	8b 00                	mov    (%eax),%eax
 748:	89 45 fc             	mov    %eax,-0x4(%ebp)
 74b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 751:	76 d4                	jbe    727 <free+0x19>
 753:	8b 45 fc             	mov    -0x4(%ebp),%eax
 756:	8b 00                	mov    (%eax),%eax
 758:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 75b:	76 ca                	jbe    727 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 75d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 760:	8b 40 04             	mov    0x4(%eax),%eax
 763:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 76a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76d:	01 c2                	add    %eax,%edx
 76f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 772:	8b 00                	mov    (%eax),%eax
 774:	39 c2                	cmp    %eax,%edx
 776:	75 24                	jne    79c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 778:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77b:	8b 50 04             	mov    0x4(%eax),%edx
 77e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 781:	8b 00                	mov    (%eax),%eax
 783:	8b 40 04             	mov    0x4(%eax),%eax
 786:	01 c2                	add    %eax,%edx
 788:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 78e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 791:	8b 00                	mov    (%eax),%eax
 793:	8b 10                	mov    (%eax),%edx
 795:	8b 45 f8             	mov    -0x8(%ebp),%eax
 798:	89 10                	mov    %edx,(%eax)
 79a:	eb 0a                	jmp    7a6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 79c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79f:	8b 10                	mov    (%eax),%edx
 7a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a9:	8b 40 04             	mov    0x4(%eax),%eax
 7ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b6:	01 d0                	add    %edx,%eax
 7b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7bb:	75 20                	jne    7dd <free+0xcf>
    p->s.size += bp->s.size;
 7bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c0:	8b 50 04             	mov    0x4(%eax),%edx
 7c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c6:	8b 40 04             	mov    0x4(%eax),%eax
 7c9:	01 c2                	add    %eax,%edx
 7cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ce:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d4:	8b 10                	mov    (%eax),%edx
 7d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d9:	89 10                	mov    %edx,(%eax)
 7db:	eb 08                	jmp    7e5 <free+0xd7>
  } else
    p->s.ptr = bp;
 7dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7e3:	89 10                	mov    %edx,(%eax)
  freep = p;
 7e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e8:	a3 d4 0b 00 00       	mov    %eax,0xbd4
}
 7ed:	c9                   	leave  
 7ee:	c3                   	ret    

000007ef <morecore>:

static Header*
morecore(uint nu)
{
 7ef:	55                   	push   %ebp
 7f0:	89 e5                	mov    %esp,%ebp
 7f2:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7f5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7fc:	77 07                	ja     805 <morecore+0x16>
    nu = 4096;
 7fe:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 805:	8b 45 08             	mov    0x8(%ebp),%eax
 808:	c1 e0 03             	shl    $0x3,%eax
 80b:	89 04 24             	mov    %eax,(%esp)
 80e:	e8 48 fc ff ff       	call   45b <sbrk>
 813:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 816:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 81a:	75 07                	jne    823 <morecore+0x34>
    return 0;
 81c:	b8 00 00 00 00       	mov    $0x0,%eax
 821:	eb 22                	jmp    845 <morecore+0x56>
  hp = (Header*)p;
 823:	8b 45 f4             	mov    -0xc(%ebp),%eax
 826:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 829:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82c:	8b 55 08             	mov    0x8(%ebp),%edx
 82f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 832:	8b 45 f0             	mov    -0x10(%ebp),%eax
 835:	83 c0 08             	add    $0x8,%eax
 838:	89 04 24             	mov    %eax,(%esp)
 83b:	e8 ce fe ff ff       	call   70e <free>
  return freep;
 840:	a1 d4 0b 00 00       	mov    0xbd4,%eax
}
 845:	c9                   	leave  
 846:	c3                   	ret    

00000847 <malloc>:

void*
malloc(uint nbytes)
{
 847:	55                   	push   %ebp
 848:	89 e5                	mov    %esp,%ebp
 84a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 84d:	8b 45 08             	mov    0x8(%ebp),%eax
 850:	83 c0 07             	add    $0x7,%eax
 853:	c1 e8 03             	shr    $0x3,%eax
 856:	83 c0 01             	add    $0x1,%eax
 859:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 85c:	a1 d4 0b 00 00       	mov    0xbd4,%eax
 861:	89 45 f0             	mov    %eax,-0x10(%ebp)
 864:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 868:	75 23                	jne    88d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 86a:	c7 45 f0 cc 0b 00 00 	movl   $0xbcc,-0x10(%ebp)
 871:	8b 45 f0             	mov    -0x10(%ebp),%eax
 874:	a3 d4 0b 00 00       	mov    %eax,0xbd4
 879:	a1 d4 0b 00 00       	mov    0xbd4,%eax
 87e:	a3 cc 0b 00 00       	mov    %eax,0xbcc
    base.s.size = 0;
 883:	c7 05 d0 0b 00 00 00 	movl   $0x0,0xbd0
 88a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 890:	8b 00                	mov    (%eax),%eax
 892:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 895:	8b 45 f4             	mov    -0xc(%ebp),%eax
 898:	8b 40 04             	mov    0x4(%eax),%eax
 89b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 89e:	72 4d                	jb     8ed <malloc+0xa6>
      if(p->s.size == nunits)
 8a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a3:	8b 40 04             	mov    0x4(%eax),%eax
 8a6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8a9:	75 0c                	jne    8b7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ae:	8b 10                	mov    (%eax),%edx
 8b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b3:	89 10                	mov    %edx,(%eax)
 8b5:	eb 26                	jmp    8dd <malloc+0x96>
      else {
        p->s.size -= nunits;
 8b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ba:	8b 40 04             	mov    0x4(%eax),%eax
 8bd:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8c0:	89 c2                	mov    %eax,%edx
 8c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cb:	8b 40 04             	mov    0x4(%eax),%eax
 8ce:	c1 e0 03             	shl    $0x3,%eax
 8d1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8da:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e0:	a3 d4 0b 00 00       	mov    %eax,0xbd4
      return (void*)(p + 1);
 8e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e8:	83 c0 08             	add    $0x8,%eax
 8eb:	eb 38                	jmp    925 <malloc+0xde>
    }
    if(p == freep)
 8ed:	a1 d4 0b 00 00       	mov    0xbd4,%eax
 8f2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8f5:	75 1b                	jne    912 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8fa:	89 04 24             	mov    %eax,(%esp)
 8fd:	e8 ed fe ff ff       	call   7ef <morecore>
 902:	89 45 f4             	mov    %eax,-0xc(%ebp)
 905:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 909:	75 07                	jne    912 <malloc+0xcb>
        return 0;
 90b:	b8 00 00 00 00       	mov    $0x0,%eax
 910:	eb 13                	jmp    925 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 912:	8b 45 f4             	mov    -0xc(%ebp),%eax
 915:	89 45 f0             	mov    %eax,-0x10(%ebp)
 918:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91b:	8b 00                	mov    (%eax),%eax
 91d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 920:	e9 70 ff ff ff       	jmp    895 <malloc+0x4e>
}
 925:	c9                   	leave  
 926:	c3                   	ret    
