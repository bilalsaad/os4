
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <iputtest>:
int stdout = 1;
#define d2 printf(1, "%d %s %d\n", __LINE__, __func__, getpid());
// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "iput test\n");
       6:	a1 d4 62 00 00       	mov    0x62d4,%eax
       b:	c7 44 24 04 2a 44 00 	movl   $0x442a,0x4(%esp)
      12:	00 
      13:	89 04 24             	mov    %eax,(%esp)
      16:	e8 2c 40 00 00       	call   4047 <printf>

  if(mkdir("iputdir") < 0){
      1b:	c7 04 24 35 44 00 00 	movl   $0x4435,(%esp)
      22:	e8 00 3f 00 00       	call   3f27 <mkdir>
      27:	85 c0                	test   %eax,%eax
      29:	79 1a                	jns    45 <iputtest+0x45>
    printf(stdout, "mkdir failed\n");
      2b:	a1 d4 62 00 00       	mov    0x62d4,%eax
      30:	c7 44 24 04 3d 44 00 	movl   $0x443d,0x4(%esp)
      37:	00 
      38:	89 04 24             	mov    %eax,(%esp)
      3b:	e8 07 40 00 00       	call   4047 <printf>
    exit();
      40:	e8 7a 3e 00 00       	call   3ebf <exit>
  }
  if(chdir("iputdir") < 0){
      45:	c7 04 24 35 44 00 00 	movl   $0x4435,(%esp)
      4c:	e8 de 3e 00 00       	call   3f2f <chdir>
      51:	85 c0                	test   %eax,%eax
      53:	79 1a                	jns    6f <iputtest+0x6f>
    printf(stdout, "chdir iputdir failed\n");
      55:	a1 d4 62 00 00       	mov    0x62d4,%eax
      5a:	c7 44 24 04 4b 44 00 	movl   $0x444b,0x4(%esp)
      61:	00 
      62:	89 04 24             	mov    %eax,(%esp)
      65:	e8 dd 3f 00 00       	call   4047 <printf>
    exit();
      6a:	e8 50 3e 00 00       	call   3ebf <exit>
  }
  if(unlink("../iputdir") < 0){
      6f:	c7 04 24 61 44 00 00 	movl   $0x4461,(%esp)
      76:	e8 94 3e 00 00       	call   3f0f <unlink>
      7b:	85 c0                	test   %eax,%eax
      7d:	79 1a                	jns    99 <iputtest+0x99>
    printf(stdout, "unlink ../iputdir failed\n");
      7f:	a1 d4 62 00 00       	mov    0x62d4,%eax
      84:	c7 44 24 04 6c 44 00 	movl   $0x446c,0x4(%esp)
      8b:	00 
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 b3 3f 00 00       	call   4047 <printf>
    exit();
      94:	e8 26 3e 00 00       	call   3ebf <exit>
  }
  if(chdir("/") < 0){
      99:	c7 04 24 86 44 00 00 	movl   $0x4486,(%esp)
      a0:	e8 8a 3e 00 00       	call   3f2f <chdir>
      a5:	85 c0                	test   %eax,%eax
      a7:	79 1a                	jns    c3 <iputtest+0xc3>
    printf(stdout, "chdir / failed\n");
      a9:	a1 d4 62 00 00       	mov    0x62d4,%eax
      ae:	c7 44 24 04 88 44 00 	movl   $0x4488,0x4(%esp)
      b5:	00 
      b6:	89 04 24             	mov    %eax,(%esp)
      b9:	e8 89 3f 00 00       	call   4047 <printf>
    exit();
      be:	e8 fc 3d 00 00       	call   3ebf <exit>
  }
  printf(stdout, "iput test ok\n");
      c3:	a1 d4 62 00 00       	mov    0x62d4,%eax
      c8:	c7 44 24 04 98 44 00 	movl   $0x4498,0x4(%esp)
      cf:	00 
      d0:	89 04 24             	mov    %eax,(%esp)
      d3:	e8 6f 3f 00 00       	call   4047 <printf>
}
      d8:	c9                   	leave  
      d9:	c3                   	ret    

000000da <exitiputtest>:

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
      da:	55                   	push   %ebp
      db:	89 e5                	mov    %esp,%ebp
      dd:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "exitiput test\n");
      e0:	a1 d4 62 00 00       	mov    0x62d4,%eax
      e5:	c7 44 24 04 a6 44 00 	movl   $0x44a6,0x4(%esp)
      ec:	00 
      ed:	89 04 24             	mov    %eax,(%esp)
      f0:	e8 52 3f 00 00       	call   4047 <printf>

  pid = fork();
      f5:	e8 bd 3d 00 00       	call   3eb7 <fork>
      fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
      fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     101:	79 1a                	jns    11d <exitiputtest+0x43>
    printf(stdout, "fork failed\n");
     103:	a1 d4 62 00 00       	mov    0x62d4,%eax
     108:	c7 44 24 04 b5 44 00 	movl   $0x44b5,0x4(%esp)
     10f:	00 
     110:	89 04 24             	mov    %eax,(%esp)
     113:	e8 2f 3f 00 00       	call   4047 <printf>
    exit();
     118:	e8 a2 3d 00 00       	call   3ebf <exit>
  }
  if(pid == 0){
     11d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     121:	0f 85 83 00 00 00    	jne    1aa <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
     127:	c7 04 24 35 44 00 00 	movl   $0x4435,(%esp)
     12e:	e8 f4 3d 00 00       	call   3f27 <mkdir>
     133:	85 c0                	test   %eax,%eax
     135:	79 1a                	jns    151 <exitiputtest+0x77>
      printf(stdout, "mkdir failed\n");
     137:	a1 d4 62 00 00       	mov    0x62d4,%eax
     13c:	c7 44 24 04 3d 44 00 	movl   $0x443d,0x4(%esp)
     143:	00 
     144:	89 04 24             	mov    %eax,(%esp)
     147:	e8 fb 3e 00 00       	call   4047 <printf>
      exit();
     14c:	e8 6e 3d 00 00       	call   3ebf <exit>
    }
    if(chdir("iputdir") < 0){
     151:	c7 04 24 35 44 00 00 	movl   $0x4435,(%esp)
     158:	e8 d2 3d 00 00       	call   3f2f <chdir>
     15d:	85 c0                	test   %eax,%eax
     15f:	79 1a                	jns    17b <exitiputtest+0xa1>
      printf(stdout, "child chdir failed\n");
     161:	a1 d4 62 00 00       	mov    0x62d4,%eax
     166:	c7 44 24 04 c2 44 00 	movl   $0x44c2,0x4(%esp)
     16d:	00 
     16e:	89 04 24             	mov    %eax,(%esp)
     171:	e8 d1 3e 00 00       	call   4047 <printf>
      exit();
     176:	e8 44 3d 00 00       	call   3ebf <exit>
    }
    if(unlink("../iputdir") < 0){
     17b:	c7 04 24 61 44 00 00 	movl   $0x4461,(%esp)
     182:	e8 88 3d 00 00       	call   3f0f <unlink>
     187:	85 c0                	test   %eax,%eax
     189:	79 1a                	jns    1a5 <exitiputtest+0xcb>
      printf(stdout, "unlink ../iputdir failed\n");
     18b:	a1 d4 62 00 00       	mov    0x62d4,%eax
     190:	c7 44 24 04 6c 44 00 	movl   $0x446c,0x4(%esp)
     197:	00 
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 a7 3e 00 00       	call   4047 <printf>
      exit();
     1a0:	e8 1a 3d 00 00       	call   3ebf <exit>
    }
    exit();
     1a5:	e8 15 3d 00 00       	call   3ebf <exit>
  }
  wait();
     1aa:	e8 18 3d 00 00       	call   3ec7 <wait>
  printf(stdout, "exitiput test ok\n");
     1af:	a1 d4 62 00 00       	mov    0x62d4,%eax
     1b4:	c7 44 24 04 d6 44 00 	movl   $0x44d6,0x4(%esp)
     1bb:	00 
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 83 3e 00 00       	call   4047 <printf>
}
     1c4:	c9                   	leave  
     1c5:	c3                   	ret    

000001c6 <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     1c6:	55                   	push   %ebp
     1c7:	89 e5                	mov    %esp,%ebp
     1c9:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "openiput test\n");
     1cc:	a1 d4 62 00 00       	mov    0x62d4,%eax
     1d1:	c7 44 24 04 e8 44 00 	movl   $0x44e8,0x4(%esp)
     1d8:	00 
     1d9:	89 04 24             	mov    %eax,(%esp)
     1dc:	e8 66 3e 00 00       	call   4047 <printf>
  if(mkdir("oidir") < 0){
     1e1:	c7 04 24 f7 44 00 00 	movl   $0x44f7,(%esp)
     1e8:	e8 3a 3d 00 00       	call   3f27 <mkdir>
     1ed:	85 c0                	test   %eax,%eax
     1ef:	79 1a                	jns    20b <openiputtest+0x45>
    printf(stdout, "mkdir oidir failed\n");
     1f1:	a1 d4 62 00 00       	mov    0x62d4,%eax
     1f6:	c7 44 24 04 fd 44 00 	movl   $0x44fd,0x4(%esp)
     1fd:	00 
     1fe:	89 04 24             	mov    %eax,(%esp)
     201:	e8 41 3e 00 00       	call   4047 <printf>
    exit();
     206:	e8 b4 3c 00 00       	call   3ebf <exit>
  }
  pid = fork();
     20b:	e8 a7 3c 00 00       	call   3eb7 <fork>
     210:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
     213:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     217:	79 1a                	jns    233 <openiputtest+0x6d>
    printf(stdout, "fork failed\n");
     219:	a1 d4 62 00 00       	mov    0x62d4,%eax
     21e:	c7 44 24 04 b5 44 00 	movl   $0x44b5,0x4(%esp)
     225:	00 
     226:	89 04 24             	mov    %eax,(%esp)
     229:	e8 19 3e 00 00       	call   4047 <printf>
    exit();
     22e:	e8 8c 3c 00 00       	call   3ebf <exit>
  }
  if(pid == 0){
     233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     237:	75 3c                	jne    275 <openiputtest+0xaf>
    int fd = open("oidir", O_RDWR);
     239:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     240:	00 
     241:	c7 04 24 f7 44 00 00 	movl   $0x44f7,(%esp)
     248:	e8 b2 3c 00 00       	call   3eff <open>
     24d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0){
     250:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     254:	78 1a                	js     270 <openiputtest+0xaa>
      printf(stdout, "open directory for write succeeded\n");
     256:	a1 d4 62 00 00       	mov    0x62d4,%eax
     25b:	c7 44 24 04 14 45 00 	movl   $0x4514,0x4(%esp)
     262:	00 
     263:	89 04 24             	mov    %eax,(%esp)
     266:	e8 dc 3d 00 00       	call   4047 <printf>
      exit();
     26b:	e8 4f 3c 00 00       	call   3ebf <exit>
    }
    exit();
     270:	e8 4a 3c 00 00       	call   3ebf <exit>
  }
  sleep(1);
     275:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     27c:	e8 ce 3c 00 00       	call   3f4f <sleep>
  if(unlink("oidir") != 0){
     281:	c7 04 24 f7 44 00 00 	movl   $0x44f7,(%esp)
     288:	e8 82 3c 00 00       	call   3f0f <unlink>
     28d:	85 c0                	test   %eax,%eax
     28f:	74 1a                	je     2ab <openiputtest+0xe5>
    printf(stdout, "unlink failed\n");
     291:	a1 d4 62 00 00       	mov    0x62d4,%eax
     296:	c7 44 24 04 38 45 00 	movl   $0x4538,0x4(%esp)
     29d:	00 
     29e:	89 04 24             	mov    %eax,(%esp)
     2a1:	e8 a1 3d 00 00       	call   4047 <printf>
    exit();
     2a6:	e8 14 3c 00 00       	call   3ebf <exit>
  }
  wait();
     2ab:	e8 17 3c 00 00       	call   3ec7 <wait>
  printf(stdout, "openiput test ok\n");
     2b0:	a1 d4 62 00 00       	mov    0x62d4,%eax
     2b5:	c7 44 24 04 47 45 00 	movl   $0x4547,0x4(%esp)
     2bc:	00 
     2bd:	89 04 24             	mov    %eax,(%esp)
     2c0:	e8 82 3d 00 00       	call   4047 <printf>
}
     2c5:	c9                   	leave  
     2c6:	c3                   	ret    

000002c7 <opentest>:

// simple file system tests

void
opentest(void)
{
     2c7:	55                   	push   %ebp
     2c8:	89 e5                	mov    %esp,%ebp
     2ca:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(stdout, "open test\n");
     2cd:	a1 d4 62 00 00       	mov    0x62d4,%eax
     2d2:	c7 44 24 04 59 45 00 	movl   $0x4559,0x4(%esp)
     2d9:	00 
     2da:	89 04 24             	mov    %eax,(%esp)
     2dd:	e8 65 3d 00 00       	call   4047 <printf>
  fd = open("echo", 0);
     2e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     2e9:	00 
     2ea:	c7 04 24 14 44 00 00 	movl   $0x4414,(%esp)
     2f1:	e8 09 3c 00 00       	call   3eff <open>
     2f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
     2f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     2fd:	79 1a                	jns    319 <opentest+0x52>
    printf(stdout, "open echo failed!\n");
     2ff:	a1 d4 62 00 00       	mov    0x62d4,%eax
     304:	c7 44 24 04 64 45 00 	movl   $0x4564,0x4(%esp)
     30b:	00 
     30c:	89 04 24             	mov    %eax,(%esp)
     30f:	e8 33 3d 00 00       	call   4047 <printf>
    exit();
     314:	e8 a6 3b 00 00       	call   3ebf <exit>
  }
  close(fd);
     319:	8b 45 f4             	mov    -0xc(%ebp),%eax
     31c:	89 04 24             	mov    %eax,(%esp)
     31f:	e8 c3 3b 00 00       	call   3ee7 <close>
  fd = open("doesnotexist", 0);
     324:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     32b:	00 
     32c:	c7 04 24 77 45 00 00 	movl   $0x4577,(%esp)
     333:	e8 c7 3b 00 00       	call   3eff <open>
     338:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
     33b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     33f:	78 1a                	js     35b <opentest+0x94>
    printf(stdout, "open doesnotexist succeeded!\n");
     341:	a1 d4 62 00 00       	mov    0x62d4,%eax
     346:	c7 44 24 04 84 45 00 	movl   $0x4584,0x4(%esp)
     34d:	00 
     34e:	89 04 24             	mov    %eax,(%esp)
     351:	e8 f1 3c 00 00       	call   4047 <printf>
    exit();
     356:	e8 64 3b 00 00       	call   3ebf <exit>
  }
  printf(stdout, "open test ok\n");
     35b:	a1 d4 62 00 00       	mov    0x62d4,%eax
     360:	c7 44 24 04 a2 45 00 	movl   $0x45a2,0x4(%esp)
     367:	00 
     368:	89 04 24             	mov    %eax,(%esp)
     36b:	e8 d7 3c 00 00       	call   4047 <printf>
}
     370:	c9                   	leave  
     371:	c3                   	ret    

00000372 <writetest>:

void
writetest(void)
{
     372:	55                   	push   %ebp
     373:	89 e5                	mov    %esp,%ebp
     375:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
     378:	a1 d4 62 00 00       	mov    0x62d4,%eax
     37d:	c7 44 24 04 b0 45 00 	movl   $0x45b0,0x4(%esp)
     384:	00 
     385:	89 04 24             	mov    %eax,(%esp)
     388:	e8 ba 3c 00 00       	call   4047 <printf>
  fd = open("small", O_CREATE|O_RDWR);
     38d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     394:	00 
     395:	c7 04 24 c1 45 00 00 	movl   $0x45c1,(%esp)
     39c:	e8 5e 3b 00 00       	call   3eff <open>
     3a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     3a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     3a8:	78 21                	js     3cb <writetest+0x59>
    printf(stdout, "creat small succeeded; ok\n");
     3aa:	a1 d4 62 00 00       	mov    0x62d4,%eax
     3af:	c7 44 24 04 c7 45 00 	movl   $0x45c7,0x4(%esp)
     3b6:	00 
     3b7:	89 04 24             	mov    %eax,(%esp)
     3ba:	e8 88 3c 00 00       	call   4047 <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     3bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     3c6:	e9 a0 00 00 00       	jmp    46b <writetest+0xf9>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
     3cb:	a1 d4 62 00 00       	mov    0x62d4,%eax
     3d0:	c7 44 24 04 e2 45 00 	movl   $0x45e2,0x4(%esp)
     3d7:	00 
     3d8:	89 04 24             	mov    %eax,(%esp)
     3db:	e8 67 3c 00 00       	call   4047 <printf>
    exit();
     3e0:	e8 da 3a 00 00       	call   3ebf <exit>
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     3e5:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     3ec:	00 
     3ed:	c7 44 24 04 fe 45 00 	movl   $0x45fe,0x4(%esp)
     3f4:	00 
     3f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     3f8:	89 04 24             	mov    %eax,(%esp)
     3fb:	e8 df 3a 00 00       	call   3edf <write>
     400:	83 f8 0a             	cmp    $0xa,%eax
     403:	74 21                	je     426 <writetest+0xb4>
      printf(stdout, "error: write aa %d new file failed\n", i);
     405:	a1 d4 62 00 00       	mov    0x62d4,%eax
     40a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     40d:	89 54 24 08          	mov    %edx,0x8(%esp)
     411:	c7 44 24 04 0c 46 00 	movl   $0x460c,0x4(%esp)
     418:	00 
     419:	89 04 24             	mov    %eax,(%esp)
     41c:	e8 26 3c 00 00       	call   4047 <printf>
      exit();
     421:	e8 99 3a 00 00       	call   3ebf <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     426:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     42d:	00 
     42e:	c7 44 24 04 30 46 00 	movl   $0x4630,0x4(%esp)
     435:	00 
     436:	8b 45 f0             	mov    -0x10(%ebp),%eax
     439:	89 04 24             	mov    %eax,(%esp)
     43c:	e8 9e 3a 00 00       	call   3edf <write>
     441:	83 f8 0a             	cmp    $0xa,%eax
     444:	74 21                	je     467 <writetest+0xf5>
      printf(stdout, "error: write bb %d new file failed\n", i);
     446:	a1 d4 62 00 00       	mov    0x62d4,%eax
     44b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     44e:	89 54 24 08          	mov    %edx,0x8(%esp)
     452:	c7 44 24 04 3c 46 00 	movl   $0x463c,0x4(%esp)
     459:	00 
     45a:	89 04 24             	mov    %eax,(%esp)
     45d:	e8 e5 3b 00 00       	call   4047 <printf>
      exit();
     462:	e8 58 3a 00 00       	call   3ebf <exit>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     467:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     46b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     46f:	0f 8e 70 ff ff ff    	jle    3e5 <writetest+0x73>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit();
    }
  }
  printf(stdout, "writes ok\n");
     475:	a1 d4 62 00 00       	mov    0x62d4,%eax
     47a:	c7 44 24 04 60 46 00 	movl   $0x4660,0x4(%esp)
     481:	00 
     482:	89 04 24             	mov    %eax,(%esp)
     485:	e8 bd 3b 00 00       	call   4047 <printf>
  close(fd);
     48a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     48d:	89 04 24             	mov    %eax,(%esp)
     490:	e8 52 3a 00 00       	call   3ee7 <close>
  fd = open("small", O_RDONLY);
     495:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     49c:	00 
     49d:	c7 04 24 c1 45 00 00 	movl   $0x45c1,(%esp)
     4a4:	e8 56 3a 00 00       	call   3eff <open>
     4a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     4ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     4b0:	78 3e                	js     4f0 <writetest+0x17e>
    printf(stdout, "open small succeeded ok\n");
     4b2:	a1 d4 62 00 00       	mov    0x62d4,%eax
     4b7:	c7 44 24 04 6b 46 00 	movl   $0x466b,0x4(%esp)
     4be:	00 
     4bf:	89 04 24             	mov    %eax,(%esp)
     4c2:	e8 80 3b 00 00       	call   4047 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     4c7:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
     4ce:	00 
     4cf:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     4d6:	00 
     4d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4da:	89 04 24             	mov    %eax,(%esp)
     4dd:	e8 f5 39 00 00       	call   3ed7 <read>
     4e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(i == 2000){
     4e5:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
     4ec:	75 4e                	jne    53c <writetest+0x1ca>
     4ee:	eb 1a                	jmp    50a <writetest+0x198>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
     4f0:	a1 d4 62 00 00       	mov    0x62d4,%eax
     4f5:	c7 44 24 04 84 46 00 	movl   $0x4684,0x4(%esp)
     4fc:	00 
     4fd:	89 04 24             	mov    %eax,(%esp)
     500:	e8 42 3b 00 00       	call   4047 <printf>
    exit();
     505:	e8 b5 39 00 00       	call   3ebf <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
     50a:	a1 d4 62 00 00       	mov    0x62d4,%eax
     50f:	c7 44 24 04 9f 46 00 	movl   $0x469f,0x4(%esp)
     516:	00 
     517:	89 04 24             	mov    %eax,(%esp)
     51a:	e8 28 3b 00 00       	call   4047 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     51f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     522:	89 04 24             	mov    %eax,(%esp)
     525:	e8 bd 39 00 00       	call   3ee7 <close>

  if(unlink("small") < 0){
     52a:	c7 04 24 c1 45 00 00 	movl   $0x45c1,(%esp)
     531:	e8 d9 39 00 00       	call   3f0f <unlink>
     536:	85 c0                	test   %eax,%eax
     538:	79 36                	jns    570 <writetest+0x1fe>
     53a:	eb 1a                	jmp    556 <writetest+0x1e4>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
     53c:	a1 d4 62 00 00       	mov    0x62d4,%eax
     541:	c7 44 24 04 b2 46 00 	movl   $0x46b2,0x4(%esp)
     548:	00 
     549:	89 04 24             	mov    %eax,(%esp)
     54c:	e8 f6 3a 00 00       	call   4047 <printf>
    exit();
     551:	e8 69 39 00 00       	call   3ebf <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
     556:	a1 d4 62 00 00       	mov    0x62d4,%eax
     55b:	c7 44 24 04 bf 46 00 	movl   $0x46bf,0x4(%esp)
     562:	00 
     563:	89 04 24             	mov    %eax,(%esp)
     566:	e8 dc 3a 00 00       	call   4047 <printf>
    exit();
     56b:	e8 4f 39 00 00       	call   3ebf <exit>
  }
  printf(stdout, "small file test ok\n");
     570:	a1 d4 62 00 00       	mov    0x62d4,%eax
     575:	c7 44 24 04 d4 46 00 	movl   $0x46d4,0x4(%esp)
     57c:	00 
     57d:	89 04 24             	mov    %eax,(%esp)
     580:	e8 c2 3a 00 00       	call   4047 <printf>
}
     585:	c9                   	leave  
     586:	c3                   	ret    

00000587 <writetest1>:

void
writetest1(void)
{
     587:	55                   	push   %ebp
     588:	89 e5                	mov    %esp,%ebp
     58a:	83 ec 28             	sub    $0x28,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
     58d:	a1 d4 62 00 00       	mov    0x62d4,%eax
     592:	c7 44 24 04 e8 46 00 	movl   $0x46e8,0x4(%esp)
     599:	00 
     59a:	89 04 24             	mov    %eax,(%esp)
     59d:	e8 a5 3a 00 00       	call   4047 <printf>

  fd = open("big", O_CREATE|O_RDWR);
     5a2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     5a9:	00 
     5aa:	c7 04 24 f8 46 00 00 	movl   $0x46f8,(%esp)
     5b1:	e8 49 39 00 00       	call   3eff <open>
     5b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     5b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     5bd:	79 1a                	jns    5d9 <writetest1+0x52>
    printf(stdout, "error: creat big failed!\n");
     5bf:	a1 d4 62 00 00       	mov    0x62d4,%eax
     5c4:	c7 44 24 04 fc 46 00 	movl   $0x46fc,0x4(%esp)
     5cb:	00 
     5cc:	89 04 24             	mov    %eax,(%esp)
     5cf:	e8 73 3a 00 00       	call   4047 <printf>
    exit();
     5d4:	e8 e6 38 00 00       	call   3ebf <exit>
  }

  for(i = 0; i < MAXFILE; i++){
     5d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     5e0:	eb 51                	jmp    633 <writetest1+0xac>
    ((int*)buf)[0] = i;
     5e2:	b8 c0 8a 00 00       	mov    $0x8ac0,%eax
     5e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5ea:	89 10                	mov    %edx,(%eax)
    if(write(fd, buf, 512) != 512){
     5ec:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     5f3:	00 
     5f4:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     5fb:	00 
     5fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
     5ff:	89 04 24             	mov    %eax,(%esp)
     602:	e8 d8 38 00 00       	call   3edf <write>
     607:	3d 00 02 00 00       	cmp    $0x200,%eax
     60c:	74 21                	je     62f <writetest1+0xa8>
      printf(stdout, "error: write big file failed\n", i);
     60e:	a1 d4 62 00 00       	mov    0x62d4,%eax
     613:	8b 55 f4             	mov    -0xc(%ebp),%edx
     616:	89 54 24 08          	mov    %edx,0x8(%esp)
     61a:	c7 44 24 04 16 47 00 	movl   $0x4716,0x4(%esp)
     621:	00 
     622:	89 04 24             	mov    %eax,(%esp)
     625:	e8 1d 3a 00 00       	call   4047 <printf>
      exit();
     62a:	e8 90 38 00 00       	call   3ebf <exit>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
     62f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     633:	8b 45 f4             	mov    -0xc(%ebp),%eax
     636:	3d 8b 00 00 00       	cmp    $0x8b,%eax
     63b:	76 a5                	jbe    5e2 <writetest1+0x5b>
      printf(stdout, "error: write big file failed\n", i);
      exit();
    }
  }

  close(fd);
     63d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     640:	89 04 24             	mov    %eax,(%esp)
     643:	e8 9f 38 00 00       	call   3ee7 <close>

  fd = open("big", O_RDONLY);
     648:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     64f:	00 
     650:	c7 04 24 f8 46 00 00 	movl   $0x46f8,(%esp)
     657:	e8 a3 38 00 00       	call   3eff <open>
     65c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     65f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     663:	79 1a                	jns    67f <writetest1+0xf8>
    printf(stdout, "error: open big failed!\n");
     665:	a1 d4 62 00 00       	mov    0x62d4,%eax
     66a:	c7 44 24 04 34 47 00 	movl   $0x4734,0x4(%esp)
     671:	00 
     672:	89 04 24             	mov    %eax,(%esp)
     675:	e8 cd 39 00 00       	call   4047 <printf>
    exit();
     67a:	e8 40 38 00 00       	call   3ebf <exit>
  }

  n = 0;
     67f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(;;){
    i = read(fd, buf, 512);
     686:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     68d:	00 
     68e:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     695:	00 
     696:	8b 45 ec             	mov    -0x14(%ebp),%eax
     699:	89 04 24             	mov    %eax,(%esp)
     69c:	e8 36 38 00 00       	call   3ed7 <read>
     6a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i == 0){
     6a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     6a8:	75 4c                	jne    6f6 <writetest1+0x16f>
      if(n == MAXFILE - 1){
     6aa:	81 7d f0 8b 00 00 00 	cmpl   $0x8b,-0x10(%ebp)
     6b1:	75 21                	jne    6d4 <writetest1+0x14d>
        printf(stdout, "read only %d blocks from big", n);
     6b3:	a1 d4 62 00 00       	mov    0x62d4,%eax
     6b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
     6bb:	89 54 24 08          	mov    %edx,0x8(%esp)
     6bf:	c7 44 24 04 4d 47 00 	movl   $0x474d,0x4(%esp)
     6c6:	00 
     6c7:	89 04 24             	mov    %eax,(%esp)
     6ca:	e8 78 39 00 00       	call   4047 <printf>
        exit();
     6cf:	e8 eb 37 00 00       	call   3ebf <exit>
      }
      break;
     6d4:	90                   	nop
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
  }
  close(fd);
     6d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
     6d8:	89 04 24             	mov    %eax,(%esp)
     6db:	e8 07 38 00 00       	call   3ee7 <close>
  if(unlink("big") < 0){
     6e0:	c7 04 24 f8 46 00 00 	movl   $0x46f8,(%esp)
     6e7:	e8 23 38 00 00       	call   3f0f <unlink>
     6ec:	85 c0                	test   %eax,%eax
     6ee:	0f 89 87 00 00 00    	jns    77b <writetest1+0x1f4>
     6f4:	eb 6b                	jmp    761 <writetest1+0x1da>
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
     6f6:	81 7d f4 00 02 00 00 	cmpl   $0x200,-0xc(%ebp)
     6fd:	74 21                	je     720 <writetest1+0x199>
      printf(stdout, "read failed %d\n", i);
     6ff:	a1 d4 62 00 00       	mov    0x62d4,%eax
     704:	8b 55 f4             	mov    -0xc(%ebp),%edx
     707:	89 54 24 08          	mov    %edx,0x8(%esp)
     70b:	c7 44 24 04 6a 47 00 	movl   $0x476a,0x4(%esp)
     712:	00 
     713:	89 04 24             	mov    %eax,(%esp)
     716:	e8 2c 39 00 00       	call   4047 <printf>
      exit();
     71b:	e8 9f 37 00 00       	call   3ebf <exit>
    }
    if(((int*)buf)[0] != n){
     720:	b8 c0 8a 00 00       	mov    $0x8ac0,%eax
     725:	8b 00                	mov    (%eax),%eax
     727:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     72a:	74 2c                	je     758 <writetest1+0x1d1>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
     72c:	b8 c0 8a 00 00       	mov    $0x8ac0,%eax
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
     731:	8b 10                	mov    (%eax),%edx
     733:	a1 d4 62 00 00       	mov    0x62d4,%eax
     738:	89 54 24 0c          	mov    %edx,0xc(%esp)
     73c:	8b 55 f0             	mov    -0x10(%ebp),%edx
     73f:	89 54 24 08          	mov    %edx,0x8(%esp)
     743:	c7 44 24 04 7c 47 00 	movl   $0x477c,0x4(%esp)
     74a:	00 
     74b:	89 04 24             	mov    %eax,(%esp)
     74e:	e8 f4 38 00 00       	call   4047 <printf>
             n, ((int*)buf)[0]);
      exit();
     753:	e8 67 37 00 00       	call   3ebf <exit>
    }
    n++;
     758:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }
     75c:	e9 25 ff ff ff       	jmp    686 <writetest1+0xff>
  close(fd);
  if(unlink("big") < 0){
    printf(stdout, "unlink big failed\n");
     761:	a1 d4 62 00 00       	mov    0x62d4,%eax
     766:	c7 44 24 04 9c 47 00 	movl   $0x479c,0x4(%esp)
     76d:	00 
     76e:	89 04 24             	mov    %eax,(%esp)
     771:	e8 d1 38 00 00       	call   4047 <printf>
    exit();
     776:	e8 44 37 00 00       	call   3ebf <exit>
  }
  printf(stdout, "big files ok\n");
     77b:	a1 d4 62 00 00       	mov    0x62d4,%eax
     780:	c7 44 24 04 af 47 00 	movl   $0x47af,0x4(%esp)
     787:	00 
     788:	89 04 24             	mov    %eax,(%esp)
     78b:	e8 b7 38 00 00       	call   4047 <printf>
}
     790:	c9                   	leave  
     791:	c3                   	ret    

00000792 <createtest>:

void
createtest(void)
{
     792:	55                   	push   %ebp
     793:	89 e5                	mov    %esp,%ebp
     795:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     798:	a1 d4 62 00 00       	mov    0x62d4,%eax
     79d:	c7 44 24 04 c0 47 00 	movl   $0x47c0,0x4(%esp)
     7a4:	00 
     7a5:	89 04 24             	mov    %eax,(%esp)
     7a8:	e8 9a 38 00 00       	call   4047 <printf>

  name[0] = 'a';
     7ad:	c6 05 c0 aa 00 00 61 	movb   $0x61,0xaac0
  name[2] = '\0';
     7b4:	c6 05 c2 aa 00 00 00 	movb   $0x0,0xaac2
  for(i = 0; i < 52; i++){
     7bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     7c2:	eb 31                	jmp    7f5 <createtest+0x63>
    name[1] = '0' + i;
     7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7c7:	83 c0 30             	add    $0x30,%eax
     7ca:	a2 c1 aa 00 00       	mov    %al,0xaac1
    fd = open(name, O_CREATE|O_RDWR);
     7cf:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     7d6:	00 
     7d7:	c7 04 24 c0 aa 00 00 	movl   $0xaac0,(%esp)
     7de:	e8 1c 37 00 00       	call   3eff <open>
     7e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(fd);
     7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7e9:	89 04 24             	mov    %eax,(%esp)
     7ec:	e8 f6 36 00 00       	call   3ee7 <close>

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     7f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     7f5:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     7f9:	7e c9                	jle    7c4 <createtest+0x32>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
     7fb:	c6 05 c0 aa 00 00 61 	movb   $0x61,0xaac0
  name[2] = '\0';
     802:	c6 05 c2 aa 00 00 00 	movb   $0x0,0xaac2
  for(i = 0; i < 52; i++){
     809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     810:	eb 1b                	jmp    82d <createtest+0x9b>
    name[1] = '0' + i;
     812:	8b 45 f4             	mov    -0xc(%ebp),%eax
     815:	83 c0 30             	add    $0x30,%eax
     818:	a2 c1 aa 00 00       	mov    %al,0xaac1
    unlink(name);
     81d:	c7 04 24 c0 aa 00 00 	movl   $0xaac0,(%esp)
     824:	e8 e6 36 00 00       	call   3f0f <unlink>
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     829:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     82d:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     831:	7e df                	jle    812 <createtest+0x80>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     833:	a1 d4 62 00 00       	mov    0x62d4,%eax
     838:	c7 44 24 04 e8 47 00 	movl   $0x47e8,0x4(%esp)
     83f:	00 
     840:	89 04 24             	mov    %eax,(%esp)
     843:	e8 ff 37 00 00       	call   4047 <printf>
}
     848:	c9                   	leave  
     849:	c3                   	ret    

0000084a <dirtest>:

void dirtest(void)
{
     84a:	55                   	push   %ebp
     84b:	89 e5                	mov    %esp,%ebp
     84d:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
     850:	a1 d4 62 00 00       	mov    0x62d4,%eax
     855:	c7 44 24 04 0e 48 00 	movl   $0x480e,0x4(%esp)
     85c:	00 
     85d:	89 04 24             	mov    %eax,(%esp)
     860:	e8 e2 37 00 00       	call   4047 <printf>

  if(mkdir("dir0") < 0){
     865:	c7 04 24 1a 48 00 00 	movl   $0x481a,(%esp)
     86c:	e8 b6 36 00 00       	call   3f27 <mkdir>
     871:	85 c0                	test   %eax,%eax
     873:	79 1a                	jns    88f <dirtest+0x45>
    printf(stdout, "mkdir failed\n");
     875:	a1 d4 62 00 00       	mov    0x62d4,%eax
     87a:	c7 44 24 04 3d 44 00 	movl   $0x443d,0x4(%esp)
     881:	00 
     882:	89 04 24             	mov    %eax,(%esp)
     885:	e8 bd 37 00 00       	call   4047 <printf>
    exit();
     88a:	e8 30 36 00 00       	call   3ebf <exit>
  }

  if(chdir("dir0") < 0){
     88f:	c7 04 24 1a 48 00 00 	movl   $0x481a,(%esp)
     896:	e8 94 36 00 00       	call   3f2f <chdir>
     89b:	85 c0                	test   %eax,%eax
     89d:	79 1a                	jns    8b9 <dirtest+0x6f>
    printf(stdout, "chdir dir0 failed\n");
     89f:	a1 d4 62 00 00       	mov    0x62d4,%eax
     8a4:	c7 44 24 04 1f 48 00 	movl   $0x481f,0x4(%esp)
     8ab:	00 
     8ac:	89 04 24             	mov    %eax,(%esp)
     8af:	e8 93 37 00 00       	call   4047 <printf>
    exit();
     8b4:	e8 06 36 00 00       	call   3ebf <exit>
  }

  if(chdir("..") < 0){
     8b9:	c7 04 24 32 48 00 00 	movl   $0x4832,(%esp)
     8c0:	e8 6a 36 00 00       	call   3f2f <chdir>
     8c5:	85 c0                	test   %eax,%eax
     8c7:	79 1a                	jns    8e3 <dirtest+0x99>
    printf(stdout, "chdir .. failed\n");
     8c9:	a1 d4 62 00 00       	mov    0x62d4,%eax
     8ce:	c7 44 24 04 35 48 00 	movl   $0x4835,0x4(%esp)
     8d5:	00 
     8d6:	89 04 24             	mov    %eax,(%esp)
     8d9:	e8 69 37 00 00       	call   4047 <printf>
    exit();
     8de:	e8 dc 35 00 00       	call   3ebf <exit>
  }

  if(unlink("dir0") < 0){
     8e3:	c7 04 24 1a 48 00 00 	movl   $0x481a,(%esp)
     8ea:	e8 20 36 00 00       	call   3f0f <unlink>
     8ef:	85 c0                	test   %eax,%eax
     8f1:	79 1a                	jns    90d <dirtest+0xc3>
    printf(stdout, "unlink dir0 failed\n");
     8f3:	a1 d4 62 00 00       	mov    0x62d4,%eax
     8f8:	c7 44 24 04 46 48 00 	movl   $0x4846,0x4(%esp)
     8ff:	00 
     900:	89 04 24             	mov    %eax,(%esp)
     903:	e8 3f 37 00 00       	call   4047 <printf>
    exit();
     908:	e8 b2 35 00 00       	call   3ebf <exit>
  }
  printf(stdout, "mkdir test ok\n");
     90d:	a1 d4 62 00 00       	mov    0x62d4,%eax
     912:	c7 44 24 04 5a 48 00 	movl   $0x485a,0x4(%esp)
     919:	00 
     91a:	89 04 24             	mov    %eax,(%esp)
     91d:	e8 25 37 00 00       	call   4047 <printf>
}
     922:	c9                   	leave  
     923:	c3                   	ret    

00000924 <exectest>:

void
exectest(void)
{
     924:	55                   	push   %ebp
     925:	89 e5                	mov    %esp,%ebp
     927:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     92a:	a1 d4 62 00 00       	mov    0x62d4,%eax
     92f:	c7 44 24 04 69 48 00 	movl   $0x4869,0x4(%esp)
     936:	00 
     937:	89 04 24             	mov    %eax,(%esp)
     93a:	e8 08 37 00 00       	call   4047 <printf>
  if(exec("echo", echoargv) < 0){
     93f:	c7 44 24 04 c0 62 00 	movl   $0x62c0,0x4(%esp)
     946:	00 
     947:	c7 04 24 14 44 00 00 	movl   $0x4414,(%esp)
     94e:	e8 a4 35 00 00       	call   3ef7 <exec>
     953:	85 c0                	test   %eax,%eax
     955:	79 1a                	jns    971 <exectest+0x4d>
    printf(stdout, "exec echo failed\n");
     957:	a1 d4 62 00 00       	mov    0x62d4,%eax
     95c:	c7 44 24 04 74 48 00 	movl   $0x4874,0x4(%esp)
     963:	00 
     964:	89 04 24             	mov    %eax,(%esp)
     967:	e8 db 36 00 00       	call   4047 <printf>
    exit();
     96c:	e8 4e 35 00 00       	call   3ebf <exit>
  }
}
     971:	c9                   	leave  
     972:	c3                   	ret    

00000973 <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     973:	55                   	push   %ebp
     974:	89 e5                	mov    %esp,%ebp
     976:	83 ec 38             	sub    $0x38,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     979:	8d 45 d8             	lea    -0x28(%ebp),%eax
     97c:	89 04 24             	mov    %eax,(%esp)
     97f:	e8 4b 35 00 00       	call   3ecf <pipe>
     984:	85 c0                	test   %eax,%eax
     986:	74 19                	je     9a1 <pipe1+0x2e>
    printf(1, "pipe() failed\n");
     988:	c7 44 24 04 86 48 00 	movl   $0x4886,0x4(%esp)
     98f:	00 
     990:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     997:	e8 ab 36 00 00       	call   4047 <printf>
    exit();
     99c:	e8 1e 35 00 00       	call   3ebf <exit>
  }
  pid = fork();
     9a1:	e8 11 35 00 00       	call   3eb7 <fork>
     9a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  seq = 0;
     9a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(pid == 0){
     9b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     9b4:	0f 85 88 00 00 00    	jne    a42 <pipe1+0xcf>
    close(fds[0]);
     9ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
     9bd:	89 04 24             	mov    %eax,(%esp)
     9c0:	e8 22 35 00 00       	call   3ee7 <close>
    for(n = 0; n < 5; n++){
     9c5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     9cc:	eb 69                	jmp    a37 <pipe1+0xc4>
      for(i = 0; i < 1033; i++)
     9ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     9d5:	eb 18                	jmp    9ef <pipe1+0x7c>
        buf[i] = seq++;
     9d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9da:	8d 50 01             	lea    0x1(%eax),%edx
     9dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
     9e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
     9e3:	81 c2 c0 8a 00 00    	add    $0x8ac0,%edx
     9e9:	88 02                	mov    %al,(%edx)
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     9eb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     9ef:	81 7d f0 08 04 00 00 	cmpl   $0x408,-0x10(%ebp)
     9f6:	7e df                	jle    9d7 <pipe1+0x64>
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     9f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
     9fb:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     a02:	00 
     a03:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     a0a:	00 
     a0b:	89 04 24             	mov    %eax,(%esp)
     a0e:	e8 cc 34 00 00       	call   3edf <write>
     a13:	3d 09 04 00 00       	cmp    $0x409,%eax
     a18:	74 19                	je     a33 <pipe1+0xc0>
        printf(1, "pipe1 oops 1\n");
     a1a:	c7 44 24 04 95 48 00 	movl   $0x4895,0x4(%esp)
     a21:	00 
     a22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a29:	e8 19 36 00 00       	call   4047 <printf>
        exit();
     a2e:	e8 8c 34 00 00       	call   3ebf <exit>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
     a33:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     a37:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
     a3b:	7e 91                	jle    9ce <pipe1+0x5b>
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
     a3d:	e8 7d 34 00 00       	call   3ebf <exit>
  } else if(pid > 0){
     a42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     a46:	0f 8e f9 00 00 00    	jle    b45 <pipe1+0x1d2>
    close(fds[1]);
     a4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     a4f:	89 04 24             	mov    %eax,(%esp)
     a52:	e8 90 34 00 00       	call   3ee7 <close>
    total = 0;
     a57:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    cc = 1;
     a5e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
     a65:	eb 68                	jmp    acf <pipe1+0x15c>
      for(i = 0; i < n; i++){
     a67:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     a6e:	eb 3d                	jmp    aad <pipe1+0x13a>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a73:	05 c0 8a 00 00       	add    $0x8ac0,%eax
     a78:	0f b6 00             	movzbl (%eax),%eax
     a7b:	0f be c8             	movsbl %al,%ecx
     a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a81:	8d 50 01             	lea    0x1(%eax),%edx
     a84:	89 55 f4             	mov    %edx,-0xc(%ebp)
     a87:	31 c8                	xor    %ecx,%eax
     a89:	0f b6 c0             	movzbl %al,%eax
     a8c:	85 c0                	test   %eax,%eax
     a8e:	74 19                	je     aa9 <pipe1+0x136>
          printf(1, "pipe1 oops 2\n");
     a90:	c7 44 24 04 a3 48 00 	movl   $0x48a3,0x4(%esp)
     a97:	00 
     a98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a9f:	e8 a3 35 00 00       	call   4047 <printf>
     aa4:	e9 b5 00 00 00       	jmp    b5e <pipe1+0x1eb>
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     aa9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ab0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     ab3:	7c bb                	jl     a70 <pipe1+0xfd>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
     ab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ab8:	01 45 e4             	add    %eax,-0x1c(%ebp)
      cc = cc * 2;
     abb:	d1 65 e8             	shll   -0x18(%ebp)
      if(cc > sizeof(buf))
     abe:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ac1:	3d 00 20 00 00       	cmp    $0x2000,%eax
     ac6:	76 07                	jbe    acf <pipe1+0x15c>
        cc = sizeof(buf);
     ac8:	c7 45 e8 00 20 00 00 	movl   $0x2000,-0x18(%ebp)
    exit();
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     acf:	8b 45 d8             	mov    -0x28(%ebp),%eax
     ad2:	8b 55 e8             	mov    -0x18(%ebp),%edx
     ad5:	89 54 24 08          	mov    %edx,0x8(%esp)
     ad9:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     ae0:	00 
     ae1:	89 04 24             	mov    %eax,(%esp)
     ae4:	e8 ee 33 00 00       	call   3ed7 <read>
     ae9:	89 45 ec             	mov    %eax,-0x14(%ebp)
     aec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     af0:	0f 8f 71 ff ff ff    	jg     a67 <pipe1+0xf4>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
     af6:	81 7d e4 2d 14 00 00 	cmpl   $0x142d,-0x1c(%ebp)
     afd:	74 20                	je     b1f <pipe1+0x1ac>
      printf(1, "pipe1 oops 3 total %d\n", total);
     aff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     b02:	89 44 24 08          	mov    %eax,0x8(%esp)
     b06:	c7 44 24 04 b1 48 00 	movl   $0x48b1,0x4(%esp)
     b0d:	00 
     b0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b15:	e8 2d 35 00 00       	call   4047 <printf>
      exit();
     b1a:	e8 a0 33 00 00       	call   3ebf <exit>
    }
    close(fds[0]);
     b1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
     b22:	89 04 24             	mov    %eax,(%esp)
     b25:	e8 bd 33 00 00       	call   3ee7 <close>
    wait();
     b2a:	e8 98 33 00 00       	call   3ec7 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
     b2f:	c7 44 24 04 d7 48 00 	movl   $0x48d7,0x4(%esp)
     b36:	00 
     b37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b3e:	e8 04 35 00 00       	call   4047 <printf>
     b43:	eb 19                	jmp    b5e <pipe1+0x1eb>
      exit();
    }
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
     b45:	c7 44 24 04 c8 48 00 	movl   $0x48c8,0x4(%esp)
     b4c:	00 
     b4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b54:	e8 ee 34 00 00       	call   4047 <printf>
    exit();
     b59:	e8 61 33 00 00       	call   3ebf <exit>
  }
  printf(1, "pipe1 ok\n");
}
     b5e:	c9                   	leave  
     b5f:	c3                   	ret    

00000b60 <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     b60:	55                   	push   %ebp
     b61:	89 e5                	mov    %esp,%ebp
     b63:	83 ec 38             	sub    $0x38,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     b66:	c7 44 24 04 e1 48 00 	movl   $0x48e1,0x4(%esp)
     b6d:	00 
     b6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b75:	e8 cd 34 00 00       	call   4047 <printf>
  pid1 = fork();
     b7a:	e8 38 33 00 00       	call   3eb7 <fork>
     b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid1 == 0)
     b82:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     b86:	75 02                	jne    b8a <preempt+0x2a>
    for(;;)
      ;
     b88:	eb fe                	jmp    b88 <preempt+0x28>

  pid2 = fork();
     b8a:	e8 28 33 00 00       	call   3eb7 <fork>
     b8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid2 == 0)
     b92:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     b96:	75 02                	jne    b9a <preempt+0x3a>
    for(;;)
      ;
     b98:	eb fe                	jmp    b98 <preempt+0x38>

  pipe(pfds);
     b9a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b9d:	89 04 24             	mov    %eax,(%esp)
     ba0:	e8 2a 33 00 00       	call   3ecf <pipe>
  pid3 = fork();
     ba5:	e8 0d 33 00 00       	call   3eb7 <fork>
     baa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid3 == 0){
     bad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     bb1:	75 4c                	jne    bff <preempt+0x9f>
    close(pfds[0]);
     bb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     bb6:	89 04 24             	mov    %eax,(%esp)
     bb9:	e8 29 33 00 00       	call   3ee7 <close>
    if(write(pfds[1], "x", 1) != 1)
     bbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bc1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     bc8:	00 
     bc9:	c7 44 24 04 eb 48 00 	movl   $0x48eb,0x4(%esp)
     bd0:	00 
     bd1:	89 04 24             	mov    %eax,(%esp)
     bd4:	e8 06 33 00 00       	call   3edf <write>
     bd9:	83 f8 01             	cmp    $0x1,%eax
     bdc:	74 14                	je     bf2 <preempt+0x92>
      printf(1, "preempt write error");
     bde:	c7 44 24 04 ed 48 00 	movl   $0x48ed,0x4(%esp)
     be5:	00 
     be6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     bed:	e8 55 34 00 00       	call   4047 <printf>
    close(pfds[1]);
     bf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bf5:	89 04 24             	mov    %eax,(%esp)
     bf8:	e8 ea 32 00 00       	call   3ee7 <close>
    for(;;)
      ;
     bfd:	eb fe                	jmp    bfd <preempt+0x9d>
  }

  close(pfds[1]);
     bff:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c02:	89 04 24             	mov    %eax,(%esp)
     c05:	e8 dd 32 00 00       	call   3ee7 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     c0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c0d:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     c14:	00 
     c15:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     c1c:	00 
     c1d:	89 04 24             	mov    %eax,(%esp)
     c20:	e8 b2 32 00 00       	call   3ed7 <read>
     c25:	83 f8 01             	cmp    $0x1,%eax
     c28:	74 16                	je     c40 <preempt+0xe0>
    printf(1, "preempt read error");
     c2a:	c7 44 24 04 01 49 00 	movl   $0x4901,0x4(%esp)
     c31:	00 
     c32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c39:	e8 09 34 00 00       	call   4047 <printf>
     c3e:	eb 77                	jmp    cb7 <preempt+0x157>
    return;
  }
  close(pfds[0]);
     c40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c43:	89 04 24             	mov    %eax,(%esp)
     c46:	e8 9c 32 00 00       	call   3ee7 <close>
  printf(1, "kill... ");
     c4b:	c7 44 24 04 14 49 00 	movl   $0x4914,0x4(%esp)
     c52:	00 
     c53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c5a:	e8 e8 33 00 00       	call   4047 <printf>
  kill(pid1);
     c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c62:	89 04 24             	mov    %eax,(%esp)
     c65:	e8 85 32 00 00       	call   3eef <kill>
  kill(pid2);
     c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c6d:	89 04 24             	mov    %eax,(%esp)
     c70:	e8 7a 32 00 00       	call   3eef <kill>
  kill(pid3);
     c75:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c78:	89 04 24             	mov    %eax,(%esp)
     c7b:	e8 6f 32 00 00       	call   3eef <kill>
  printf(1, "wait... ");
     c80:	c7 44 24 04 1d 49 00 	movl   $0x491d,0x4(%esp)
     c87:	00 
     c88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c8f:	e8 b3 33 00 00       	call   4047 <printf>
  wait();
     c94:	e8 2e 32 00 00       	call   3ec7 <wait>
  wait();
     c99:	e8 29 32 00 00       	call   3ec7 <wait>
  wait();
     c9e:	e8 24 32 00 00       	call   3ec7 <wait>
  printf(1, "preempt ok\n");
     ca3:	c7 44 24 04 26 49 00 	movl   $0x4926,0x4(%esp)
     caa:	00 
     cab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cb2:	e8 90 33 00 00       	call   4047 <printf>
}
     cb7:	c9                   	leave  
     cb8:	c3                   	ret    

00000cb9 <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     cb9:	55                   	push   %ebp
     cba:	89 e5                	mov    %esp,%ebp
     cbc:	83 ec 28             	sub    $0x28,%esp
  int i, pid;

  for(i = 0; i < 100; i++){
     cbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     cc6:	eb 53                	jmp    d1b <exitwait+0x62>
    pid = fork();
     cc8:	e8 ea 31 00 00       	call   3eb7 <fork>
     ccd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0){
     cd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     cd4:	79 16                	jns    cec <exitwait+0x33>
      printf(1, "fork failed\n");
     cd6:	c7 44 24 04 b5 44 00 	movl   $0x44b5,0x4(%esp)
     cdd:	00 
     cde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ce5:	e8 5d 33 00 00       	call   4047 <printf>
      return;
     cea:	eb 49                	jmp    d35 <exitwait+0x7c>
    }
    if(pid){
     cec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     cf0:	74 20                	je     d12 <exitwait+0x59>
      if(wait() != pid){
     cf2:	e8 d0 31 00 00       	call   3ec7 <wait>
     cf7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     cfa:	74 1b                	je     d17 <exitwait+0x5e>
        printf(1, "wait wrong pid\n");
     cfc:	c7 44 24 04 32 49 00 	movl   $0x4932,0x4(%esp)
     d03:	00 
     d04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d0b:	e8 37 33 00 00       	call   4047 <printf>
        return;
     d10:	eb 23                	jmp    d35 <exitwait+0x7c>
      }
    } else {
      exit();
     d12:	e8 a8 31 00 00       	call   3ebf <exit>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
     d17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     d1b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     d1f:	7e a7                	jle    cc8 <exitwait+0xf>
      }
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
     d21:	c7 44 24 04 42 49 00 	movl   $0x4942,0x4(%esp)
     d28:	00 
     d29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d30:	e8 12 33 00 00       	call   4047 <printf>
}
     d35:	c9                   	leave  
     d36:	c3                   	ret    

00000d37 <mem>:

void
mem(void)
{
     d37:	55                   	push   %ebp
     d38:	89 e5                	mov    %esp,%ebp
     d3a:	83 ec 28             	sub    $0x28,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     d3d:	c7 44 24 04 4f 49 00 	movl   $0x494f,0x4(%esp)
     d44:	00 
     d45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d4c:	e8 f6 32 00 00       	call   4047 <printf>
  ppid = getpid();
     d51:	e8 e9 31 00 00       	call   3f3f <getpid>
     d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if((pid = fork()) == 0){
     d59:	e8 59 31 00 00       	call   3eb7 <fork>
     d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
     d61:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     d65:	0f 85 aa 00 00 00    	jne    e15 <mem+0xde>
    m1 = 0;
     d6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while((m2 = malloc(10001)) != 0){
     d72:	eb 0e                	jmp    d82 <mem+0x4b>
      *(char**)m2 = m1;
     d74:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d77:	8b 55 f4             	mov    -0xc(%ebp),%edx
     d7a:	89 10                	mov    %edx,(%eax)
      m1 = m2;
     d7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d7f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
     d82:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
     d89:	e8 a5 35 00 00       	call   4333 <malloc>
     d8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
     d91:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     d95:	75 dd                	jne    d74 <mem+0x3d>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     d97:	eb 19                	jmp    db2 <mem+0x7b>
      m2 = *(char**)m1;
     d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d9c:	8b 00                	mov    (%eax),%eax
     d9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      free(m1);
     da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     da4:	89 04 24             	mov    %eax,(%esp)
     da7:	e8 4e 34 00 00       	call   41fa <free>
      m1 = m2;
     dac:	8b 45 e8             	mov    -0x18(%ebp),%eax
     daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     db2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     db6:	75 e1                	jne    d99 <mem+0x62>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
     db8:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
     dbf:	e8 6f 35 00 00       	call   4333 <malloc>
     dc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(m1 == 0){
     dc7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     dcb:	75 24                	jne    df1 <mem+0xba>
      printf(1, "couldn't allocate mem?!!\n");
     dcd:	c7 44 24 04 59 49 00 	movl   $0x4959,0x4(%esp)
     dd4:	00 
     dd5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ddc:	e8 66 32 00 00       	call   4047 <printf>
      kill(ppid);
     de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     de4:	89 04 24             	mov    %eax,(%esp)
     de7:	e8 03 31 00 00       	call   3eef <kill>
      exit();
     dec:	e8 ce 30 00 00       	call   3ebf <exit>
    }
    free(m1);
     df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     df4:	89 04 24             	mov    %eax,(%esp)
     df7:	e8 fe 33 00 00       	call   41fa <free>
    printf(1, "mem ok\n");
     dfc:	c7 44 24 04 73 49 00 	movl   $0x4973,0x4(%esp)
     e03:	00 
     e04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e0b:	e8 37 32 00 00       	call   4047 <printf>
    exit();
     e10:	e8 aa 30 00 00       	call   3ebf <exit>
  } else {
    wait();
     e15:	e8 ad 30 00 00       	call   3ec7 <wait>
  }
}
     e1a:	c9                   	leave  
     e1b:	c3                   	ret    

00000e1c <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     e1c:	55                   	push   %ebp
     e1d:	89 e5                	mov    %esp,%ebp
     e1f:	81 ec 98 00 00 00    	sub    $0x98,%esp
  int fd, pid, i, n, nc, np;
  char buf[100];

  printf(1, "sharedfd test\n");
     e25:	c7 44 24 04 7b 49 00 	movl   $0x497b,0x4(%esp)
     e2c:	00 
     e2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e34:	e8 0e 32 00 00       	call   4047 <printf>
  unlink("sharedfd");
     e39:	c7 04 24 8a 49 00 00 	movl   $0x498a,(%esp)
     e40:	e8 ca 30 00 00       	call   3f0f <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     e45:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     e4c:	00 
     e4d:	c7 04 24 8a 49 00 00 	movl   $0x498a,(%esp)
     e54:	e8 a6 30 00 00       	call   3eff <open>
     e59:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     e5c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     e60:	79 19                	jns    e7b <sharedfd+0x5f>
    printf(1, "fstests: cannot open sharedfd for writing");
     e62:	c7 44 24 04 94 49 00 	movl   $0x4994,0x4(%esp)
     e69:	00 
     e6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e71:	e8 d1 31 00 00       	call   4047 <printf>
    return;
     e76:	e9 ac 01 00 00       	jmp    1027 <sharedfd+0x20b>
  }
  pid = fork();
     e7b:	e8 37 30 00 00       	call   3eb7 <fork>
     e80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     e83:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     e87:	75 07                	jne    e90 <sharedfd+0x74>
     e89:	b8 63 00 00 00       	mov    $0x63,%eax
     e8e:	eb 05                	jmp    e95 <sharedfd+0x79>
     e90:	b8 70 00 00 00       	mov    $0x70,%eax
     e95:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
     e9c:	00 
     e9d:	89 44 24 04          	mov    %eax,0x4(%esp)
     ea1:	8d 85 7c ff ff ff    	lea    -0x84(%ebp),%eax
     ea7:	89 04 24             	mov    %eax,(%esp)
     eaa:	e8 63 2e 00 00       	call   3d12 <memset>
  for(i = 0; i < 100; i++){
     eaf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     eb6:	eb 3c                	jmp    ef4 <sharedfd+0xd8>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     eb8:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
     ebf:	00 
     ec0:	8d 85 7c ff ff ff    	lea    -0x84(%ebp),%eax
     ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
     eca:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ecd:	89 04 24             	mov    %eax,(%esp)
     ed0:	e8 0a 30 00 00       	call   3edf <write>
     ed5:	83 f8 64             	cmp    $0x64,%eax
     ed8:	74 16                	je     ef0 <sharedfd+0xd4>
      printf(1, "fstests: write sharedfd failed\n");
     eda:	c7 44 24 04 c0 49 00 	movl   $0x49c0,0x4(%esp)
     ee1:	00 
     ee2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ee9:	e8 59 31 00 00       	call   4047 <printf>
      break;
     eee:	eb 0a                	jmp    efa <sharedfd+0xde>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
  memset(buf, pid==0?'c':'p', sizeof(buf));
  for(i = 0; i < 100; i++){
     ef0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     ef4:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     ef8:	7e be                	jle    eb8 <sharedfd+0x9c>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
      printf(1, "fstests: write sharedfd failed\n");
      break;
    }
  }
  if(pid == 0)
     efa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     efe:	75 05                	jne    f05 <sharedfd+0xe9>
    exit();
     f00:	e8 ba 2f 00 00       	call   3ebf <exit>
  else
    wait();
     f05:	e8 bd 2f 00 00       	call   3ec7 <wait>
  close(fd);
     f0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f0d:	89 04 24             	mov    %eax,(%esp)
     f10:	e8 d2 2f 00 00       	call   3ee7 <close>
  fd = open("sharedfd", 0);
     f15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     f1c:	00 
     f1d:	c7 04 24 8a 49 00 00 	movl   $0x498a,(%esp)
     f24:	e8 d6 2f 00 00       	call   3eff <open>
     f29:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     f2c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     f30:	79 19                	jns    f4b <sharedfd+0x12f>
    printf(1, "fstests: cannot open sharedfd for reading\n");
     f32:	c7 44 24 04 e0 49 00 	movl   $0x49e0,0x4(%esp)
     f39:	00 
     f3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f41:	e8 01 31 00 00       	call   4047 <printf>
    return;
     f46:	e9 dc 00 00 00       	jmp    1027 <sharedfd+0x20b>
  }
  nc = np = 0;
     f4b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     f52:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
     f58:	eb 41                	jmp    f9b <sharedfd+0x17f>
    for(i = 0; i < sizeof(buf); i++){
     f5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     f61:	eb 30                	jmp    f93 <sharedfd+0x177>
      if(buf[i] == 'c')
     f63:	8d 95 7c ff ff ff    	lea    -0x84(%ebp),%edx
     f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f6c:	01 d0                	add    %edx,%eax
     f6e:	0f b6 00             	movzbl (%eax),%eax
     f71:	3c 63                	cmp    $0x63,%al
     f73:	75 04                	jne    f79 <sharedfd+0x15d>
        nc++;
     f75:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(buf[i] == 'p')
     f79:	8d 95 7c ff ff ff    	lea    -0x84(%ebp),%edx
     f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f82:	01 d0                	add    %edx,%eax
     f84:	0f b6 00             	movzbl (%eax),%eax
     f87:	3c 70                	cmp    $0x70,%al
     f89:	75 04                	jne    f8f <sharedfd+0x173>
        np++;
     f8b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
     f8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f96:	83 f8 63             	cmp    $0x63,%eax
     f99:	76 c8                	jbe    f63 <sharedfd+0x147>
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
     f9b:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
     fa2:	00 
     fa3:	8d 85 7c ff ff ff    	lea    -0x84(%ebp),%eax
     fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
     fad:	8b 45 e8             	mov    -0x18(%ebp),%eax
     fb0:	89 04 24             	mov    %eax,(%esp)
     fb3:	e8 1f 2f 00 00       	call   3ed7 <read>
     fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
     fbb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     fbf:	7f 99                	jg     f5a <sharedfd+0x13e>
        nc++;
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
     fc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     fc4:	89 04 24             	mov    %eax,(%esp)
     fc7:	e8 1b 2f 00 00       	call   3ee7 <close>
  unlink("sharedfd");
     fcc:	c7 04 24 8a 49 00 00 	movl   $0x498a,(%esp)
     fd3:	e8 37 2f 00 00       	call   3f0f <unlink>
  if(nc == 10000 && np == 10000){
     fd8:	81 7d f0 10 27 00 00 	cmpl   $0x2710,-0x10(%ebp)
     fdf:	75 1f                	jne    1000 <sharedfd+0x1e4>
     fe1:	81 7d ec 10 27 00 00 	cmpl   $0x2710,-0x14(%ebp)
     fe8:	75 16                	jne    1000 <sharedfd+0x1e4>
    printf(1, "sharedfd ok\n");
     fea:	c7 44 24 04 0b 4a 00 	movl   $0x4a0b,0x4(%esp)
     ff1:	00 
     ff2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ff9:	e8 49 30 00 00       	call   4047 <printf>
     ffe:	eb 27                	jmp    1027 <sharedfd+0x20b>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
    1000:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1003:	89 44 24 0c          	mov    %eax,0xc(%esp)
    1007:	8b 45 f0             	mov    -0x10(%ebp),%eax
    100a:	89 44 24 08          	mov    %eax,0x8(%esp)
    100e:	c7 44 24 04 18 4a 00 	movl   $0x4a18,0x4(%esp)
    1015:	00 
    1016:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    101d:	e8 25 30 00 00       	call   4047 <printf>
    exit();
    1022:	e8 98 2e 00 00       	call   3ebf <exit>
  }
}
    1027:	c9                   	leave  
    1028:	c3                   	ret    

00001029 <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
    1029:	55                   	push   %ebp
    102a:	89 e5                	mov    %esp,%ebp
    102c:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
    102f:	c7 45 c8 2d 4a 00 00 	movl   $0x4a2d,-0x38(%ebp)
    1036:	c7 45 cc 30 4a 00 00 	movl   $0x4a30,-0x34(%ebp)
    103d:	c7 45 d0 33 4a 00 00 	movl   $0x4a33,-0x30(%ebp)
    1044:	c7 45 d4 36 4a 00 00 	movl   $0x4a36,-0x2c(%ebp)
  char *fname;

  printf(1, "fourfiles test\n");
    104b:	c7 44 24 04 39 4a 00 	movl   $0x4a39,0x4(%esp)
    1052:	00 
    1053:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    105a:	e8 e8 2f 00 00       	call   4047 <printf>

  for(pi = 0; pi < 4; pi++){
    105f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    1066:	e9 fc 00 00 00       	jmp    1167 <fourfiles+0x13e>
    fname = names[pi];
    106b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    106e:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    1072:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    unlink(fname);
    1075:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1078:	89 04 24             	mov    %eax,(%esp)
    107b:	e8 8f 2e 00 00       	call   3f0f <unlink>

    pid = fork();
    1080:	e8 32 2e 00 00       	call   3eb7 <fork>
    1085:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(pid < 0){
    1088:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    108c:	79 19                	jns    10a7 <fourfiles+0x7e>
      printf(1, "fork failed\n");
    108e:	c7 44 24 04 b5 44 00 	movl   $0x44b5,0x4(%esp)
    1095:	00 
    1096:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    109d:	e8 a5 2f 00 00       	call   4047 <printf>
      exit();
    10a2:	e8 18 2e 00 00       	call   3ebf <exit>
    }

    if(pid == 0){
    10a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    10ab:	0f 85 b2 00 00 00    	jne    1163 <fourfiles+0x13a>
      fd = open(fname, O_CREATE | O_RDWR);
    10b1:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    10b8:	00 
    10b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    10bc:	89 04 24             	mov    %eax,(%esp)
    10bf:	e8 3b 2e 00 00       	call   3eff <open>
    10c4:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(fd < 0){
    10c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
    10cb:	79 19                	jns    10e6 <fourfiles+0xbd>
        printf(1, "create failed\n");
    10cd:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
    10d4:	00 
    10d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10dc:	e8 66 2f 00 00       	call   4047 <printf>
        exit();
    10e1:	e8 d9 2d 00 00       	call   3ebf <exit>
      }
      
      memset(buf, '0'+pi, 512);
    10e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10e9:	83 c0 30             	add    $0x30,%eax
    10ec:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    10f3:	00 
    10f4:	89 44 24 04          	mov    %eax,0x4(%esp)
    10f8:	c7 04 24 c0 8a 00 00 	movl   $0x8ac0,(%esp)
    10ff:	e8 0e 2c 00 00       	call   3d12 <memset>
      for(i = 0; i < 12; i++){
    1104:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    110b:	eb 4b                	jmp    1158 <fourfiles+0x12f>
        if((n = write(fd, buf, 500)) != 500){
    110d:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
    1114:	00 
    1115:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    111c:	00 
    111d:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1120:	89 04 24             	mov    %eax,(%esp)
    1123:	e8 b7 2d 00 00       	call   3edf <write>
    1128:	89 45 d8             	mov    %eax,-0x28(%ebp)
    112b:	81 7d d8 f4 01 00 00 	cmpl   $0x1f4,-0x28(%ebp)
    1132:	74 20                	je     1154 <fourfiles+0x12b>
          printf(1, "write failed %d\n", n);
    1134:	8b 45 d8             	mov    -0x28(%ebp),%eax
    1137:	89 44 24 08          	mov    %eax,0x8(%esp)
    113b:	c7 44 24 04 58 4a 00 	movl   $0x4a58,0x4(%esp)
    1142:	00 
    1143:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    114a:	e8 f8 2e 00 00       	call   4047 <printf>
          exit();
    114f:	e8 6b 2d 00 00       	call   3ebf <exit>
        printf(1, "create failed\n");
        exit();
      }
      
      memset(buf, '0'+pi, 512);
      for(i = 0; i < 12; i++){
    1154:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1158:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
    115c:	7e af                	jle    110d <fourfiles+0xe4>
        if((n = write(fd, buf, 500)) != 500){
          printf(1, "write failed %d\n", n);
          exit();
        }
      }
      exit();
    115e:	e8 5c 2d 00 00       	call   3ebf <exit>
  char *names[] = { "f0", "f1", "f2", "f3" };
  char *fname;

  printf(1, "fourfiles test\n");

  for(pi = 0; pi < 4; pi++){
    1163:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    1167:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    116b:	0f 8e fa fe ff ff    	jle    106b <fourfiles+0x42>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    1171:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    1178:	eb 09                	jmp    1183 <fourfiles+0x15a>
    wait();
    117a:	e8 48 2d 00 00       	call   3ec7 <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    117f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    1183:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    1187:	7e f1                	jle    117a <fourfiles+0x151>
    wait();
  }

  for(i = 0; i < 2; i++){
    1189:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1190:	e9 dc 00 00 00       	jmp    1271 <fourfiles+0x248>
    fname = names[i];
    1195:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1198:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    119c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    fd = open(fname, 0);
    119f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    11a6:	00 
    11a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11aa:	89 04 24             	mov    %eax,(%esp)
    11ad:	e8 4d 2d 00 00       	call   3eff <open>
    11b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    total = 0;
    11b5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    11bc:	eb 4c                	jmp    120a <fourfiles+0x1e1>
      for(j = 0; j < n; j++){
    11be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    11c5:	eb 35                	jmp    11fc <fourfiles+0x1d3>
        if(buf[j] != '0'+i){
    11c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11ca:	05 c0 8a 00 00       	add    $0x8ac0,%eax
    11cf:	0f b6 00             	movzbl (%eax),%eax
    11d2:	0f be c0             	movsbl %al,%eax
    11d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11d8:	83 c2 30             	add    $0x30,%edx
    11db:	39 d0                	cmp    %edx,%eax
    11dd:	74 19                	je     11f8 <fourfiles+0x1cf>
          printf(1, "wrong char\n");
    11df:	c7 44 24 04 69 4a 00 	movl   $0x4a69,0x4(%esp)
    11e6:	00 
    11e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11ee:	e8 54 2e 00 00       	call   4047 <printf>
          exit();
    11f3:	e8 c7 2c 00 00       	call   3ebf <exit>
  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
    11f8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    11fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11ff:	3b 45 d8             	cmp    -0x28(%ebp),%eax
    1202:	7c c3                	jl     11c7 <fourfiles+0x19e>
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
          exit();
        }
      }
      total += n;
    1204:	8b 45 d8             	mov    -0x28(%ebp),%eax
    1207:	01 45 ec             	add    %eax,-0x14(%ebp)

  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
    120a:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1211:	00 
    1212:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    1219:	00 
    121a:	8b 45 dc             	mov    -0x24(%ebp),%eax
    121d:	89 04 24             	mov    %eax,(%esp)
    1220:	e8 b2 2c 00 00       	call   3ed7 <read>
    1225:	89 45 d8             	mov    %eax,-0x28(%ebp)
    1228:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
    122c:	7f 90                	jg     11be <fourfiles+0x195>
          exit();
        }
      }
      total += n;
    }
    close(fd);
    122e:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1231:	89 04 24             	mov    %eax,(%esp)
    1234:	e8 ae 2c 00 00       	call   3ee7 <close>
    if(total != 12*500){
    1239:	81 7d ec 70 17 00 00 	cmpl   $0x1770,-0x14(%ebp)
    1240:	74 20                	je     1262 <fourfiles+0x239>
      printf(1, "wrong length %d\n", total);
    1242:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1245:	89 44 24 08          	mov    %eax,0x8(%esp)
    1249:	c7 44 24 04 75 4a 00 	movl   $0x4a75,0x4(%esp)
    1250:	00 
    1251:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1258:	e8 ea 2d 00 00       	call   4047 <printf>
      exit();
    125d:	e8 5d 2c 00 00       	call   3ebf <exit>
    }
    unlink(fname);
    1262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1265:	89 04 24             	mov    %eax,(%esp)
    1268:	e8 a2 2c 00 00       	call   3f0f <unlink>

  for(pi = 0; pi < 4; pi++){
    wait();
  }

  for(i = 0; i < 2; i++){
    126d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1271:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
    1275:	0f 8e 1a ff ff ff    	jle    1195 <fourfiles+0x16c>
      exit();
    }
    unlink(fname);
  }

  printf(1, "fourfiles ok\n");
    127b:	c7 44 24 04 86 4a 00 	movl   $0x4a86,0x4(%esp)
    1282:	00 
    1283:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    128a:	e8 b8 2d 00 00       	call   4047 <printf>
}
    128f:	c9                   	leave  
    1290:	c3                   	ret    

00001291 <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    1291:	55                   	push   %ebp
    1292:	89 e5                	mov    %esp,%ebp
    1294:	83 ec 58             	sub    $0x58,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];
  int PS = 2;
    1297:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)

  printf(1, "createdelete test\n");
    129e:	c7 44 24 04 94 4a 00 	movl   $0x4a94,0x4(%esp)
    12a5:	00 
    12a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    12ad:	e8 95 2d 00 00       	call   4047 <printf>

  for(pi = 0; pi < PS; pi++){
    12b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    12b9:	e9 e0 00 00 00       	jmp    139e <createdelete+0x10d>
    pid = fork();
    12be:	e8 f4 2b 00 00       	call   3eb7 <fork>
    12c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pid < 0){
    12c6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    12ca:	79 19                	jns    12e5 <createdelete+0x54>
      printf(1, "fork failed\n");
    12cc:	c7 44 24 04 b5 44 00 	movl   $0x44b5,0x4(%esp)
    12d3:	00 
    12d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    12db:	e8 67 2d 00 00       	call   4047 <printf>
      exit();
    12e0:	e8 da 2b 00 00       	call   3ebf <exit>
    }

    if(pid == 0){
    12e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    12e9:	0f 85 ab 00 00 00    	jne    139a <createdelete+0x109>
      name[0] = 'p' + pi;
    12ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12f2:	83 c0 70             	add    $0x70,%eax
    12f5:	88 45 c4             	mov    %al,-0x3c(%ebp)
      name[2] = '\0';
    12f8:	c6 45 c6 00          	movb   $0x0,-0x3a(%ebp)
      for(i = 0; i < N; i++){
    12fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1303:	e9 83 00 00 00       	jmp    138b <createdelete+0xfa>
        name[1] = '0' + i;
    1308:	8b 45 f4             	mov    -0xc(%ebp),%eax
    130b:	83 c0 30             	add    $0x30,%eax
    130e:	88 45 c5             	mov    %al,-0x3b(%ebp)
//        printf(1, "creating %s \n", name);
        fd = open(name, O_CREATE | O_RDWR);
    1311:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1318:	00 
    1319:	8d 45 c4             	lea    -0x3c(%ebp),%eax
    131c:	89 04 24             	mov    %eax,(%esp)
    131f:	e8 db 2b 00 00       	call   3eff <open>
    1324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(fd < 0){
    1327:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    132b:	79 19                	jns    1346 <createdelete+0xb5>
          printf(1, "create failed\n");
    132d:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
    1334:	00 
    1335:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    133c:	e8 06 2d 00 00       	call   4047 <printf>
          exit();
    1341:	e8 79 2b 00 00       	call   3ebf <exit>
        }
        close(fd);
    1346:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1349:	89 04 24             	mov    %eax,(%esp)
    134c:	e8 96 2b 00 00       	call   3ee7 <close>
        if(i > 0 && (i % 2 ) == 0){
    1351:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1355:	7e 30                	jle    1387 <createdelete+0xf6>
    1357:	8b 45 f4             	mov    -0xc(%ebp),%eax
    135a:	83 e0 01             	and    $0x1,%eax
    135d:	85 c0                	test   %eax,%eax
    135f:	75 26                	jne    1387 <createdelete+0xf6>
          name[1] = '0' + (i / 2);
    1361:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1364:	89 c2                	mov    %eax,%edx
    1366:	c1 ea 1f             	shr    $0x1f,%edx
    1369:	01 d0                	add    %edx,%eax
    136b:	d1 f8                	sar    %eax
    136d:	83 c0 30             	add    $0x30,%eax
    1370:	88 45 c5             	mov    %al,-0x3b(%ebp)
          if(unlink(name) < 0){
    1373:	8d 45 c4             	lea    -0x3c(%ebp),%eax
    1376:	89 04 24             	mov    %eax,(%esp)
    1379:	e8 91 2b 00 00       	call   3f0f <unlink>
    137e:	85 c0                	test   %eax,%eax
    1380:	79 05                	jns    1387 <createdelete+0xf6>
//            printf(1, "unlink failed on %s\n", name);
            exit();
    1382:	e8 38 2b 00 00       	call   3ebf <exit>
    }

    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
      for(i = 0; i < N; i++){
    1387:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    138b:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    138f:	0f 8e 73 ff ff ff    	jle    1308 <createdelete+0x77>
//            printf(1, "unlink failed on %s\n", name);
            exit();
          }
        }
      }
      exit();
    1395:	e8 25 2b 00 00       	call   3ebf <exit>
  char name[32];
  int PS = 2;

  printf(1, "createdelete test\n");

  for(pi = 0; pi < PS; pi++){
    139a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13a1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    13a4:	0f 8c 14 ff ff ff    	jl     12be <createdelete+0x2d>
      }
      exit();
    }
  }

  for(pi = 0; pi < PS; pi++){
    13aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    13b1:	eb 09                	jmp    13bc <createdelete+0x12b>
    wait();
    13b3:	e8 0f 2b 00 00       	call   3ec7 <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < PS; pi++){
    13b8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    13bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13bf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    13c2:	7c ef                	jl     13b3 <createdelete+0x122>
    wait();
  }
  name[0] = name[1] = name[2] = 0;
    13c4:	c6 45 c6 00          	movb   $0x0,-0x3a(%ebp)
    13c8:	0f b6 45 c6          	movzbl -0x3a(%ebp),%eax
    13cc:	88 45 c5             	mov    %al,-0x3b(%ebp)
    13cf:	0f b6 45 c5          	movzbl -0x3b(%ebp),%eax
    13d3:	88 45 c4             	mov    %al,-0x3c(%ebp)
  for(i = 0; i < N; i++){
    13d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    13dd:	e9 bd 00 00 00       	jmp    149f <createdelete+0x20e>
    for(pi = 0; pi < PS; pi++){
    13e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    13e9:	e9 a1 00 00 00       	jmp    148f <createdelete+0x1fe>
      name[0] = 'p' + pi;
    13ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13f1:	83 c0 70             	add    $0x70,%eax
    13f4:	88 45 c4             	mov    %al,-0x3c(%ebp)
      name[1] = '0' + i;
    13f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13fa:	83 c0 30             	add    $0x30,%eax
    13fd:	88 45 c5             	mov    %al,-0x3b(%ebp)
      fd = open(name, 0);
    1400:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1407:	00 
    1408:	8d 45 c4             	lea    -0x3c(%ebp),%eax
    140b:	89 04 24             	mov    %eax,(%esp)
    140e:	e8 ec 2a 00 00       	call   3eff <open>
    1413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if((i == 0 || i >= N/2) && fd < 0){
    1416:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    141a:	74 06                	je     1422 <createdelete+0x191>
    141c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    1420:	7e 26                	jle    1448 <createdelete+0x1b7>
    1422:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    1426:	79 20                	jns    1448 <createdelete+0x1b7>
        printf(1, "oops createdelete %s didn't exist\n", name);
    1428:	8d 45 c4             	lea    -0x3c(%ebp),%eax
    142b:	89 44 24 08          	mov    %eax,0x8(%esp)
    142f:	c7 44 24 04 a8 4a 00 	movl   $0x4aa8,0x4(%esp)
    1436:	00 
    1437:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    143e:	e8 04 2c 00 00       	call   4047 <printf>
        exit();
    1443:	e8 77 2a 00 00       	call   3ebf <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1448:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    144c:	7e 2c                	jle    147a <createdelete+0x1e9>
    144e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    1452:	7f 26                	jg     147a <createdelete+0x1e9>
    1454:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    1458:	78 20                	js     147a <createdelete+0x1e9>
        printf(1, "oops createdelete %s did exist\n", name);
    145a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
    145d:	89 44 24 08          	mov    %eax,0x8(%esp)
    1461:	c7 44 24 04 cc 4a 00 	movl   $0x4acc,0x4(%esp)
    1468:	00 
    1469:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1470:	e8 d2 2b 00 00       	call   4047 <printf>
        exit();
    1475:	e8 45 2a 00 00       	call   3ebf <exit>
      }
      if(fd >= 0)
    147a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    147e:	78 0b                	js     148b <createdelete+0x1fa>
        close(fd);
    1480:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1483:	89 04 24             	mov    %eax,(%esp)
    1486:	e8 5c 2a 00 00       	call   3ee7 <close>
  for(pi = 0; pi < PS; pi++){
    wait();
  }
  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    for(pi = 0; pi < PS; pi++){
    148b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1492:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1495:	0f 8c 53 ff ff ff    	jl     13ee <createdelete+0x15d>

  for(pi = 0; pi < PS; pi++){
    wait();
  }
  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    149b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    149f:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    14a3:	0f 8e 39 ff ff ff    	jle    13e2 <createdelete+0x151>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    14a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    14b0:	eb 36                	jmp    14e8 <createdelete+0x257>
    for(pi = 0; pi < PS; pi++){
    14b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    14b9:	eb 21                	jmp    14dc <createdelete+0x24b>
      name[0] = 'p' + i;
    14bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14be:	83 c0 70             	add    $0x70,%eax
    14c1:	88 45 c4             	mov    %al,-0x3c(%ebp)
      name[1] = '0' + i;
    14c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14c7:	83 c0 30             	add    $0x30,%eax
    14ca:	88 45 c5             	mov    %al,-0x3b(%ebp)
      unlink(name);
    14cd:	8d 45 c4             	lea    -0x3c(%ebp),%eax
    14d0:	89 04 24             	mov    %eax,(%esp)
    14d3:	e8 37 2a 00 00       	call   3f0f <unlink>
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    for(pi = 0; pi < PS; pi++){
    14d8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    14dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    14e2:	7c d7                	jl     14bb <createdelete+0x22a>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    14e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    14e8:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    14ec:	7e c4                	jle    14b2 <createdelete+0x221>
      name[1] = '0' + i;
      unlink(name);
    }
  }

  printf(1, "createdelete ok\n");
    14ee:	c7 44 24 04 ec 4a 00 	movl   $0x4aec,0x4(%esp)
    14f5:	00 
    14f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14fd:	e8 45 2b 00 00       	call   4047 <printf>
}
    1502:	c9                   	leave  
    1503:	c3                   	ret    

00001504 <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    1504:	55                   	push   %ebp
    1505:	89 e5                	mov    %esp,%ebp
    1507:	83 ec 28             	sub    $0x28,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    150a:	c7 44 24 04 fd 4a 00 	movl   $0x4afd,0x4(%esp)
    1511:	00 
    1512:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1519:	e8 29 2b 00 00       	call   4047 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    151e:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1525:	00 
    1526:	c7 04 24 0e 4b 00 00 	movl   $0x4b0e,(%esp)
    152d:	e8 cd 29 00 00       	call   3eff <open>
    1532:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1535:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1539:	79 19                	jns    1554 <unlinkread+0x50>
    printf(1, "create unlinkread failed\n");
    153b:	c7 44 24 04 19 4b 00 	movl   $0x4b19,0x4(%esp)
    1542:	00 
    1543:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    154a:	e8 f8 2a 00 00       	call   4047 <printf>
    exit();
    154f:	e8 6b 29 00 00       	call   3ebf <exit>
  }
  write(fd, "hello", 5);
    1554:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    155b:	00 
    155c:	c7 44 24 04 33 4b 00 	movl   $0x4b33,0x4(%esp)
    1563:	00 
    1564:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1567:	89 04 24             	mov    %eax,(%esp)
    156a:	e8 70 29 00 00       	call   3edf <write>
  close(fd);
    156f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1572:	89 04 24             	mov    %eax,(%esp)
    1575:	e8 6d 29 00 00       	call   3ee7 <close>

  fd = open("unlinkread", O_RDWR);
    157a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1581:	00 
    1582:	c7 04 24 0e 4b 00 00 	movl   $0x4b0e,(%esp)
    1589:	e8 71 29 00 00       	call   3eff <open>
    158e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1591:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1595:	79 19                	jns    15b0 <unlinkread+0xac>
    printf(1, "open unlinkread failed\n");
    1597:	c7 44 24 04 39 4b 00 	movl   $0x4b39,0x4(%esp)
    159e:	00 
    159f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15a6:	e8 9c 2a 00 00       	call   4047 <printf>
    exit();
    15ab:	e8 0f 29 00 00       	call   3ebf <exit>
  }
  if(unlink("unlinkread") != 0){
    15b0:	c7 04 24 0e 4b 00 00 	movl   $0x4b0e,(%esp)
    15b7:	e8 53 29 00 00       	call   3f0f <unlink>
    15bc:	85 c0                	test   %eax,%eax
    15be:	74 19                	je     15d9 <unlinkread+0xd5>
    printf(1, "unlink unlinkread failed\n");
    15c0:	c7 44 24 04 51 4b 00 	movl   $0x4b51,0x4(%esp)
    15c7:	00 
    15c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15cf:	e8 73 2a 00 00       	call   4047 <printf>
    exit();
    15d4:	e8 e6 28 00 00       	call   3ebf <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    15d9:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    15e0:	00 
    15e1:	c7 04 24 0e 4b 00 00 	movl   $0x4b0e,(%esp)
    15e8:	e8 12 29 00 00       	call   3eff <open>
    15ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  write(fd1, "yyy", 3);
    15f0:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    15f7:	00 
    15f8:	c7 44 24 04 6b 4b 00 	movl   $0x4b6b,0x4(%esp)
    15ff:	00 
    1600:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1603:	89 04 24             	mov    %eax,(%esp)
    1606:	e8 d4 28 00 00       	call   3edf <write>
  close(fd1);
    160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    160e:	89 04 24             	mov    %eax,(%esp)
    1611:	e8 d1 28 00 00       	call   3ee7 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    1616:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    161d:	00 
    161e:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    1625:	00 
    1626:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1629:	89 04 24             	mov    %eax,(%esp)
    162c:	e8 a6 28 00 00       	call   3ed7 <read>
    1631:	83 f8 05             	cmp    $0x5,%eax
    1634:	74 19                	je     164f <unlinkread+0x14b>
    printf(1, "unlinkread read failed");
    1636:	c7 44 24 04 6f 4b 00 	movl   $0x4b6f,0x4(%esp)
    163d:	00 
    163e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1645:	e8 fd 29 00 00       	call   4047 <printf>
    exit();
    164a:	e8 70 28 00 00       	call   3ebf <exit>
  }
  if(buf[0] != 'h'){
    164f:	0f b6 05 c0 8a 00 00 	movzbl 0x8ac0,%eax
    1656:	3c 68                	cmp    $0x68,%al
    1658:	74 19                	je     1673 <unlinkread+0x16f>
    printf(1, "unlinkread wrong data\n");
    165a:	c7 44 24 04 86 4b 00 	movl   $0x4b86,0x4(%esp)
    1661:	00 
    1662:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1669:	e8 d9 29 00 00       	call   4047 <printf>
    exit();
    166e:	e8 4c 28 00 00       	call   3ebf <exit>
  }
  if(write(fd, buf, 10) != 10){
    1673:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    167a:	00 
    167b:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    1682:	00 
    1683:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1686:	89 04 24             	mov    %eax,(%esp)
    1689:	e8 51 28 00 00       	call   3edf <write>
    168e:	83 f8 0a             	cmp    $0xa,%eax
    1691:	74 19                	je     16ac <unlinkread+0x1a8>
    printf(1, "unlinkread write failed\n");
    1693:	c7 44 24 04 9d 4b 00 	movl   $0x4b9d,0x4(%esp)
    169a:	00 
    169b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16a2:	e8 a0 29 00 00       	call   4047 <printf>
    exit();
    16a7:	e8 13 28 00 00       	call   3ebf <exit>
  }
  close(fd);
    16ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16af:	89 04 24             	mov    %eax,(%esp)
    16b2:	e8 30 28 00 00       	call   3ee7 <close>
  unlink("unlinkread");
    16b7:	c7 04 24 0e 4b 00 00 	movl   $0x4b0e,(%esp)
    16be:	e8 4c 28 00 00       	call   3f0f <unlink>
  printf(1, "unlinkread ok\n");
    16c3:	c7 44 24 04 b6 4b 00 	movl   $0x4bb6,0x4(%esp)
    16ca:	00 
    16cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16d2:	e8 70 29 00 00       	call   4047 <printf>
}
    16d7:	c9                   	leave  
    16d8:	c3                   	ret    

000016d9 <linktest>:

void
linktest(void)
{
    16d9:	55                   	push   %ebp
    16da:	89 e5                	mov    %esp,%ebp
    16dc:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "linktest\n");
    16df:	c7 44 24 04 c5 4b 00 	movl   $0x4bc5,0x4(%esp)
    16e6:	00 
    16e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16ee:	e8 54 29 00 00       	call   4047 <printf>

  unlink("lf1");
    16f3:	c7 04 24 cf 4b 00 00 	movl   $0x4bcf,(%esp)
    16fa:	e8 10 28 00 00       	call   3f0f <unlink>
  unlink("lf2");
    16ff:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    1706:	e8 04 28 00 00       	call   3f0f <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    170b:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1712:	00 
    1713:	c7 04 24 cf 4b 00 00 	movl   $0x4bcf,(%esp)
    171a:	e8 e0 27 00 00       	call   3eff <open>
    171f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1722:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1726:	79 19                	jns    1741 <linktest+0x68>
    printf(1, "create lf1 failed\n");
    1728:	c7 44 24 04 d7 4b 00 	movl   $0x4bd7,0x4(%esp)
    172f:	00 
    1730:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1737:	e8 0b 29 00 00       	call   4047 <printf>
    exit();
    173c:	e8 7e 27 00 00       	call   3ebf <exit>
  }
  if(write(fd, "hello", 5) != 5){
    1741:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1748:	00 
    1749:	c7 44 24 04 33 4b 00 	movl   $0x4b33,0x4(%esp)
    1750:	00 
    1751:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1754:	89 04 24             	mov    %eax,(%esp)
    1757:	e8 83 27 00 00       	call   3edf <write>
    175c:	83 f8 05             	cmp    $0x5,%eax
    175f:	74 19                	je     177a <linktest+0xa1>
    printf(1, "write lf1 failed\n");
    1761:	c7 44 24 04 ea 4b 00 	movl   $0x4bea,0x4(%esp)
    1768:	00 
    1769:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1770:	e8 d2 28 00 00       	call   4047 <printf>
    exit();
    1775:	e8 45 27 00 00       	call   3ebf <exit>
  }
  close(fd);
    177a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177d:	89 04 24             	mov    %eax,(%esp)
    1780:	e8 62 27 00 00       	call   3ee7 <close>

  if(link("lf1", "lf2") < 0){
    1785:	c7 44 24 04 d3 4b 00 	movl   $0x4bd3,0x4(%esp)
    178c:	00 
    178d:	c7 04 24 cf 4b 00 00 	movl   $0x4bcf,(%esp)
    1794:	e8 86 27 00 00       	call   3f1f <link>
    1799:	85 c0                	test   %eax,%eax
    179b:	79 19                	jns    17b6 <linktest+0xdd>
    printf(1, "link lf1 lf2 failed\n");
    179d:	c7 44 24 04 fc 4b 00 	movl   $0x4bfc,0x4(%esp)
    17a4:	00 
    17a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17ac:	e8 96 28 00 00       	call   4047 <printf>
    exit();
    17b1:	e8 09 27 00 00       	call   3ebf <exit>
  }
  unlink("lf1");
    17b6:	c7 04 24 cf 4b 00 00 	movl   $0x4bcf,(%esp)
    17bd:	e8 4d 27 00 00       	call   3f0f <unlink>

  if(open("lf1", 0) >= 0){
    17c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    17c9:	00 
    17ca:	c7 04 24 cf 4b 00 00 	movl   $0x4bcf,(%esp)
    17d1:	e8 29 27 00 00       	call   3eff <open>
    17d6:	85 c0                	test   %eax,%eax
    17d8:	78 19                	js     17f3 <linktest+0x11a>
    printf(1, "unlinked lf1 but it is still there!\n");
    17da:	c7 44 24 04 14 4c 00 	movl   $0x4c14,0x4(%esp)
    17e1:	00 
    17e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17e9:	e8 59 28 00 00       	call   4047 <printf>
    exit();
    17ee:	e8 cc 26 00 00       	call   3ebf <exit>
  }

  fd = open("lf2", 0);
    17f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    17fa:	00 
    17fb:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    1802:	e8 f8 26 00 00       	call   3eff <open>
    1807:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    180a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    180e:	79 19                	jns    1829 <linktest+0x150>
    printf(1, "open lf2 failed\n");
    1810:	c7 44 24 04 39 4c 00 	movl   $0x4c39,0x4(%esp)
    1817:	00 
    1818:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    181f:	e8 23 28 00 00       	call   4047 <printf>
    exit();
    1824:	e8 96 26 00 00       	call   3ebf <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    1829:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1830:	00 
    1831:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    1838:	00 
    1839:	8b 45 f4             	mov    -0xc(%ebp),%eax
    183c:	89 04 24             	mov    %eax,(%esp)
    183f:	e8 93 26 00 00       	call   3ed7 <read>
    1844:	83 f8 05             	cmp    $0x5,%eax
    1847:	74 19                	je     1862 <linktest+0x189>
    printf(1, "read lf2 failed\n");
    1849:	c7 44 24 04 4a 4c 00 	movl   $0x4c4a,0x4(%esp)
    1850:	00 
    1851:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1858:	e8 ea 27 00 00       	call   4047 <printf>
    exit();
    185d:	e8 5d 26 00 00       	call   3ebf <exit>
  }
  close(fd);
    1862:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1865:	89 04 24             	mov    %eax,(%esp)
    1868:	e8 7a 26 00 00       	call   3ee7 <close>

  if(link("lf2", "lf2") >= 0){
    186d:	c7 44 24 04 d3 4b 00 	movl   $0x4bd3,0x4(%esp)
    1874:	00 
    1875:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    187c:	e8 9e 26 00 00       	call   3f1f <link>
    1881:	85 c0                	test   %eax,%eax
    1883:	78 19                	js     189e <linktest+0x1c5>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    1885:	c7 44 24 04 5b 4c 00 	movl   $0x4c5b,0x4(%esp)
    188c:	00 
    188d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1894:	e8 ae 27 00 00       	call   4047 <printf>
    exit();
    1899:	e8 21 26 00 00       	call   3ebf <exit>
  }

  unlink("lf2");
    189e:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    18a5:	e8 65 26 00 00       	call   3f0f <unlink>
  if(link("lf2", "lf1") >= 0){
    18aa:	c7 44 24 04 cf 4b 00 	movl   $0x4bcf,0x4(%esp)
    18b1:	00 
    18b2:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    18b9:	e8 61 26 00 00       	call   3f1f <link>
    18be:	85 c0                	test   %eax,%eax
    18c0:	78 19                	js     18db <linktest+0x202>
    printf(1, "link non-existant succeeded! oops\n");
    18c2:	c7 44 24 04 7c 4c 00 	movl   $0x4c7c,0x4(%esp)
    18c9:	00 
    18ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18d1:	e8 71 27 00 00       	call   4047 <printf>
    exit();
    18d6:	e8 e4 25 00 00       	call   3ebf <exit>
  }

  if(link(".", "lf1") >= 0){
    18db:	c7 44 24 04 cf 4b 00 	movl   $0x4bcf,0x4(%esp)
    18e2:	00 
    18e3:	c7 04 24 9f 4c 00 00 	movl   $0x4c9f,(%esp)
    18ea:	e8 30 26 00 00       	call   3f1f <link>
    18ef:	85 c0                	test   %eax,%eax
    18f1:	78 19                	js     190c <linktest+0x233>
    printf(1, "link . lf1 succeeded! oops\n");
    18f3:	c7 44 24 04 a1 4c 00 	movl   $0x4ca1,0x4(%esp)
    18fa:	00 
    18fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1902:	e8 40 27 00 00       	call   4047 <printf>
    exit();
    1907:	e8 b3 25 00 00       	call   3ebf <exit>
  }

  printf(1, "linktest ok\n");
    190c:	c7 44 24 04 bd 4c 00 	movl   $0x4cbd,0x4(%esp)
    1913:	00 
    1914:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    191b:	e8 27 27 00 00       	call   4047 <printf>
}
    1920:	c9                   	leave  
    1921:	c3                   	ret    

00001922 <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    1922:	55                   	push   %ebp
    1923:	89 e5                	mov    %esp,%ebp
    1925:	83 ec 68             	sub    $0x68,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    1928:	c7 44 24 04 ca 4c 00 	movl   $0x4cca,0x4(%esp)
    192f:	00 
    1930:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1937:	e8 0b 27 00 00       	call   4047 <printf>
  file[0] = 'C';
    193c:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    1940:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    1944:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    194b:	e9 f7 00 00 00       	jmp    1a47 <concreate+0x125>
    file[1] = '0' + i;
    1950:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1953:	83 c0 30             	add    $0x30,%eax
    1956:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    1959:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    195c:	89 04 24             	mov    %eax,(%esp)
    195f:	e8 ab 25 00 00       	call   3f0f <unlink>
    pid = fork();
    1964:	e8 4e 25 00 00       	call   3eb7 <fork>
    1969:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid && (i % 3) == 1){
    196c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1970:	74 3a                	je     19ac <concreate+0x8a>
    1972:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1975:	ba 56 55 55 55       	mov    $0x55555556,%edx
    197a:	89 c8                	mov    %ecx,%eax
    197c:	f7 ea                	imul   %edx
    197e:	89 c8                	mov    %ecx,%eax
    1980:	c1 f8 1f             	sar    $0x1f,%eax
    1983:	29 c2                	sub    %eax,%edx
    1985:	89 d0                	mov    %edx,%eax
    1987:	01 c0                	add    %eax,%eax
    1989:	01 d0                	add    %edx,%eax
    198b:	29 c1                	sub    %eax,%ecx
    198d:	89 ca                	mov    %ecx,%edx
    198f:	83 fa 01             	cmp    $0x1,%edx
    1992:	75 18                	jne    19ac <concreate+0x8a>
      link("C0", file);
    1994:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1997:	89 44 24 04          	mov    %eax,0x4(%esp)
    199b:	c7 04 24 da 4c 00 00 	movl   $0x4cda,(%esp)
    19a2:	e8 78 25 00 00       	call   3f1f <link>
    19a7:	e9 87 00 00 00       	jmp    1a33 <concreate+0x111>
    } else if(pid == 0 && (i % 5) == 1){
    19ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    19b0:	75 3a                	jne    19ec <concreate+0xca>
    19b2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    19b5:	ba 67 66 66 66       	mov    $0x66666667,%edx
    19ba:	89 c8                	mov    %ecx,%eax
    19bc:	f7 ea                	imul   %edx
    19be:	d1 fa                	sar    %edx
    19c0:	89 c8                	mov    %ecx,%eax
    19c2:	c1 f8 1f             	sar    $0x1f,%eax
    19c5:	29 c2                	sub    %eax,%edx
    19c7:	89 d0                	mov    %edx,%eax
    19c9:	c1 e0 02             	shl    $0x2,%eax
    19cc:	01 d0                	add    %edx,%eax
    19ce:	29 c1                	sub    %eax,%ecx
    19d0:	89 ca                	mov    %ecx,%edx
    19d2:	83 fa 01             	cmp    $0x1,%edx
    19d5:	75 15                	jne    19ec <concreate+0xca>
      link("C0", file);
    19d7:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19da:	89 44 24 04          	mov    %eax,0x4(%esp)
    19de:	c7 04 24 da 4c 00 00 	movl   $0x4cda,(%esp)
    19e5:	e8 35 25 00 00       	call   3f1f <link>
    19ea:	eb 47                	jmp    1a33 <concreate+0x111>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    19ec:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    19f3:	00 
    19f4:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19f7:	89 04 24             	mov    %eax,(%esp)
    19fa:	e8 00 25 00 00       	call   3eff <open>
    19ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(fd < 0){
    1a02:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1a06:	79 20                	jns    1a28 <concreate+0x106>
        printf(1, "concreate create %s failed\n", file);
    1a08:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
    1a0f:	c7 44 24 04 dd 4c 00 	movl   $0x4cdd,0x4(%esp)
    1a16:	00 
    1a17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a1e:	e8 24 26 00 00       	call   4047 <printf>
        exit();
    1a23:	e8 97 24 00 00       	call   3ebf <exit>
      }
      close(fd);
    1a28:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1a2b:	89 04 24             	mov    %eax,(%esp)
    1a2e:	e8 b4 24 00 00       	call   3ee7 <close>
    }
    if(pid == 0)
    1a33:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1a37:	75 05                	jne    1a3e <concreate+0x11c>
      exit();
    1a39:	e8 81 24 00 00       	call   3ebf <exit>
    else
      wait();
    1a3e:	e8 84 24 00 00       	call   3ec7 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    1a43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1a47:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1a4b:	0f 8e ff fe ff ff    	jle    1950 <concreate+0x2e>
      exit();
    else
      wait();
  }

  memset(fa, 0, sizeof(fa));
    1a51:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    1a58:	00 
    1a59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1a60:	00 
    1a61:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1a64:	89 04 24             	mov    %eax,(%esp)
    1a67:	e8 a6 22 00 00       	call   3d12 <memset>
  fd = open(".", 0);
    1a6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1a73:	00 
    1a74:	c7 04 24 9f 4c 00 00 	movl   $0x4c9f,(%esp)
    1a7b:	e8 7f 24 00 00       	call   3eff <open>
    1a80:	89 45 e8             	mov    %eax,-0x18(%ebp)
  n = 0;
    1a83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(read(fd, &de, sizeof(de)) > 0){
    1a8a:	e9 a1 00 00 00       	jmp    1b30 <concreate+0x20e>
    if(de.inum == 0)
    1a8f:	0f b7 45 ac          	movzwl -0x54(%ebp),%eax
    1a93:	66 85 c0             	test   %ax,%ax
    1a96:	75 05                	jne    1a9d <concreate+0x17b>
      continue;
    1a98:	e9 93 00 00 00       	jmp    1b30 <concreate+0x20e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1a9d:	0f b6 45 ae          	movzbl -0x52(%ebp),%eax
    1aa1:	3c 43                	cmp    $0x43,%al
    1aa3:	0f 85 87 00 00 00    	jne    1b30 <concreate+0x20e>
    1aa9:	0f b6 45 b0          	movzbl -0x50(%ebp),%eax
    1aad:	84 c0                	test   %al,%al
    1aaf:	75 7f                	jne    1b30 <concreate+0x20e>
      i = de.name[1] - '0';
    1ab1:	0f b6 45 af          	movzbl -0x51(%ebp),%eax
    1ab5:	0f be c0             	movsbl %al,%eax
    1ab8:	83 e8 30             	sub    $0x30,%eax
    1abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(i < 0 || i >= sizeof(fa)){
    1abe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1ac2:	78 08                	js     1acc <concreate+0x1aa>
    1ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ac7:	83 f8 27             	cmp    $0x27,%eax
    1aca:	76 23                	jbe    1aef <concreate+0x1cd>
        printf(1, "concreate weird file %s\n", de.name);
    1acc:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1acf:	83 c0 02             	add    $0x2,%eax
    1ad2:	89 44 24 08          	mov    %eax,0x8(%esp)
    1ad6:	c7 44 24 04 f9 4c 00 	movl   $0x4cf9,0x4(%esp)
    1add:	00 
    1ade:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ae5:	e8 5d 25 00 00       	call   4047 <printf>
        exit();
    1aea:	e8 d0 23 00 00       	call   3ebf <exit>
      }
      if(fa[i]){
    1aef:	8d 55 bd             	lea    -0x43(%ebp),%edx
    1af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1af5:	01 d0                	add    %edx,%eax
    1af7:	0f b6 00             	movzbl (%eax),%eax
    1afa:	84 c0                	test   %al,%al
    1afc:	74 23                	je     1b21 <concreate+0x1ff>
        printf(1, "concreate duplicate file %s\n", de.name);
    1afe:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1b01:	83 c0 02             	add    $0x2,%eax
    1b04:	89 44 24 08          	mov    %eax,0x8(%esp)
    1b08:	c7 44 24 04 12 4d 00 	movl   $0x4d12,0x4(%esp)
    1b0f:	00 
    1b10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b17:	e8 2b 25 00 00       	call   4047 <printf>
        exit();
    1b1c:	e8 9e 23 00 00       	call   3ebf <exit>
      }
      fa[i] = 1;
    1b21:	8d 55 bd             	lea    -0x43(%ebp),%edx
    1b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b27:	01 d0                	add    %edx,%eax
    1b29:	c6 00 01             	movb   $0x1,(%eax)
      n++;
    1b2c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }

  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    1b30:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1b37:	00 
    1b38:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
    1b3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1b42:	89 04 24             	mov    %eax,(%esp)
    1b45:	e8 8d 23 00 00       	call   3ed7 <read>
    1b4a:	85 c0                	test   %eax,%eax
    1b4c:	0f 8f 3d ff ff ff    	jg     1a8f <concreate+0x16d>
      }
      fa[i] = 1;
      n++;
    }
  }
  close(fd);
    1b52:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1b55:	89 04 24             	mov    %eax,(%esp)
    1b58:	e8 8a 23 00 00       	call   3ee7 <close>

  if(n != 40){
    1b5d:	83 7d f0 28          	cmpl   $0x28,-0x10(%ebp)
    1b61:	74 19                	je     1b7c <concreate+0x25a>
    printf(1, "concreate not enough files in directory listing\n");
    1b63:	c7 44 24 04 30 4d 00 	movl   $0x4d30,0x4(%esp)
    1b6a:	00 
    1b6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b72:	e8 d0 24 00 00       	call   4047 <printf>
    exit();
    1b77:	e8 43 23 00 00       	call   3ebf <exit>
  }

  for(i = 0; i < 40; i++){
    1b7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1b83:	e9 2d 01 00 00       	jmp    1cb5 <concreate+0x393>
    file[1] = '0' + i;
    1b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b8b:	83 c0 30             	add    $0x30,%eax
    1b8e:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    1b91:	e8 21 23 00 00       	call   3eb7 <fork>
    1b96:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1b99:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1b9d:	79 19                	jns    1bb8 <concreate+0x296>
      printf(1, "fork failed\n");
    1b9f:	c7 44 24 04 b5 44 00 	movl   $0x44b5,0x4(%esp)
    1ba6:	00 
    1ba7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1bae:	e8 94 24 00 00       	call   4047 <printf>
      exit();
    1bb3:	e8 07 23 00 00       	call   3ebf <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    1bb8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1bbb:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1bc0:	89 c8                	mov    %ecx,%eax
    1bc2:	f7 ea                	imul   %edx
    1bc4:	89 c8                	mov    %ecx,%eax
    1bc6:	c1 f8 1f             	sar    $0x1f,%eax
    1bc9:	29 c2                	sub    %eax,%edx
    1bcb:	89 d0                	mov    %edx,%eax
    1bcd:	01 c0                	add    %eax,%eax
    1bcf:	01 d0                	add    %edx,%eax
    1bd1:	29 c1                	sub    %eax,%ecx
    1bd3:	89 ca                	mov    %ecx,%edx
    1bd5:	85 d2                	test   %edx,%edx
    1bd7:	75 06                	jne    1bdf <concreate+0x2bd>
    1bd9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1bdd:	74 28                	je     1c07 <concreate+0x2e5>
       ((i % 3) == 1 && pid != 0)){
    1bdf:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1be2:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1be7:	89 c8                	mov    %ecx,%eax
    1be9:	f7 ea                	imul   %edx
    1beb:	89 c8                	mov    %ecx,%eax
    1bed:	c1 f8 1f             	sar    $0x1f,%eax
    1bf0:	29 c2                	sub    %eax,%edx
    1bf2:	89 d0                	mov    %edx,%eax
    1bf4:	01 c0                	add    %eax,%eax
    1bf6:	01 d0                	add    %edx,%eax
    1bf8:	29 c1                	sub    %eax,%ecx
    1bfa:	89 ca                	mov    %ecx,%edx
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    1bfc:	83 fa 01             	cmp    $0x1,%edx
    1bff:	75 74                	jne    1c75 <concreate+0x353>
       ((i % 3) == 1 && pid != 0)){
    1c01:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1c05:	74 6e                	je     1c75 <concreate+0x353>
      close(open(file, 0));
    1c07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c0e:	00 
    1c0f:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c12:	89 04 24             	mov    %eax,(%esp)
    1c15:	e8 e5 22 00 00       	call   3eff <open>
    1c1a:	89 04 24             	mov    %eax,(%esp)
    1c1d:	e8 c5 22 00 00       	call   3ee7 <close>
      close(open(file, 0));
    1c22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c29:	00 
    1c2a:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c2d:	89 04 24             	mov    %eax,(%esp)
    1c30:	e8 ca 22 00 00       	call   3eff <open>
    1c35:	89 04 24             	mov    %eax,(%esp)
    1c38:	e8 aa 22 00 00       	call   3ee7 <close>
      close(open(file, 0));
    1c3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c44:	00 
    1c45:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c48:	89 04 24             	mov    %eax,(%esp)
    1c4b:	e8 af 22 00 00       	call   3eff <open>
    1c50:	89 04 24             	mov    %eax,(%esp)
    1c53:	e8 8f 22 00 00       	call   3ee7 <close>
      close(open(file, 0));
    1c58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c5f:	00 
    1c60:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c63:	89 04 24             	mov    %eax,(%esp)
    1c66:	e8 94 22 00 00       	call   3eff <open>
    1c6b:	89 04 24             	mov    %eax,(%esp)
    1c6e:	e8 74 22 00 00       	call   3ee7 <close>
    1c73:	eb 2c                	jmp    1ca1 <concreate+0x37f>
    } else {
      unlink(file);
    1c75:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c78:	89 04 24             	mov    %eax,(%esp)
    1c7b:	e8 8f 22 00 00       	call   3f0f <unlink>
      unlink(file);
    1c80:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c83:	89 04 24             	mov    %eax,(%esp)
    1c86:	e8 84 22 00 00       	call   3f0f <unlink>
      unlink(file);
    1c8b:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c8e:	89 04 24             	mov    %eax,(%esp)
    1c91:	e8 79 22 00 00       	call   3f0f <unlink>
      unlink(file);
    1c96:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c99:	89 04 24             	mov    %eax,(%esp)
    1c9c:	e8 6e 22 00 00       	call   3f0f <unlink>
    }
    if(pid == 0)
    1ca1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1ca5:	75 05                	jne    1cac <concreate+0x38a>
      exit();
    1ca7:	e8 13 22 00 00       	call   3ebf <exit>
    else
      wait();
    1cac:	e8 16 22 00 00       	call   3ec7 <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    1cb1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1cb5:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1cb9:	0f 8e c9 fe ff ff    	jle    1b88 <concreate+0x266>
      exit();
    else
      wait();
  }

  printf(1, "concreate ok\n");
    1cbf:	c7 44 24 04 61 4d 00 	movl   $0x4d61,0x4(%esp)
    1cc6:	00 
    1cc7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cce:	e8 74 23 00 00       	call   4047 <printf>
}
    1cd3:	c9                   	leave  
    1cd4:	c3                   	ret    

00001cd5 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1cd5:	55                   	push   %ebp
    1cd6:	89 e5                	mov    %esp,%ebp
    1cd8:	83 ec 28             	sub    $0x28,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    1cdb:	c7 44 24 04 6f 4d 00 	movl   $0x4d6f,0x4(%esp)
    1ce2:	00 
    1ce3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cea:	e8 58 23 00 00       	call   4047 <printf>

  unlink("x");
    1cef:	c7 04 24 eb 48 00 00 	movl   $0x48eb,(%esp)
    1cf6:	e8 14 22 00 00       	call   3f0f <unlink>
  pid = fork();
    1cfb:	e8 b7 21 00 00       	call   3eb7 <fork>
    1d00:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid < 0){
    1d03:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1d07:	79 19                	jns    1d22 <linkunlink+0x4d>
    printf(1, "fork failed\n");
    1d09:	c7 44 24 04 b5 44 00 	movl   $0x44b5,0x4(%esp)
    1d10:	00 
    1d11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d18:	e8 2a 23 00 00       	call   4047 <printf>
    exit();
    1d1d:	e8 9d 21 00 00       	call   3ebf <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    1d22:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1d26:	74 07                	je     1d2f <linkunlink+0x5a>
    1d28:	b8 01 00 00 00       	mov    $0x1,%eax
    1d2d:	eb 05                	jmp    1d34 <linkunlink+0x5f>
    1d2f:	b8 61 00 00 00       	mov    $0x61,%eax
    1d34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 100; i++){
    1d37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1d3e:	e9 8e 00 00 00       	jmp    1dd1 <linkunlink+0xfc>
    x = x * 1103515245 + 12345;
    1d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1d46:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
    1d4c:	05 39 30 00 00       	add    $0x3039,%eax
    1d51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((x % 3) == 0){
    1d54:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1d57:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1d5c:	89 c8                	mov    %ecx,%eax
    1d5e:	f7 e2                	mul    %edx
    1d60:	d1 ea                	shr    %edx
    1d62:	89 d0                	mov    %edx,%eax
    1d64:	01 c0                	add    %eax,%eax
    1d66:	01 d0                	add    %edx,%eax
    1d68:	29 c1                	sub    %eax,%ecx
    1d6a:	89 ca                	mov    %ecx,%edx
    1d6c:	85 d2                	test   %edx,%edx
    1d6e:	75 1e                	jne    1d8e <linkunlink+0xb9>
      close(open("x", O_RDWR | O_CREATE));
    1d70:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1d77:	00 
    1d78:	c7 04 24 eb 48 00 00 	movl   $0x48eb,(%esp)
    1d7f:	e8 7b 21 00 00       	call   3eff <open>
    1d84:	89 04 24             	mov    %eax,(%esp)
    1d87:	e8 5b 21 00 00       	call   3ee7 <close>
    1d8c:	eb 3f                	jmp    1dcd <linkunlink+0xf8>
    } else if((x % 3) == 1){
    1d8e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1d91:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1d96:	89 c8                	mov    %ecx,%eax
    1d98:	f7 e2                	mul    %edx
    1d9a:	d1 ea                	shr    %edx
    1d9c:	89 d0                	mov    %edx,%eax
    1d9e:	01 c0                	add    %eax,%eax
    1da0:	01 d0                	add    %edx,%eax
    1da2:	29 c1                	sub    %eax,%ecx
    1da4:	89 ca                	mov    %ecx,%edx
    1da6:	83 fa 01             	cmp    $0x1,%edx
    1da9:	75 16                	jne    1dc1 <linkunlink+0xec>
      link("cat", "x");
    1dab:	c7 44 24 04 eb 48 00 	movl   $0x48eb,0x4(%esp)
    1db2:	00 
    1db3:	c7 04 24 80 4d 00 00 	movl   $0x4d80,(%esp)
    1dba:	e8 60 21 00 00       	call   3f1f <link>
    1dbf:	eb 0c                	jmp    1dcd <linkunlink+0xf8>
    } else {
      unlink("x");
    1dc1:	c7 04 24 eb 48 00 00 	movl   $0x48eb,(%esp)
    1dc8:	e8 42 21 00 00       	call   3f0f <unlink>
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    1dcd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1dd1:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    1dd5:	0f 8e 68 ff ff ff    	jle    1d43 <linkunlink+0x6e>
    } else {
      unlink("x");
    }
  }

  if(pid)
    1ddb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1ddf:	74 07                	je     1de8 <linkunlink+0x113>
    wait();
    1de1:	e8 e1 20 00 00       	call   3ec7 <wait>
    1de6:	eb 05                	jmp    1ded <linkunlink+0x118>
  else 
    exit();
    1de8:	e8 d2 20 00 00       	call   3ebf <exit>

  printf(1, "linkunlink ok\n");
    1ded:	c7 44 24 04 84 4d 00 	movl   $0x4d84,0x4(%esp)
    1df4:	00 
    1df5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1dfc:	e8 46 22 00 00       	call   4047 <printf>
}
    1e01:	c9                   	leave  
    1e02:	c3                   	ret    

00001e03 <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    1e03:	55                   	push   %ebp
    1e04:	89 e5                	mov    %esp,%ebp
    1e06:	83 ec 38             	sub    $0x38,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    1e09:	c7 44 24 04 93 4d 00 	movl   $0x4d93,0x4(%esp)
    1e10:	00 
    1e11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e18:	e8 2a 22 00 00       	call   4047 <printf>
  unlink("bd");
    1e1d:	c7 04 24 a0 4d 00 00 	movl   $0x4da0,(%esp)
    1e24:	e8 e6 20 00 00       	call   3f0f <unlink>

  fd = open("bd", O_CREATE);
    1e29:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    1e30:	00 
    1e31:	c7 04 24 a0 4d 00 00 	movl   $0x4da0,(%esp)
    1e38:	e8 c2 20 00 00       	call   3eff <open>
    1e3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd < 0){
    1e40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1e44:	79 19                	jns    1e5f <bigdir+0x5c>
    printf(1, "bigdir create failed\n");
    1e46:	c7 44 24 04 a3 4d 00 	movl   $0x4da3,0x4(%esp)
    1e4d:	00 
    1e4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e55:	e8 ed 21 00 00       	call   4047 <printf>
    exit();
    1e5a:	e8 60 20 00 00       	call   3ebf <exit>
  }
  close(fd);
    1e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1e62:	89 04 24             	mov    %eax,(%esp)
    1e65:	e8 7d 20 00 00       	call   3ee7 <close>

  for(i = 0; i < 500; i++){
    1e6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1e71:	eb 64                	jmp    1ed7 <bigdir+0xd4>
    name[0] = 'x';
    1e73:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1e7a:	8d 50 3f             	lea    0x3f(%eax),%edx
    1e7d:	85 c0                	test   %eax,%eax
    1e7f:	0f 48 c2             	cmovs  %edx,%eax
    1e82:	c1 f8 06             	sar    $0x6,%eax
    1e85:	83 c0 30             	add    $0x30,%eax
    1e88:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1e8e:	99                   	cltd   
    1e8f:	c1 ea 1a             	shr    $0x1a,%edx
    1e92:	01 d0                	add    %edx,%eax
    1e94:	83 e0 3f             	and    $0x3f,%eax
    1e97:	29 d0                	sub    %edx,%eax
    1e99:	83 c0 30             	add    $0x30,%eax
    1e9c:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1e9f:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(link("bd", name) != 0){
    1ea3:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1ea6:	89 44 24 04          	mov    %eax,0x4(%esp)
    1eaa:	c7 04 24 a0 4d 00 00 	movl   $0x4da0,(%esp)
    1eb1:	e8 69 20 00 00       	call   3f1f <link>
    1eb6:	85 c0                	test   %eax,%eax
    1eb8:	74 19                	je     1ed3 <bigdir+0xd0>
      printf(1, "bigdir link failed\n");
    1eba:	c7 44 24 04 b9 4d 00 	movl   $0x4db9,0x4(%esp)
    1ec1:	00 
    1ec2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ec9:	e8 79 21 00 00       	call   4047 <printf>
      exit();
    1ece:	e8 ec 1f 00 00       	call   3ebf <exit>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);

  for(i = 0; i < 500; i++){
    1ed3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1ed7:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1ede:	7e 93                	jle    1e73 <bigdir+0x70>
      printf(1, "bigdir link failed\n");
      exit();
    }
  }

  unlink("bd");
    1ee0:	c7 04 24 a0 4d 00 00 	movl   $0x4da0,(%esp)
    1ee7:	e8 23 20 00 00       	call   3f0f <unlink>
  for(i = 0; i < 500; i++){
    1eec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1ef3:	eb 5c                	jmp    1f51 <bigdir+0x14e>
    name[0] = 'x';
    1ef5:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1efc:	8d 50 3f             	lea    0x3f(%eax),%edx
    1eff:	85 c0                	test   %eax,%eax
    1f01:	0f 48 c2             	cmovs  %edx,%eax
    1f04:	c1 f8 06             	sar    $0x6,%eax
    1f07:	83 c0 30             	add    $0x30,%eax
    1f0a:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1f10:	99                   	cltd   
    1f11:	c1 ea 1a             	shr    $0x1a,%edx
    1f14:	01 d0                	add    %edx,%eax
    1f16:	83 e0 3f             	and    $0x3f,%eax
    1f19:	29 d0                	sub    %edx,%eax
    1f1b:	83 c0 30             	add    $0x30,%eax
    1f1e:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1f21:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(unlink(name) != 0){
    1f25:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1f28:	89 04 24             	mov    %eax,(%esp)
    1f2b:	e8 df 1f 00 00       	call   3f0f <unlink>
    1f30:	85 c0                	test   %eax,%eax
    1f32:	74 19                	je     1f4d <bigdir+0x14a>
      printf(1, "bigdir unlink failed");
    1f34:	c7 44 24 04 cd 4d 00 	movl   $0x4dcd,0x4(%esp)
    1f3b:	00 
    1f3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f43:	e8 ff 20 00 00       	call   4047 <printf>
      exit();
    1f48:	e8 72 1f 00 00       	call   3ebf <exit>
      exit();
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    1f4d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1f51:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1f58:	7e 9b                	jle    1ef5 <bigdir+0xf2>
      printf(1, "bigdir unlink failed");
      exit();
    }
  }

  printf(1, "bigdir ok\n");
    1f5a:	c7 44 24 04 e2 4d 00 	movl   $0x4de2,0x4(%esp)
    1f61:	00 
    1f62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f69:	e8 d9 20 00 00       	call   4047 <printf>
}
    1f6e:	c9                   	leave  
    1f6f:	c3                   	ret    

00001f70 <subdir>:

void
subdir(void)
{
    1f70:	55                   	push   %ebp
    1f71:	89 e5                	mov    %esp,%ebp
    1f73:	83 ec 28             	sub    $0x28,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    1f76:	c7 44 24 04 ed 4d 00 	movl   $0x4ded,0x4(%esp)
    1f7d:	00 
    1f7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f85:	e8 bd 20 00 00       	call   4047 <printf>

  unlink("ff");
    1f8a:	c7 04 24 fa 4d 00 00 	movl   $0x4dfa,(%esp)
    1f91:	e8 79 1f 00 00       	call   3f0f <unlink>
  if(mkdir("dd") != 0){
    1f96:	c7 04 24 fd 4d 00 00 	movl   $0x4dfd,(%esp)
    1f9d:	e8 85 1f 00 00       	call   3f27 <mkdir>
    1fa2:	85 c0                	test   %eax,%eax
    1fa4:	74 19                	je     1fbf <subdir+0x4f>
    printf(1, "subdir mkdir dd failed\n");
    1fa6:	c7 44 24 04 00 4e 00 	movl   $0x4e00,0x4(%esp)
    1fad:	00 
    1fae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1fb5:	e8 8d 20 00 00       	call   4047 <printf>
    exit();
    1fba:	e8 00 1f 00 00       	call   3ebf <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    1fbf:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1fc6:	00 
    1fc7:	c7 04 24 18 4e 00 00 	movl   $0x4e18,(%esp)
    1fce:	e8 2c 1f 00 00       	call   3eff <open>
    1fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1fd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1fda:	79 19                	jns    1ff5 <subdir+0x85>
    printf(1, "create dd/ff failed\n");
    1fdc:	c7 44 24 04 1e 4e 00 	movl   $0x4e1e,0x4(%esp)
    1fe3:	00 
    1fe4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1feb:	e8 57 20 00 00       	call   4047 <printf>
    exit();
    1ff0:	e8 ca 1e 00 00       	call   3ebf <exit>
  }
  write(fd, "ff", 2);
    1ff5:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1ffc:	00 
    1ffd:	c7 44 24 04 fa 4d 00 	movl   $0x4dfa,0x4(%esp)
    2004:	00 
    2005:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2008:	89 04 24             	mov    %eax,(%esp)
    200b:	e8 cf 1e 00 00       	call   3edf <write>
  close(fd);
    2010:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2013:	89 04 24             	mov    %eax,(%esp)
    2016:	e8 cc 1e 00 00       	call   3ee7 <close>
  
  if(unlink("dd") >= 0){
    201b:	c7 04 24 fd 4d 00 00 	movl   $0x4dfd,(%esp)
    2022:	e8 e8 1e 00 00       	call   3f0f <unlink>
    2027:	85 c0                	test   %eax,%eax
    2029:	78 19                	js     2044 <subdir+0xd4>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    202b:	c7 44 24 04 34 4e 00 	movl   $0x4e34,0x4(%esp)
    2032:	00 
    2033:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    203a:	e8 08 20 00 00       	call   4047 <printf>
    exit();
    203f:	e8 7b 1e 00 00       	call   3ebf <exit>
  }

  if(mkdir("/dd/dd") != 0){
    2044:	c7 04 24 5a 4e 00 00 	movl   $0x4e5a,(%esp)
    204b:	e8 d7 1e 00 00       	call   3f27 <mkdir>
    2050:	85 c0                	test   %eax,%eax
    2052:	74 19                	je     206d <subdir+0xfd>
    printf(1, "subdir mkdir dd/dd failed\n");
    2054:	c7 44 24 04 61 4e 00 	movl   $0x4e61,0x4(%esp)
    205b:	00 
    205c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2063:	e8 df 1f 00 00       	call   4047 <printf>
    exit();
    2068:	e8 52 1e 00 00       	call   3ebf <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    206d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2074:	00 
    2075:	c7 04 24 7c 4e 00 00 	movl   $0x4e7c,(%esp)
    207c:	e8 7e 1e 00 00       	call   3eff <open>
    2081:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2084:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2088:	79 19                	jns    20a3 <subdir+0x133>
    printf(1, "create dd/dd/ff failed\n");
    208a:	c7 44 24 04 85 4e 00 	movl   $0x4e85,0x4(%esp)
    2091:	00 
    2092:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2099:	e8 a9 1f 00 00       	call   4047 <printf>
    exit();
    209e:	e8 1c 1e 00 00       	call   3ebf <exit>
  }
  write(fd, "FF", 2);
    20a3:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    20aa:	00 
    20ab:	c7 44 24 04 9d 4e 00 	movl   $0x4e9d,0x4(%esp)
    20b2:	00 
    20b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    20b6:	89 04 24             	mov    %eax,(%esp)
    20b9:	e8 21 1e 00 00       	call   3edf <write>
  close(fd);
    20be:	8b 45 f4             	mov    -0xc(%ebp),%eax
    20c1:	89 04 24             	mov    %eax,(%esp)
    20c4:	e8 1e 1e 00 00       	call   3ee7 <close>

  fd = open("dd/dd/../ff", 0);
    20c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    20d0:	00 
    20d1:	c7 04 24 a0 4e 00 00 	movl   $0x4ea0,(%esp)
    20d8:	e8 22 1e 00 00       	call   3eff <open>
    20dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    20e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    20e4:	79 19                	jns    20ff <subdir+0x18f>
    printf(1, "open dd/dd/../ff failed\n");
    20e6:	c7 44 24 04 ac 4e 00 	movl   $0x4eac,0x4(%esp)
    20ed:	00 
    20ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20f5:	e8 4d 1f 00 00       	call   4047 <printf>
    exit();
    20fa:	e8 c0 1d 00 00       	call   3ebf <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    20ff:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    2106:	00 
    2107:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    210e:	00 
    210f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2112:	89 04 24             	mov    %eax,(%esp)
    2115:	e8 bd 1d 00 00       	call   3ed7 <read>
    211a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(cc != 2 || buf[0] != 'f'){
    211d:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
    2121:	75 0b                	jne    212e <subdir+0x1be>
    2123:	0f b6 05 c0 8a 00 00 	movzbl 0x8ac0,%eax
    212a:	3c 66                	cmp    $0x66,%al
    212c:	74 19                	je     2147 <subdir+0x1d7>
    printf(1, "dd/dd/../ff wrong content\n");
    212e:	c7 44 24 04 c5 4e 00 	movl   $0x4ec5,0x4(%esp)
    2135:	00 
    2136:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    213d:	e8 05 1f 00 00       	call   4047 <printf>
    exit();
    2142:	e8 78 1d 00 00       	call   3ebf <exit>
  }
  close(fd);
    2147:	8b 45 f4             	mov    -0xc(%ebp),%eax
    214a:	89 04 24             	mov    %eax,(%esp)
    214d:	e8 95 1d 00 00       	call   3ee7 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2152:	c7 44 24 04 e0 4e 00 	movl   $0x4ee0,0x4(%esp)
    2159:	00 
    215a:	c7 04 24 7c 4e 00 00 	movl   $0x4e7c,(%esp)
    2161:	e8 b9 1d 00 00       	call   3f1f <link>
    2166:	85 c0                	test   %eax,%eax
    2168:	74 19                	je     2183 <subdir+0x213>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    216a:	c7 44 24 04 ec 4e 00 	movl   $0x4eec,0x4(%esp)
    2171:	00 
    2172:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2179:	e8 c9 1e 00 00       	call   4047 <printf>
    exit();
    217e:	e8 3c 1d 00 00       	call   3ebf <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    2183:	c7 04 24 7c 4e 00 00 	movl   $0x4e7c,(%esp)
    218a:	e8 80 1d 00 00       	call   3f0f <unlink>
    218f:	85 c0                	test   %eax,%eax
    2191:	74 19                	je     21ac <subdir+0x23c>
    printf(1, "unlink dd/dd/ff failed\n");
    2193:	c7 44 24 04 0d 4f 00 	movl   $0x4f0d,0x4(%esp)
    219a:	00 
    219b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21a2:	e8 a0 1e 00 00       	call   4047 <printf>
    exit();
    21a7:	e8 13 1d 00 00       	call   3ebf <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    21ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    21b3:	00 
    21b4:	c7 04 24 7c 4e 00 00 	movl   $0x4e7c,(%esp)
    21bb:	e8 3f 1d 00 00       	call   3eff <open>
    21c0:	85 c0                	test   %eax,%eax
    21c2:	78 19                	js     21dd <subdir+0x26d>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    21c4:	c7 44 24 04 28 4f 00 	movl   $0x4f28,0x4(%esp)
    21cb:	00 
    21cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21d3:	e8 6f 1e 00 00       	call   4047 <printf>
    exit();
    21d8:	e8 e2 1c 00 00       	call   3ebf <exit>
  }

  if(chdir("dd") != 0){
    21dd:	c7 04 24 fd 4d 00 00 	movl   $0x4dfd,(%esp)
    21e4:	e8 46 1d 00 00       	call   3f2f <chdir>
    21e9:	85 c0                	test   %eax,%eax
    21eb:	74 19                	je     2206 <subdir+0x296>
    printf(1, "chdir dd failed\n");
    21ed:	c7 44 24 04 4c 4f 00 	movl   $0x4f4c,0x4(%esp)
    21f4:	00 
    21f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21fc:	e8 46 1e 00 00       	call   4047 <printf>
    exit();
    2201:	e8 b9 1c 00 00       	call   3ebf <exit>
  }
  if(chdir("dd/../../dd") != 0){
    2206:	c7 04 24 5d 4f 00 00 	movl   $0x4f5d,(%esp)
    220d:	e8 1d 1d 00 00       	call   3f2f <chdir>
    2212:	85 c0                	test   %eax,%eax
    2214:	74 19                	je     222f <subdir+0x2bf>
    printf(1, "chdir dd/../../dd failed\n");
    2216:	c7 44 24 04 69 4f 00 	movl   $0x4f69,0x4(%esp)
    221d:	00 
    221e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2225:	e8 1d 1e 00 00       	call   4047 <printf>
    exit();
    222a:	e8 90 1c 00 00       	call   3ebf <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    222f:	c7 04 24 83 4f 00 00 	movl   $0x4f83,(%esp)
    2236:	e8 f4 1c 00 00       	call   3f2f <chdir>
    223b:	85 c0                	test   %eax,%eax
    223d:	74 19                	je     2258 <subdir+0x2e8>
    printf(1, "chdir dd/../../dd failed\n");
    223f:	c7 44 24 04 69 4f 00 	movl   $0x4f69,0x4(%esp)
    2246:	00 
    2247:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    224e:	e8 f4 1d 00 00       	call   4047 <printf>
    exit();
    2253:	e8 67 1c 00 00       	call   3ebf <exit>
  }
  if(chdir("./..") != 0){
    2258:	c7 04 24 92 4f 00 00 	movl   $0x4f92,(%esp)
    225f:	e8 cb 1c 00 00       	call   3f2f <chdir>
    2264:	85 c0                	test   %eax,%eax
    2266:	74 19                	je     2281 <subdir+0x311>
    printf(1, "chdir ./.. failed\n");
    2268:	c7 44 24 04 97 4f 00 	movl   $0x4f97,0x4(%esp)
    226f:	00 
    2270:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2277:	e8 cb 1d 00 00       	call   4047 <printf>
    exit();
    227c:	e8 3e 1c 00 00       	call   3ebf <exit>
  }

  fd = open("dd/dd/ffff", 0);
    2281:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2288:	00 
    2289:	c7 04 24 e0 4e 00 00 	movl   $0x4ee0,(%esp)
    2290:	e8 6a 1c 00 00       	call   3eff <open>
    2295:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2298:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    229c:	79 19                	jns    22b7 <subdir+0x347>
    printf(1, "open dd/dd/ffff failed\n");
    229e:	c7 44 24 04 aa 4f 00 	movl   $0x4faa,0x4(%esp)
    22a5:	00 
    22a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22ad:	e8 95 1d 00 00       	call   4047 <printf>
    exit();
    22b2:	e8 08 1c 00 00       	call   3ebf <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    22b7:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    22be:	00 
    22bf:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    22c6:	00 
    22c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    22ca:	89 04 24             	mov    %eax,(%esp)
    22cd:	e8 05 1c 00 00       	call   3ed7 <read>
    22d2:	83 f8 02             	cmp    $0x2,%eax
    22d5:	74 19                	je     22f0 <subdir+0x380>
    printf(1, "read dd/dd/ffff wrong len\n");
    22d7:	c7 44 24 04 c2 4f 00 	movl   $0x4fc2,0x4(%esp)
    22de:	00 
    22df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22e6:	e8 5c 1d 00 00       	call   4047 <printf>
    exit();
    22eb:	e8 cf 1b 00 00       	call   3ebf <exit>
  }
  close(fd);
    22f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    22f3:	89 04 24             	mov    %eax,(%esp)
    22f6:	e8 ec 1b 00 00       	call   3ee7 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    22fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2302:	00 
    2303:	c7 04 24 7c 4e 00 00 	movl   $0x4e7c,(%esp)
    230a:	e8 f0 1b 00 00       	call   3eff <open>
    230f:	85 c0                	test   %eax,%eax
    2311:	78 19                	js     232c <subdir+0x3bc>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    2313:	c7 44 24 04 e0 4f 00 	movl   $0x4fe0,0x4(%esp)
    231a:	00 
    231b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2322:	e8 20 1d 00 00       	call   4047 <printf>
    exit();
    2327:	e8 93 1b 00 00       	call   3ebf <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    232c:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2333:	00 
    2334:	c7 04 24 05 50 00 00 	movl   $0x5005,(%esp)
    233b:	e8 bf 1b 00 00       	call   3eff <open>
    2340:	85 c0                	test   %eax,%eax
    2342:	78 19                	js     235d <subdir+0x3ed>
    printf(1, "create dd/ff/ff succeeded!\n");
    2344:	c7 44 24 04 0e 50 00 	movl   $0x500e,0x4(%esp)
    234b:	00 
    234c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2353:	e8 ef 1c 00 00       	call   4047 <printf>
    exit();
    2358:	e8 62 1b 00 00       	call   3ebf <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    235d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2364:	00 
    2365:	c7 04 24 2a 50 00 00 	movl   $0x502a,(%esp)
    236c:	e8 8e 1b 00 00       	call   3eff <open>
    2371:	85 c0                	test   %eax,%eax
    2373:	78 19                	js     238e <subdir+0x41e>
    printf(1, "create dd/xx/ff succeeded!\n");
    2375:	c7 44 24 04 33 50 00 	movl   $0x5033,0x4(%esp)
    237c:	00 
    237d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2384:	e8 be 1c 00 00       	call   4047 <printf>
    exit();
    2389:	e8 31 1b 00 00       	call   3ebf <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    238e:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2395:	00 
    2396:	c7 04 24 fd 4d 00 00 	movl   $0x4dfd,(%esp)
    239d:	e8 5d 1b 00 00       	call   3eff <open>
    23a2:	85 c0                	test   %eax,%eax
    23a4:	78 19                	js     23bf <subdir+0x44f>
    printf(1, "create dd succeeded!\n");
    23a6:	c7 44 24 04 4f 50 00 	movl   $0x504f,0x4(%esp)
    23ad:	00 
    23ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23b5:	e8 8d 1c 00 00       	call   4047 <printf>
    exit();
    23ba:	e8 00 1b 00 00       	call   3ebf <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    23bf:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    23c6:	00 
    23c7:	c7 04 24 fd 4d 00 00 	movl   $0x4dfd,(%esp)
    23ce:	e8 2c 1b 00 00       	call   3eff <open>
    23d3:	85 c0                	test   %eax,%eax
    23d5:	78 19                	js     23f0 <subdir+0x480>
    printf(1, "open dd rdwr succeeded!\n");
    23d7:	c7 44 24 04 65 50 00 	movl   $0x5065,0x4(%esp)
    23de:	00 
    23df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23e6:	e8 5c 1c 00 00       	call   4047 <printf>
    exit();
    23eb:	e8 cf 1a 00 00       	call   3ebf <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    23f0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    23f7:	00 
    23f8:	c7 04 24 fd 4d 00 00 	movl   $0x4dfd,(%esp)
    23ff:	e8 fb 1a 00 00       	call   3eff <open>
    2404:	85 c0                	test   %eax,%eax
    2406:	78 19                	js     2421 <subdir+0x4b1>
    printf(1, "open dd wronly succeeded!\n");
    2408:	c7 44 24 04 7e 50 00 	movl   $0x507e,0x4(%esp)
    240f:	00 
    2410:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2417:	e8 2b 1c 00 00       	call   4047 <printf>
    exit();
    241c:	e8 9e 1a 00 00       	call   3ebf <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2421:	c7 44 24 04 99 50 00 	movl   $0x5099,0x4(%esp)
    2428:	00 
    2429:	c7 04 24 05 50 00 00 	movl   $0x5005,(%esp)
    2430:	e8 ea 1a 00 00       	call   3f1f <link>
    2435:	85 c0                	test   %eax,%eax
    2437:	75 19                	jne    2452 <subdir+0x4e2>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    2439:	c7 44 24 04 a4 50 00 	movl   $0x50a4,0x4(%esp)
    2440:	00 
    2441:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2448:	e8 fa 1b 00 00       	call   4047 <printf>
    exit();
    244d:	e8 6d 1a 00 00       	call   3ebf <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2452:	c7 44 24 04 99 50 00 	movl   $0x5099,0x4(%esp)
    2459:	00 
    245a:	c7 04 24 2a 50 00 00 	movl   $0x502a,(%esp)
    2461:	e8 b9 1a 00 00       	call   3f1f <link>
    2466:	85 c0                	test   %eax,%eax
    2468:	75 19                	jne    2483 <subdir+0x513>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    246a:	c7 44 24 04 c8 50 00 	movl   $0x50c8,0x4(%esp)
    2471:	00 
    2472:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2479:	e8 c9 1b 00 00       	call   4047 <printf>
    exit();
    247e:	e8 3c 1a 00 00       	call   3ebf <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2483:	c7 44 24 04 e0 4e 00 	movl   $0x4ee0,0x4(%esp)
    248a:	00 
    248b:	c7 04 24 18 4e 00 00 	movl   $0x4e18,(%esp)
    2492:	e8 88 1a 00 00       	call   3f1f <link>
    2497:	85 c0                	test   %eax,%eax
    2499:	75 19                	jne    24b4 <subdir+0x544>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    249b:	c7 44 24 04 ec 50 00 	movl   $0x50ec,0x4(%esp)
    24a2:	00 
    24a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24aa:	e8 98 1b 00 00       	call   4047 <printf>
    exit();
    24af:	e8 0b 1a 00 00       	call   3ebf <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    24b4:	c7 04 24 05 50 00 00 	movl   $0x5005,(%esp)
    24bb:	e8 67 1a 00 00       	call   3f27 <mkdir>
    24c0:	85 c0                	test   %eax,%eax
    24c2:	75 19                	jne    24dd <subdir+0x56d>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    24c4:	c7 44 24 04 0e 51 00 	movl   $0x510e,0x4(%esp)
    24cb:	00 
    24cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24d3:	e8 6f 1b 00 00       	call   4047 <printf>
    exit();
    24d8:	e8 e2 19 00 00       	call   3ebf <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    24dd:	c7 04 24 2a 50 00 00 	movl   $0x502a,(%esp)
    24e4:	e8 3e 1a 00 00       	call   3f27 <mkdir>
    24e9:	85 c0                	test   %eax,%eax
    24eb:	75 19                	jne    2506 <subdir+0x596>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    24ed:	c7 44 24 04 29 51 00 	movl   $0x5129,0x4(%esp)
    24f4:	00 
    24f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24fc:	e8 46 1b 00 00       	call   4047 <printf>
    exit();
    2501:	e8 b9 19 00 00       	call   3ebf <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    2506:	c7 04 24 e0 4e 00 00 	movl   $0x4ee0,(%esp)
    250d:	e8 15 1a 00 00       	call   3f27 <mkdir>
    2512:	85 c0                	test   %eax,%eax
    2514:	75 19                	jne    252f <subdir+0x5bf>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    2516:	c7 44 24 04 44 51 00 	movl   $0x5144,0x4(%esp)
    251d:	00 
    251e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2525:	e8 1d 1b 00 00       	call   4047 <printf>
    exit();
    252a:	e8 90 19 00 00       	call   3ebf <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    252f:	c7 04 24 2a 50 00 00 	movl   $0x502a,(%esp)
    2536:	e8 d4 19 00 00       	call   3f0f <unlink>
    253b:	85 c0                	test   %eax,%eax
    253d:	75 19                	jne    2558 <subdir+0x5e8>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    253f:	c7 44 24 04 61 51 00 	movl   $0x5161,0x4(%esp)
    2546:	00 
    2547:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    254e:	e8 f4 1a 00 00       	call   4047 <printf>
    exit();
    2553:	e8 67 19 00 00       	call   3ebf <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    2558:	c7 04 24 05 50 00 00 	movl   $0x5005,(%esp)
    255f:	e8 ab 19 00 00       	call   3f0f <unlink>
    2564:	85 c0                	test   %eax,%eax
    2566:	75 19                	jne    2581 <subdir+0x611>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    2568:	c7 44 24 04 7d 51 00 	movl   $0x517d,0x4(%esp)
    256f:	00 
    2570:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2577:	e8 cb 1a 00 00       	call   4047 <printf>
    exit();
    257c:	e8 3e 19 00 00       	call   3ebf <exit>
  }
  if(chdir("dd/ff") == 0){
    2581:	c7 04 24 18 4e 00 00 	movl   $0x4e18,(%esp)
    2588:	e8 a2 19 00 00       	call   3f2f <chdir>
    258d:	85 c0                	test   %eax,%eax
    258f:	75 19                	jne    25aa <subdir+0x63a>
    printf(1, "chdir dd/ff succeeded!\n");
    2591:	c7 44 24 04 99 51 00 	movl   $0x5199,0x4(%esp)
    2598:	00 
    2599:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25a0:	e8 a2 1a 00 00       	call   4047 <printf>
    exit();
    25a5:	e8 15 19 00 00       	call   3ebf <exit>
  }
  if(chdir("dd/xx") == 0){
    25aa:	c7 04 24 b1 51 00 00 	movl   $0x51b1,(%esp)
    25b1:	e8 79 19 00 00       	call   3f2f <chdir>
    25b6:	85 c0                	test   %eax,%eax
    25b8:	75 19                	jne    25d3 <subdir+0x663>
    printf(1, "chdir dd/xx succeeded!\n");
    25ba:	c7 44 24 04 b7 51 00 	movl   $0x51b7,0x4(%esp)
    25c1:	00 
    25c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25c9:	e8 79 1a 00 00       	call   4047 <printf>
    exit();
    25ce:	e8 ec 18 00 00       	call   3ebf <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    25d3:	c7 04 24 e0 4e 00 00 	movl   $0x4ee0,(%esp)
    25da:	e8 30 19 00 00       	call   3f0f <unlink>
    25df:	85 c0                	test   %eax,%eax
    25e1:	74 19                	je     25fc <subdir+0x68c>
    printf(1, "unlink dd/dd/ff failed\n");
    25e3:	c7 44 24 04 0d 4f 00 	movl   $0x4f0d,0x4(%esp)
    25ea:	00 
    25eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25f2:	e8 50 1a 00 00       	call   4047 <printf>
    exit();
    25f7:	e8 c3 18 00 00       	call   3ebf <exit>
  }
  if(unlink("dd/ff") != 0){
    25fc:	c7 04 24 18 4e 00 00 	movl   $0x4e18,(%esp)
    2603:	e8 07 19 00 00       	call   3f0f <unlink>
    2608:	85 c0                	test   %eax,%eax
    260a:	74 19                	je     2625 <subdir+0x6b5>
    printf(1, "unlink dd/ff failed\n");
    260c:	c7 44 24 04 cf 51 00 	movl   $0x51cf,0x4(%esp)
    2613:	00 
    2614:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    261b:	e8 27 1a 00 00       	call   4047 <printf>
    exit();
    2620:	e8 9a 18 00 00       	call   3ebf <exit>
  }
  if(unlink("dd") == 0){
    2625:	c7 04 24 fd 4d 00 00 	movl   $0x4dfd,(%esp)
    262c:	e8 de 18 00 00       	call   3f0f <unlink>
    2631:	85 c0                	test   %eax,%eax
    2633:	75 19                	jne    264e <subdir+0x6de>
    printf(1, "unlink non-empty dd succeeded!\n");
    2635:	c7 44 24 04 e4 51 00 	movl   $0x51e4,0x4(%esp)
    263c:	00 
    263d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2644:	e8 fe 19 00 00       	call   4047 <printf>
    exit();
    2649:	e8 71 18 00 00       	call   3ebf <exit>
  }
  if(unlink("dd/dd") < 0){
    264e:	c7 04 24 04 52 00 00 	movl   $0x5204,(%esp)
    2655:	e8 b5 18 00 00       	call   3f0f <unlink>
    265a:	85 c0                	test   %eax,%eax
    265c:	79 19                	jns    2677 <subdir+0x707>
    printf(1, "unlink dd/dd failed\n");
    265e:	c7 44 24 04 0a 52 00 	movl   $0x520a,0x4(%esp)
    2665:	00 
    2666:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    266d:	e8 d5 19 00 00       	call   4047 <printf>
    exit();
    2672:	e8 48 18 00 00       	call   3ebf <exit>
  }
  if(unlink("dd") < 0){
    2677:	c7 04 24 fd 4d 00 00 	movl   $0x4dfd,(%esp)
    267e:	e8 8c 18 00 00       	call   3f0f <unlink>
    2683:	85 c0                	test   %eax,%eax
    2685:	79 19                	jns    26a0 <subdir+0x730>
    printf(1, "unlink dd failed\n");
    2687:	c7 44 24 04 1f 52 00 	movl   $0x521f,0x4(%esp)
    268e:	00 
    268f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2696:	e8 ac 19 00 00       	call   4047 <printf>
    exit();
    269b:	e8 1f 18 00 00       	call   3ebf <exit>
  }

  printf(1, "subdir ok\n");
    26a0:	c7 44 24 04 31 52 00 	movl   $0x5231,0x4(%esp)
    26a7:	00 
    26a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26af:	e8 93 19 00 00       	call   4047 <printf>
}
    26b4:	c9                   	leave  
    26b5:	c3                   	ret    

000026b6 <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    26b6:	55                   	push   %ebp
    26b7:	89 e5                	mov    %esp,%ebp
    26b9:	83 ec 28             	sub    $0x28,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    26bc:	c7 44 24 04 3c 52 00 	movl   $0x523c,0x4(%esp)
    26c3:	00 
    26c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26cb:	e8 77 19 00 00       	call   4047 <printf>

  unlink("bigwrite");
    26d0:	c7 04 24 4b 52 00 00 	movl   $0x524b,(%esp)
    26d7:	e8 33 18 00 00       	call   3f0f <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    26dc:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%ebp)
    26e3:	e9 b3 00 00 00       	jmp    279b <bigwrite+0xe5>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    26e8:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    26ef:	00 
    26f0:	c7 04 24 4b 52 00 00 	movl   $0x524b,(%esp)
    26f7:	e8 03 18 00 00       	call   3eff <open>
    26fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fd < 0){
    26ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2703:	79 19                	jns    271e <bigwrite+0x68>
      printf(1, "cannot create bigwrite\n");
    2705:	c7 44 24 04 54 52 00 	movl   $0x5254,0x4(%esp)
    270c:	00 
    270d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2714:	e8 2e 19 00 00       	call   4047 <printf>
      exit();
    2719:	e8 a1 17 00 00       	call   3ebf <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    271e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    2725:	eb 50                	jmp    2777 <bigwrite+0xc1>
      int cc = write(fd, buf, sz);
    2727:	8b 45 f4             	mov    -0xc(%ebp),%eax
    272a:	89 44 24 08          	mov    %eax,0x8(%esp)
    272e:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    2735:	00 
    2736:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2739:	89 04 24             	mov    %eax,(%esp)
    273c:	e8 9e 17 00 00       	call   3edf <write>
    2741:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(cc != sz){
    2744:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2747:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    274a:	74 27                	je     2773 <bigwrite+0xbd>
        printf(1, "write(%d) ret %d\n", sz, cc);
    274c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    274f:	89 44 24 0c          	mov    %eax,0xc(%esp)
    2753:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2756:	89 44 24 08          	mov    %eax,0x8(%esp)
    275a:	c7 44 24 04 6c 52 00 	movl   $0x526c,0x4(%esp)
    2761:	00 
    2762:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2769:	e8 d9 18 00 00       	call   4047 <printf>
        exit();
    276e:	e8 4c 17 00 00       	call   3ebf <exit>
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
      exit();
    }
    int i;
    for(i = 0; i < 2; i++){
    2773:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    2777:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
    277b:	7e aa                	jle    2727 <bigwrite+0x71>
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
        exit();
      }
    }
    close(fd);
    277d:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2780:	89 04 24             	mov    %eax,(%esp)
    2783:	e8 5f 17 00 00       	call   3ee7 <close>
    unlink("bigwrite");
    2788:	c7 04 24 4b 52 00 00 	movl   $0x524b,(%esp)
    278f:	e8 7b 17 00 00       	call   3f0f <unlink>
  int fd, sz;

  printf(1, "bigwrite test\n");

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    2794:	81 45 f4 d7 01 00 00 	addl   $0x1d7,-0xc(%ebp)
    279b:	81 7d f4 ff 17 00 00 	cmpl   $0x17ff,-0xc(%ebp)
    27a2:	0f 8e 40 ff ff ff    	jle    26e8 <bigwrite+0x32>
    }
    close(fd);
    unlink("bigwrite");
  }

  printf(1, "bigwrite ok\n");
    27a8:	c7 44 24 04 7e 52 00 	movl   $0x527e,0x4(%esp)
    27af:	00 
    27b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27b7:	e8 8b 18 00 00       	call   4047 <printf>
}
    27bc:	c9                   	leave  
    27bd:	c3                   	ret    

000027be <bigfile>:

void
bigfile(void)
{
    27be:	55                   	push   %ebp
    27bf:	89 e5                	mov    %esp,%ebp
    27c1:	83 ec 28             	sub    $0x28,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    27c4:	c7 44 24 04 8b 52 00 	movl   $0x528b,0x4(%esp)
    27cb:	00 
    27cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27d3:	e8 6f 18 00 00       	call   4047 <printf>

  unlink("bigfile");
    27d8:	c7 04 24 99 52 00 00 	movl   $0x5299,(%esp)
    27df:	e8 2b 17 00 00       	call   3f0f <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    27e4:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    27eb:	00 
    27ec:	c7 04 24 99 52 00 00 	movl   $0x5299,(%esp)
    27f3:	e8 07 17 00 00       	call   3eff <open>
    27f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    27fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    27ff:	79 19                	jns    281a <bigfile+0x5c>
    printf(1, "cannot create bigfile");
    2801:	c7 44 24 04 a1 52 00 	movl   $0x52a1,0x4(%esp)
    2808:	00 
    2809:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2810:	e8 32 18 00 00       	call   4047 <printf>
    exit();
    2815:	e8 a5 16 00 00       	call   3ebf <exit>
  }
  for(i = 0; i < 20; i++){
    281a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2821:	eb 5a                	jmp    287d <bigfile+0xbf>
    memset(buf, i, 600);
    2823:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    282a:	00 
    282b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    282e:	89 44 24 04          	mov    %eax,0x4(%esp)
    2832:	c7 04 24 c0 8a 00 00 	movl   $0x8ac0,(%esp)
    2839:	e8 d4 14 00 00       	call   3d12 <memset>
    if(write(fd, buf, 600) != 600){
    283e:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    2845:	00 
    2846:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    284d:	00 
    284e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2851:	89 04 24             	mov    %eax,(%esp)
    2854:	e8 86 16 00 00       	call   3edf <write>
    2859:	3d 58 02 00 00       	cmp    $0x258,%eax
    285e:	74 19                	je     2879 <bigfile+0xbb>
      printf(1, "write bigfile failed\n");
    2860:	c7 44 24 04 b7 52 00 	movl   $0x52b7,0x4(%esp)
    2867:	00 
    2868:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    286f:	e8 d3 17 00 00       	call   4047 <printf>
      exit();
    2874:	e8 46 16 00 00       	call   3ebf <exit>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    2879:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    287d:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    2881:	7e a0                	jle    2823 <bigfile+0x65>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit();
    }
  }
  close(fd);
    2883:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2886:	89 04 24             	mov    %eax,(%esp)
    2889:	e8 59 16 00 00       	call   3ee7 <close>

  fd = open("bigfile", 0);
    288e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2895:	00 
    2896:	c7 04 24 99 52 00 00 	movl   $0x5299,(%esp)
    289d:	e8 5d 16 00 00       	call   3eff <open>
    28a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    28a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    28a9:	79 19                	jns    28c4 <bigfile+0x106>
    printf(1, "cannot open bigfile\n");
    28ab:	c7 44 24 04 cd 52 00 	movl   $0x52cd,0x4(%esp)
    28b2:	00 
    28b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28ba:	e8 88 17 00 00       	call   4047 <printf>
    exit();
    28bf:	e8 fb 15 00 00       	call   3ebf <exit>
  }
  total = 0;
    28c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; ; i++){
    28cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cc = read(fd, buf, 300);
    28d2:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    28d9:	00 
    28da:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    28e1:	00 
    28e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    28e5:	89 04 24             	mov    %eax,(%esp)
    28e8:	e8 ea 15 00 00       	call   3ed7 <read>
    28ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(cc < 0){
    28f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    28f4:	79 19                	jns    290f <bigfile+0x151>
      printf(1, "read bigfile failed\n");
    28f6:	c7 44 24 04 e2 52 00 	movl   $0x52e2,0x4(%esp)
    28fd:	00 
    28fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2905:	e8 3d 17 00 00       	call   4047 <printf>
      exit();
    290a:	e8 b0 15 00 00       	call   3ebf <exit>
    }
    if(cc == 0)
    290f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2913:	75 1b                	jne    2930 <bigfile+0x172>
      break;
    2915:	90                   	nop
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
  close(fd);
    2916:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2919:	89 04 24             	mov    %eax,(%esp)
    291c:	e8 c6 15 00 00       	call   3ee7 <close>
  if(total != 20*600){
    2921:	81 7d f0 e0 2e 00 00 	cmpl   $0x2ee0,-0x10(%ebp)
    2928:	0f 84 99 00 00 00    	je     29c7 <bigfile+0x209>
    292e:	eb 7e                	jmp    29ae <bigfile+0x1f0>
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
      break;
    if(cc != 300){
    2930:	81 7d e8 2c 01 00 00 	cmpl   $0x12c,-0x18(%ebp)
    2937:	74 19                	je     2952 <bigfile+0x194>
      printf(1, "short read bigfile\n");
    2939:	c7 44 24 04 f7 52 00 	movl   $0x52f7,0x4(%esp)
    2940:	00 
    2941:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2948:	e8 fa 16 00 00       	call   4047 <printf>
      exit();
    294d:	e8 6d 15 00 00       	call   3ebf <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    2952:	0f b6 05 c0 8a 00 00 	movzbl 0x8ac0,%eax
    2959:	0f be d0             	movsbl %al,%edx
    295c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    295f:	89 c1                	mov    %eax,%ecx
    2961:	c1 e9 1f             	shr    $0x1f,%ecx
    2964:	01 c8                	add    %ecx,%eax
    2966:	d1 f8                	sar    %eax
    2968:	39 c2                	cmp    %eax,%edx
    296a:	75 1a                	jne    2986 <bigfile+0x1c8>
    296c:	0f b6 05 eb 8b 00 00 	movzbl 0x8beb,%eax
    2973:	0f be d0             	movsbl %al,%edx
    2976:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2979:	89 c1                	mov    %eax,%ecx
    297b:	c1 e9 1f             	shr    $0x1f,%ecx
    297e:	01 c8                	add    %ecx,%eax
    2980:	d1 f8                	sar    %eax
    2982:	39 c2                	cmp    %eax,%edx
    2984:	74 19                	je     299f <bigfile+0x1e1>
      printf(1, "read bigfile wrong data\n");
    2986:	c7 44 24 04 0b 53 00 	movl   $0x530b,0x4(%esp)
    298d:	00 
    298e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2995:	e8 ad 16 00 00       	call   4047 <printf>
      exit();
    299a:	e8 20 15 00 00       	call   3ebf <exit>
    }
    total += cc;
    299f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    29a2:	01 45 f0             	add    %eax,-0x10(%ebp)
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
  for(i = 0; ; i++){
    29a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
    29a9:	e9 24 ff ff ff       	jmp    28d2 <bigfile+0x114>
  close(fd);
  if(total != 20*600){
    printf(1, "read bigfile wrong total\n");
    29ae:	c7 44 24 04 24 53 00 	movl   $0x5324,0x4(%esp)
    29b5:	00 
    29b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29bd:	e8 85 16 00 00       	call   4047 <printf>
    exit();
    29c2:	e8 f8 14 00 00       	call   3ebf <exit>
  }
  unlink("bigfile");
    29c7:	c7 04 24 99 52 00 00 	movl   $0x5299,(%esp)
    29ce:	e8 3c 15 00 00       	call   3f0f <unlink>

  printf(1, "bigfile test ok\n");
    29d3:	c7 44 24 04 3e 53 00 	movl   $0x533e,0x4(%esp)
    29da:	00 
    29db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29e2:	e8 60 16 00 00       	call   4047 <printf>
}
    29e7:	c9                   	leave  
    29e8:	c3                   	ret    

000029e9 <fourteen>:

void
fourteen(void)
{
    29e9:	55                   	push   %ebp
    29ea:	89 e5                	mov    %esp,%ebp
    29ec:	83 ec 28             	sub    $0x28,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    29ef:	c7 44 24 04 4f 53 00 	movl   $0x534f,0x4(%esp)
    29f6:	00 
    29f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29fe:	e8 44 16 00 00       	call   4047 <printf>

  if(mkdir("12345678901234") != 0){
    2a03:	c7 04 24 5e 53 00 00 	movl   $0x535e,(%esp)
    2a0a:	e8 18 15 00 00       	call   3f27 <mkdir>
    2a0f:	85 c0                	test   %eax,%eax
    2a11:	74 19                	je     2a2c <fourteen+0x43>
    printf(1, "mkdir 12345678901234 failed\n");
    2a13:	c7 44 24 04 6d 53 00 	movl   $0x536d,0x4(%esp)
    2a1a:	00 
    2a1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a22:	e8 20 16 00 00       	call   4047 <printf>
    exit();
    2a27:	e8 93 14 00 00       	call   3ebf <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    2a2c:	c7 04 24 8c 53 00 00 	movl   $0x538c,(%esp)
    2a33:	e8 ef 14 00 00       	call   3f27 <mkdir>
    2a38:	85 c0                	test   %eax,%eax
    2a3a:	74 19                	je     2a55 <fourteen+0x6c>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    2a3c:	c7 44 24 04 ac 53 00 	movl   $0x53ac,0x4(%esp)
    2a43:	00 
    2a44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a4b:	e8 f7 15 00 00       	call   4047 <printf>
    exit();
    2a50:	e8 6a 14 00 00       	call   3ebf <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2a55:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2a5c:	00 
    2a5d:	c7 04 24 dc 53 00 00 	movl   $0x53dc,(%esp)
    2a64:	e8 96 14 00 00       	call   3eff <open>
    2a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2a6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2a70:	79 19                	jns    2a8b <fourteen+0xa2>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    2a72:	c7 44 24 04 0c 54 00 	movl   $0x540c,0x4(%esp)
    2a79:	00 
    2a7a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a81:	e8 c1 15 00 00       	call   4047 <printf>
    exit();
    2a86:	e8 34 14 00 00       	call   3ebf <exit>
  }
  close(fd);
    2a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2a8e:	89 04 24             	mov    %eax,(%esp)
    2a91:	e8 51 14 00 00       	call   3ee7 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2a96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2a9d:	00 
    2a9e:	c7 04 24 4c 54 00 00 	movl   $0x544c,(%esp)
    2aa5:	e8 55 14 00 00       	call   3eff <open>
    2aaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2aad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2ab1:	79 19                	jns    2acc <fourteen+0xe3>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    2ab3:	c7 44 24 04 7c 54 00 	movl   $0x547c,0x4(%esp)
    2aba:	00 
    2abb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ac2:	e8 80 15 00 00       	call   4047 <printf>
    exit();
    2ac7:	e8 f3 13 00 00       	call   3ebf <exit>
  }
  close(fd);
    2acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2acf:	89 04 24             	mov    %eax,(%esp)
    2ad2:	e8 10 14 00 00       	call   3ee7 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    2ad7:	c7 04 24 b6 54 00 00 	movl   $0x54b6,(%esp)
    2ade:	e8 44 14 00 00       	call   3f27 <mkdir>
    2ae3:	85 c0                	test   %eax,%eax
    2ae5:	75 19                	jne    2b00 <fourteen+0x117>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    2ae7:	c7 44 24 04 d4 54 00 	movl   $0x54d4,0x4(%esp)
    2aee:	00 
    2aef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2af6:	e8 4c 15 00 00       	call   4047 <printf>
    exit();
    2afb:	e8 bf 13 00 00       	call   3ebf <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    2b00:	c7 04 24 04 55 00 00 	movl   $0x5504,(%esp)
    2b07:	e8 1b 14 00 00       	call   3f27 <mkdir>
    2b0c:	85 c0                	test   %eax,%eax
    2b0e:	75 19                	jne    2b29 <fourteen+0x140>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    2b10:	c7 44 24 04 24 55 00 	movl   $0x5524,0x4(%esp)
    2b17:	00 
    2b18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b1f:	e8 23 15 00 00       	call   4047 <printf>
    exit();
    2b24:	e8 96 13 00 00       	call   3ebf <exit>
  }

  printf(1, "fourteen ok\n");
    2b29:	c7 44 24 04 55 55 00 	movl   $0x5555,0x4(%esp)
    2b30:	00 
    2b31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b38:	e8 0a 15 00 00       	call   4047 <printf>
}
    2b3d:	c9                   	leave  
    2b3e:	c3                   	ret    

00002b3f <rmdot>:

void
rmdot(void)
{
    2b3f:	55                   	push   %ebp
    2b40:	89 e5                	mov    %esp,%ebp
    2b42:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    2b45:	c7 44 24 04 62 55 00 	movl   $0x5562,0x4(%esp)
    2b4c:	00 
    2b4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b54:	e8 ee 14 00 00       	call   4047 <printf>
  if(mkdir("dots") != 0){
    2b59:	c7 04 24 6e 55 00 00 	movl   $0x556e,(%esp)
    2b60:	e8 c2 13 00 00       	call   3f27 <mkdir>
    2b65:	85 c0                	test   %eax,%eax
    2b67:	74 19                	je     2b82 <rmdot+0x43>
    printf(1, "mkdir dots failed\n");
    2b69:	c7 44 24 04 73 55 00 	movl   $0x5573,0x4(%esp)
    2b70:	00 
    2b71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b78:	e8 ca 14 00 00       	call   4047 <printf>
    exit();
    2b7d:	e8 3d 13 00 00       	call   3ebf <exit>
  }
  if(chdir("dots") != 0){
    2b82:	c7 04 24 6e 55 00 00 	movl   $0x556e,(%esp)
    2b89:	e8 a1 13 00 00       	call   3f2f <chdir>
    2b8e:	85 c0                	test   %eax,%eax
    2b90:	74 19                	je     2bab <rmdot+0x6c>
    printf(1, "chdir dots failed\n");
    2b92:	c7 44 24 04 86 55 00 	movl   $0x5586,0x4(%esp)
    2b99:	00 
    2b9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ba1:	e8 a1 14 00 00       	call   4047 <printf>
    exit();
    2ba6:	e8 14 13 00 00       	call   3ebf <exit>
  }
  if(unlink(".") == 0){
    2bab:	c7 04 24 9f 4c 00 00 	movl   $0x4c9f,(%esp)
    2bb2:	e8 58 13 00 00       	call   3f0f <unlink>
    2bb7:	85 c0                	test   %eax,%eax
    2bb9:	75 19                	jne    2bd4 <rmdot+0x95>
    printf(1, "rm . worked!\n");
    2bbb:	c7 44 24 04 99 55 00 	movl   $0x5599,0x4(%esp)
    2bc2:	00 
    2bc3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bca:	e8 78 14 00 00       	call   4047 <printf>
    exit();
    2bcf:	e8 eb 12 00 00       	call   3ebf <exit>
  }
  if(unlink("..") == 0){
    2bd4:	c7 04 24 32 48 00 00 	movl   $0x4832,(%esp)
    2bdb:	e8 2f 13 00 00       	call   3f0f <unlink>
    2be0:	85 c0                	test   %eax,%eax
    2be2:	75 19                	jne    2bfd <rmdot+0xbe>
    printf(1, "rm .. worked!\n");
    2be4:	c7 44 24 04 a7 55 00 	movl   $0x55a7,0x4(%esp)
    2beb:	00 
    2bec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bf3:	e8 4f 14 00 00       	call   4047 <printf>
    exit();
    2bf8:	e8 c2 12 00 00       	call   3ebf <exit>
  }
  if(chdir("/") != 0){
    2bfd:	c7 04 24 86 44 00 00 	movl   $0x4486,(%esp)
    2c04:	e8 26 13 00 00       	call   3f2f <chdir>
    2c09:	85 c0                	test   %eax,%eax
    2c0b:	74 19                	je     2c26 <rmdot+0xe7>
    printf(1, "chdir / failed\n");
    2c0d:	c7 44 24 04 88 44 00 	movl   $0x4488,0x4(%esp)
    2c14:	00 
    2c15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c1c:	e8 26 14 00 00       	call   4047 <printf>
    exit();
    2c21:	e8 99 12 00 00       	call   3ebf <exit>
  }
  if(unlink("dots/.") == 0){
    2c26:	c7 04 24 b6 55 00 00 	movl   $0x55b6,(%esp)
    2c2d:	e8 dd 12 00 00       	call   3f0f <unlink>
    2c32:	85 c0                	test   %eax,%eax
    2c34:	75 19                	jne    2c4f <rmdot+0x110>
    printf(1, "unlink dots/. worked!\n");
    2c36:	c7 44 24 04 bd 55 00 	movl   $0x55bd,0x4(%esp)
    2c3d:	00 
    2c3e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c45:	e8 fd 13 00 00       	call   4047 <printf>
    exit();
    2c4a:	e8 70 12 00 00       	call   3ebf <exit>
  }
  if(unlink("dots/..") == 0){
    2c4f:	c7 04 24 d4 55 00 00 	movl   $0x55d4,(%esp)
    2c56:	e8 b4 12 00 00       	call   3f0f <unlink>
    2c5b:	85 c0                	test   %eax,%eax
    2c5d:	75 19                	jne    2c78 <rmdot+0x139>
    printf(1, "unlink dots/.. worked!\n");
    2c5f:	c7 44 24 04 dc 55 00 	movl   $0x55dc,0x4(%esp)
    2c66:	00 
    2c67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c6e:	e8 d4 13 00 00       	call   4047 <printf>
    exit();
    2c73:	e8 47 12 00 00       	call   3ebf <exit>
  }
  if(unlink("dots") != 0){
    2c78:	c7 04 24 6e 55 00 00 	movl   $0x556e,(%esp)
    2c7f:	e8 8b 12 00 00       	call   3f0f <unlink>
    2c84:	85 c0                	test   %eax,%eax
    2c86:	74 19                	je     2ca1 <rmdot+0x162>
    printf(1, "unlink dots failed!\n");
    2c88:	c7 44 24 04 f4 55 00 	movl   $0x55f4,0x4(%esp)
    2c8f:	00 
    2c90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c97:	e8 ab 13 00 00       	call   4047 <printf>
    exit();
    2c9c:	e8 1e 12 00 00       	call   3ebf <exit>
  }
  printf(1, "rmdot ok\n");
    2ca1:	c7 44 24 04 09 56 00 	movl   $0x5609,0x4(%esp)
    2ca8:	00 
    2ca9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cb0:	e8 92 13 00 00       	call   4047 <printf>
}
    2cb5:	c9                   	leave  
    2cb6:	c3                   	ret    

00002cb7 <dirfile>:

void
dirfile(void)
{
    2cb7:	55                   	push   %ebp
    2cb8:	89 e5                	mov    %esp,%ebp
    2cba:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "dir vs file\n");
    2cbd:	c7 44 24 04 13 56 00 	movl   $0x5613,0x4(%esp)
    2cc4:	00 
    2cc5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ccc:	e8 76 13 00 00       	call   4047 <printf>

  fd = open("dirfile", O_CREATE);
    2cd1:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2cd8:	00 
    2cd9:	c7 04 24 20 56 00 00 	movl   $0x5620,(%esp)
    2ce0:	e8 1a 12 00 00       	call   3eff <open>
    2ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2ce8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2cec:	79 19                	jns    2d07 <dirfile+0x50>
    printf(1, "create dirfile failed\n");
    2cee:	c7 44 24 04 28 56 00 	movl   $0x5628,0x4(%esp)
    2cf5:	00 
    2cf6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cfd:	e8 45 13 00 00       	call   4047 <printf>
    exit();
    2d02:	e8 b8 11 00 00       	call   3ebf <exit>
  }
  close(fd);
    2d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2d0a:	89 04 24             	mov    %eax,(%esp)
    2d0d:	e8 d5 11 00 00       	call   3ee7 <close>
  if(chdir("dirfile") == 0){
    2d12:	c7 04 24 20 56 00 00 	movl   $0x5620,(%esp)
    2d19:	e8 11 12 00 00       	call   3f2f <chdir>
    2d1e:	85 c0                	test   %eax,%eax
    2d20:	75 19                	jne    2d3b <dirfile+0x84>
    printf(1, "chdir dirfile succeeded!\n");
    2d22:	c7 44 24 04 3f 56 00 	movl   $0x563f,0x4(%esp)
    2d29:	00 
    2d2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d31:	e8 11 13 00 00       	call   4047 <printf>
    exit();
    2d36:	e8 84 11 00 00       	call   3ebf <exit>
  }
  fd = open("dirfile/xx", 0);
    2d3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2d42:	00 
    2d43:	c7 04 24 59 56 00 00 	movl   $0x5659,(%esp)
    2d4a:	e8 b0 11 00 00       	call   3eff <open>
    2d4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2d52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2d56:	78 19                	js     2d71 <dirfile+0xba>
    printf(1, "create dirfile/xx succeeded!\n");
    2d58:	c7 44 24 04 64 56 00 	movl   $0x5664,0x4(%esp)
    2d5f:	00 
    2d60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d67:	e8 db 12 00 00       	call   4047 <printf>
    exit();
    2d6c:	e8 4e 11 00 00       	call   3ebf <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    2d71:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2d78:	00 
    2d79:	c7 04 24 59 56 00 00 	movl   $0x5659,(%esp)
    2d80:	e8 7a 11 00 00       	call   3eff <open>
    2d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2d88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2d8c:	78 19                	js     2da7 <dirfile+0xf0>
    printf(1, "create dirfile/xx succeeded!\n");
    2d8e:	c7 44 24 04 64 56 00 	movl   $0x5664,0x4(%esp)
    2d95:	00 
    2d96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d9d:	e8 a5 12 00 00       	call   4047 <printf>
    exit();
    2da2:	e8 18 11 00 00       	call   3ebf <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    2da7:	c7 04 24 59 56 00 00 	movl   $0x5659,(%esp)
    2dae:	e8 74 11 00 00       	call   3f27 <mkdir>
    2db3:	85 c0                	test   %eax,%eax
    2db5:	75 19                	jne    2dd0 <dirfile+0x119>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    2db7:	c7 44 24 04 82 56 00 	movl   $0x5682,0x4(%esp)
    2dbe:	00 
    2dbf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dc6:	e8 7c 12 00 00       	call   4047 <printf>
    exit();
    2dcb:	e8 ef 10 00 00       	call   3ebf <exit>
  }
  if(unlink("dirfile/xx") == 0){
    2dd0:	c7 04 24 59 56 00 00 	movl   $0x5659,(%esp)
    2dd7:	e8 33 11 00 00       	call   3f0f <unlink>
    2ddc:	85 c0                	test   %eax,%eax
    2dde:	75 19                	jne    2df9 <dirfile+0x142>
    printf(1, "unlink dirfile/xx succeeded!\n");
    2de0:	c7 44 24 04 9f 56 00 	movl   $0x569f,0x4(%esp)
    2de7:	00 
    2de8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2def:	e8 53 12 00 00       	call   4047 <printf>
    exit();
    2df4:	e8 c6 10 00 00       	call   3ebf <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    2df9:	c7 44 24 04 59 56 00 	movl   $0x5659,0x4(%esp)
    2e00:	00 
    2e01:	c7 04 24 bd 56 00 00 	movl   $0x56bd,(%esp)
    2e08:	e8 12 11 00 00       	call   3f1f <link>
    2e0d:	85 c0                	test   %eax,%eax
    2e0f:	75 19                	jne    2e2a <dirfile+0x173>
    printf(1, "link to dirfile/xx succeeded!\n");
    2e11:	c7 44 24 04 c4 56 00 	movl   $0x56c4,0x4(%esp)
    2e18:	00 
    2e19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e20:	e8 22 12 00 00       	call   4047 <printf>
    exit();
    2e25:	e8 95 10 00 00       	call   3ebf <exit>
  }
  if(unlink("dirfile") != 0){
    2e2a:	c7 04 24 20 56 00 00 	movl   $0x5620,(%esp)
    2e31:	e8 d9 10 00 00       	call   3f0f <unlink>
    2e36:	85 c0                	test   %eax,%eax
    2e38:	74 19                	je     2e53 <dirfile+0x19c>
    printf(1, "unlink dirfile failed!\n");
    2e3a:	c7 44 24 04 e3 56 00 	movl   $0x56e3,0x4(%esp)
    2e41:	00 
    2e42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e49:	e8 f9 11 00 00       	call   4047 <printf>
    exit();
    2e4e:	e8 6c 10 00 00       	call   3ebf <exit>
  }

  fd = open(".", O_RDWR);
    2e53:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2e5a:	00 
    2e5b:	c7 04 24 9f 4c 00 00 	movl   $0x4c9f,(%esp)
    2e62:	e8 98 10 00 00       	call   3eff <open>
    2e67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2e6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2e6e:	78 19                	js     2e89 <dirfile+0x1d2>
    printf(1, "open . for writing succeeded!\n");
    2e70:	c7 44 24 04 fc 56 00 	movl   $0x56fc,0x4(%esp)
    2e77:	00 
    2e78:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e7f:	e8 c3 11 00 00       	call   4047 <printf>
    exit();
    2e84:	e8 36 10 00 00       	call   3ebf <exit>
  }
  fd = open(".", 0);
    2e89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2e90:	00 
    2e91:	c7 04 24 9f 4c 00 00 	movl   $0x4c9f,(%esp)
    2e98:	e8 62 10 00 00       	call   3eff <open>
    2e9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(write(fd, "x", 1) > 0){
    2ea0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    2ea7:	00 
    2ea8:	c7 44 24 04 eb 48 00 	movl   $0x48eb,0x4(%esp)
    2eaf:	00 
    2eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2eb3:	89 04 24             	mov    %eax,(%esp)
    2eb6:	e8 24 10 00 00       	call   3edf <write>
    2ebb:	85 c0                	test   %eax,%eax
    2ebd:	7e 19                	jle    2ed8 <dirfile+0x221>
    printf(1, "write . succeeded!\n");
    2ebf:	c7 44 24 04 1b 57 00 	movl   $0x571b,0x4(%esp)
    2ec6:	00 
    2ec7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ece:	e8 74 11 00 00       	call   4047 <printf>
    exit();
    2ed3:	e8 e7 0f 00 00       	call   3ebf <exit>
  }
  close(fd);
    2ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2edb:	89 04 24             	mov    %eax,(%esp)
    2ede:	e8 04 10 00 00       	call   3ee7 <close>

  printf(1, "dir vs file OK\n");
    2ee3:	c7 44 24 04 2f 57 00 	movl   $0x572f,0x4(%esp)
    2eea:	00 
    2eeb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ef2:	e8 50 11 00 00       	call   4047 <printf>
}
    2ef7:	c9                   	leave  
    2ef8:	c3                   	ret    

00002ef9 <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    2ef9:	55                   	push   %ebp
    2efa:	89 e5                	mov    %esp,%ebp
    2efc:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(1, "empty file name\n");
    2eff:	c7 44 24 04 3f 57 00 	movl   $0x573f,0x4(%esp)
    2f06:	00 
    2f07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f0e:	e8 34 11 00 00       	call   4047 <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2f13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2f1a:	e9 d2 00 00 00       	jmp    2ff1 <iref+0xf8>
    if(mkdir("irefd") != 0){
    2f1f:	c7 04 24 50 57 00 00 	movl   $0x5750,(%esp)
    2f26:	e8 fc 0f 00 00       	call   3f27 <mkdir>
    2f2b:	85 c0                	test   %eax,%eax
    2f2d:	74 19                	je     2f48 <iref+0x4f>
      printf(1, "mkdir irefd failed\n");
    2f2f:	c7 44 24 04 56 57 00 	movl   $0x5756,0x4(%esp)
    2f36:	00 
    2f37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f3e:	e8 04 11 00 00       	call   4047 <printf>
      exit();
    2f43:	e8 77 0f 00 00       	call   3ebf <exit>
    }
    if(chdir("irefd") != 0){
    2f48:	c7 04 24 50 57 00 00 	movl   $0x5750,(%esp)
    2f4f:	e8 db 0f 00 00       	call   3f2f <chdir>
    2f54:	85 c0                	test   %eax,%eax
    2f56:	74 19                	je     2f71 <iref+0x78>
      printf(1, "chdir irefd failed\n");
    2f58:	c7 44 24 04 6a 57 00 	movl   $0x576a,0x4(%esp)
    2f5f:	00 
    2f60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f67:	e8 db 10 00 00       	call   4047 <printf>
      exit();
    2f6c:	e8 4e 0f 00 00       	call   3ebf <exit>
    }

    mkdir("");
    2f71:	c7 04 24 7e 57 00 00 	movl   $0x577e,(%esp)
    2f78:	e8 aa 0f 00 00       	call   3f27 <mkdir>
    link("README", "");
    2f7d:	c7 44 24 04 7e 57 00 	movl   $0x577e,0x4(%esp)
    2f84:	00 
    2f85:	c7 04 24 bd 56 00 00 	movl   $0x56bd,(%esp)
    2f8c:	e8 8e 0f 00 00       	call   3f1f <link>
    fd = open("", O_CREATE);
    2f91:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2f98:	00 
    2f99:	c7 04 24 7e 57 00 00 	movl   $0x577e,(%esp)
    2fa0:	e8 5a 0f 00 00       	call   3eff <open>
    2fa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    2fa8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2fac:	78 0b                	js     2fb9 <iref+0xc0>
      close(fd);
    2fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2fb1:	89 04 24             	mov    %eax,(%esp)
    2fb4:	e8 2e 0f 00 00       	call   3ee7 <close>
    fd = open("xx", O_CREATE);
    2fb9:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2fc0:	00 
    2fc1:	c7 04 24 7f 57 00 00 	movl   $0x577f,(%esp)
    2fc8:	e8 32 0f 00 00       	call   3eff <open>
    2fcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    2fd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2fd4:	78 0b                	js     2fe1 <iref+0xe8>
      close(fd);
    2fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2fd9:	89 04 24             	mov    %eax,(%esp)
    2fdc:	e8 06 0f 00 00       	call   3ee7 <close>
    unlink("xx");
    2fe1:	c7 04 24 7f 57 00 00 	movl   $0x577f,(%esp)
    2fe8:	e8 22 0f 00 00       	call   3f0f <unlink>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2ff1:	83 7d f4 32          	cmpl   $0x32,-0xc(%ebp)
    2ff5:	0f 8e 24 ff ff ff    	jle    2f1f <iref+0x26>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
    2ffb:	c7 04 24 86 44 00 00 	movl   $0x4486,(%esp)
    3002:	e8 28 0f 00 00       	call   3f2f <chdir>
  printf(1, "empty file name OK\n");
    3007:	c7 44 24 04 82 57 00 	movl   $0x5782,0x4(%esp)
    300e:	00 
    300f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3016:	e8 2c 10 00 00       	call   4047 <printf>
}
    301b:	c9                   	leave  
    301c:	c3                   	ret    

0000301d <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    301d:	55                   	push   %ebp
    301e:	89 e5                	mov    %esp,%ebp
    3020:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
    3023:	c7 44 24 04 96 57 00 	movl   $0x5796,0x4(%esp)
    302a:	00 
    302b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3032:	e8 10 10 00 00       	call   4047 <printf>

  for(n=0; n<1000; n++){
    3037:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    303e:	eb 1f                	jmp    305f <forktest+0x42>
    pid = fork();
    3040:	e8 72 0e 00 00       	call   3eb7 <fork>
    3045:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
    3048:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    304c:	79 02                	jns    3050 <forktest+0x33>
      break;
    304e:	eb 18                	jmp    3068 <forktest+0x4b>
    if(pid == 0)
    3050:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3054:	75 05                	jne    305b <forktest+0x3e>
      exit();
    3056:	e8 64 0e 00 00       	call   3ebf <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
    305b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    305f:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    3066:	7e d8                	jle    3040 <forktest+0x23>
      break;
    if(pid == 0)
      exit();
  }
  
  if(n == 1000){
    3068:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
    306f:	75 19                	jne    308a <forktest+0x6d>
    printf(1, "fork claimed to work 1000 times!\n");
    3071:	c7 44 24 04 a4 57 00 	movl   $0x57a4,0x4(%esp)
    3078:	00 
    3079:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3080:	e8 c2 0f 00 00       	call   4047 <printf>
    exit();
    3085:	e8 35 0e 00 00       	call   3ebf <exit>
  }
  
  for(; n > 0; n--){
    308a:	eb 26                	jmp    30b2 <forktest+0x95>
    if(wait() < 0){
    308c:	e8 36 0e 00 00       	call   3ec7 <wait>
    3091:	85 c0                	test   %eax,%eax
    3093:	79 19                	jns    30ae <forktest+0x91>
      printf(1, "wait stopped early\n");
    3095:	c7 44 24 04 c6 57 00 	movl   $0x57c6,0x4(%esp)
    309c:	00 
    309d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30a4:	e8 9e 0f 00 00       	call   4047 <printf>
      exit();
    30a9:	e8 11 0e 00 00       	call   3ebf <exit>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }
  
  for(; n > 0; n--){
    30ae:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    30b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    30b6:	7f d4                	jg     308c <forktest+0x6f>
      printf(1, "wait stopped early\n");
      exit();
    }
  }
  
  if(wait() != -1){
    30b8:	e8 0a 0e 00 00       	call   3ec7 <wait>
    30bd:	83 f8 ff             	cmp    $0xffffffff,%eax
    30c0:	74 19                	je     30db <forktest+0xbe>
    printf(1, "wait got too many\n");
    30c2:	c7 44 24 04 da 57 00 	movl   $0x57da,0x4(%esp)
    30c9:	00 
    30ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30d1:	e8 71 0f 00 00       	call   4047 <printf>
    exit();
    30d6:	e8 e4 0d 00 00       	call   3ebf <exit>
  }
  
  printf(1, "fork test OK\n");
    30db:	c7 44 24 04 ed 57 00 	movl   $0x57ed,0x4(%esp)
    30e2:	00 
    30e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30ea:	e8 58 0f 00 00       	call   4047 <printf>
}
    30ef:	c9                   	leave  
    30f0:	c3                   	ret    

000030f1 <sbrktest>:

void
sbrktest(void)
{
    30f1:	55                   	push   %ebp
    30f2:	89 e5                	mov    %esp,%ebp
    30f4:	53                   	push   %ebx
    30f5:	81 ec 84 00 00 00    	sub    $0x84,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    30fb:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3100:	c7 44 24 04 fb 57 00 	movl   $0x57fb,0x4(%esp)
    3107:	00 
    3108:	89 04 24             	mov    %eax,(%esp)
    310b:	e8 37 0f 00 00       	call   4047 <printf>
  oldbrk = sbrk(0);
    3110:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3117:	e8 2b 0e 00 00       	call   3f47 <sbrk>
    311c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    311f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3126:	e8 1c 0e 00 00       	call   3f47 <sbrk>
    312b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i;
  for(i = 0; i < 5000; i++){ 
    312e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    3135:	eb 59                	jmp    3190 <sbrktest+0x9f>
    b = sbrk(1);
    3137:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    313e:	e8 04 0e 00 00       	call   3f47 <sbrk>
    3143:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(b != a){
    3146:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3149:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    314c:	74 2f                	je     317d <sbrktest+0x8c>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    314e:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3153:	8b 55 e8             	mov    -0x18(%ebp),%edx
    3156:	89 54 24 10          	mov    %edx,0x10(%esp)
    315a:	8b 55 f4             	mov    -0xc(%ebp),%edx
    315d:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3161:	8b 55 f0             	mov    -0x10(%ebp),%edx
    3164:	89 54 24 08          	mov    %edx,0x8(%esp)
    3168:	c7 44 24 04 06 58 00 	movl   $0x5806,0x4(%esp)
    316f:	00 
    3170:	89 04 24             	mov    %eax,(%esp)
    3173:	e8 cf 0e 00 00       	call   4047 <printf>
      exit();
    3178:	e8 42 0d 00 00       	call   3ebf <exit>
    }
    *b = 1;
    317d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3180:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    3183:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3186:	83 c0 01             	add    $0x1,%eax
    3189:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){ 
    318c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3190:	81 7d f0 87 13 00 00 	cmpl   $0x1387,-0x10(%ebp)
    3197:	7e 9e                	jle    3137 <sbrktest+0x46>
      exit();
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
    3199:	e8 19 0d 00 00       	call   3eb7 <fork>
    319e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    31a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    31a5:	79 1a                	jns    31c1 <sbrktest+0xd0>
    printf(stdout, "sbrk test fork failed\n");
    31a7:	a1 d4 62 00 00       	mov    0x62d4,%eax
    31ac:	c7 44 24 04 21 58 00 	movl   $0x5821,0x4(%esp)
    31b3:	00 
    31b4:	89 04 24             	mov    %eax,(%esp)
    31b7:	e8 8b 0e 00 00       	call   4047 <printf>
    exit();
    31bc:	e8 fe 0c 00 00       	call   3ebf <exit>
  }
  c = sbrk(1);
    31c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31c8:	e8 7a 0d 00 00       	call   3f47 <sbrk>
    31cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  c = sbrk(1);
    31d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31d7:	e8 6b 0d 00 00       	call   3f47 <sbrk>
    31dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a + 1){
    31df:	8b 45 f4             	mov    -0xc(%ebp),%eax
    31e2:	83 c0 01             	add    $0x1,%eax
    31e5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    31e8:	74 1a                	je     3204 <sbrktest+0x113>
    printf(stdout, "sbrk test failed post-fork\n");
    31ea:	a1 d4 62 00 00       	mov    0x62d4,%eax
    31ef:	c7 44 24 04 38 58 00 	movl   $0x5838,0x4(%esp)
    31f6:	00 
    31f7:	89 04 24             	mov    %eax,(%esp)
    31fa:	e8 48 0e 00 00       	call   4047 <printf>
    exit();
    31ff:	e8 bb 0c 00 00       	call   3ebf <exit>
  }
  if(pid == 0)
    3204:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3208:	75 05                	jne    320f <sbrktest+0x11e>
    exit();
    320a:	e8 b0 0c 00 00       	call   3ebf <exit>
  wait();
    320f:	e8 b3 0c 00 00       	call   3ec7 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    3214:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    321b:	e8 27 0d 00 00       	call   3f47 <sbrk>
    3220:	89 45 f4             	mov    %eax,-0xc(%ebp)
  amt = (BIG) - (uint)a;
    3223:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3226:	ba 00 00 40 06       	mov    $0x6400000,%edx
    322b:	29 c2                	sub    %eax,%edx
    322d:	89 d0                	mov    %edx,%eax
    322f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  p = sbrk(amt);
    3232:	8b 45 dc             	mov    -0x24(%ebp),%eax
    3235:	89 04 24             	mov    %eax,(%esp)
    3238:	e8 0a 0d 00 00       	call   3f47 <sbrk>
    323d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (p != a) { 
    3240:	8b 45 d8             	mov    -0x28(%ebp),%eax
    3243:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3246:	74 1a                	je     3262 <sbrktest+0x171>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    3248:	a1 d4 62 00 00       	mov    0x62d4,%eax
    324d:	c7 44 24 04 54 58 00 	movl   $0x5854,0x4(%esp)
    3254:	00 
    3255:	89 04 24             	mov    %eax,(%esp)
    3258:	e8 ea 0d 00 00       	call   4047 <printf>
    exit();
    325d:	e8 5d 0c 00 00       	call   3ebf <exit>
  }
  lastaddr = (char*) (BIG-1);
    3262:	c7 45 d4 ff ff 3f 06 	movl   $0x63fffff,-0x2c(%ebp)
  *lastaddr = 99;
    3269:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    326c:	c6 00 63             	movb   $0x63,(%eax)

  // can one de-allocate?
  a = sbrk(0);
    326f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3276:	e8 cc 0c 00 00       	call   3f47 <sbrk>
    327b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-4096);
    327e:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    3285:	e8 bd 0c 00 00       	call   3f47 <sbrk>
    328a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c == (char*)0xffffffff){
    328d:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    3291:	75 1a                	jne    32ad <sbrktest+0x1bc>
    printf(stdout, "sbrk could not deallocate\n");
    3293:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3298:	c7 44 24 04 92 58 00 	movl   $0x5892,0x4(%esp)
    329f:	00 
    32a0:	89 04 24             	mov    %eax,(%esp)
    32a3:	e8 9f 0d 00 00       	call   4047 <printf>
    exit();
    32a8:	e8 12 0c 00 00       	call   3ebf <exit>
  }
  c = sbrk(0);
    32ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    32b4:	e8 8e 0c 00 00       	call   3f47 <sbrk>
    32b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a - 4096){
    32bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    32bf:	2d 00 10 00 00       	sub    $0x1000,%eax
    32c4:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    32c7:	74 28                	je     32f1 <sbrktest+0x200>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    32c9:	a1 d4 62 00 00       	mov    0x62d4,%eax
    32ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
    32d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
    32d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
    32d8:	89 54 24 08          	mov    %edx,0x8(%esp)
    32dc:	c7 44 24 04 b0 58 00 	movl   $0x58b0,0x4(%esp)
    32e3:	00 
    32e4:	89 04 24             	mov    %eax,(%esp)
    32e7:	e8 5b 0d 00 00       	call   4047 <printf>
    exit();
    32ec:	e8 ce 0b 00 00       	call   3ebf <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    32f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    32f8:	e8 4a 0c 00 00       	call   3f47 <sbrk>
    32fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(4096);
    3300:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    3307:	e8 3b 0c 00 00       	call   3f47 <sbrk>
    330c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a || sbrk(0) != a + 4096){
    330f:	8b 45 e0             	mov    -0x20(%ebp),%eax
    3312:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3315:	75 19                	jne    3330 <sbrktest+0x23f>
    3317:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    331e:	e8 24 0c 00 00       	call   3f47 <sbrk>
    3323:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3326:	81 c2 00 10 00 00    	add    $0x1000,%edx
    332c:	39 d0                	cmp    %edx,%eax
    332e:	74 28                	je     3358 <sbrktest+0x267>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    3330:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3335:	8b 55 e0             	mov    -0x20(%ebp),%edx
    3338:	89 54 24 0c          	mov    %edx,0xc(%esp)
    333c:	8b 55 f4             	mov    -0xc(%ebp),%edx
    333f:	89 54 24 08          	mov    %edx,0x8(%esp)
    3343:	c7 44 24 04 e8 58 00 	movl   $0x58e8,0x4(%esp)
    334a:	00 
    334b:	89 04 24             	mov    %eax,(%esp)
    334e:	e8 f4 0c 00 00       	call   4047 <printf>
    exit();
    3353:	e8 67 0b 00 00       	call   3ebf <exit>
  }
  if(*lastaddr == 99){
    3358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    335b:	0f b6 00             	movzbl (%eax),%eax
    335e:	3c 63                	cmp    $0x63,%al
    3360:	75 1a                	jne    337c <sbrktest+0x28b>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    3362:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3367:	c7 44 24 04 10 59 00 	movl   $0x5910,0x4(%esp)
    336e:	00 
    336f:	89 04 24             	mov    %eax,(%esp)
    3372:	e8 d0 0c 00 00       	call   4047 <printf>
    exit();
    3377:	e8 43 0b 00 00       	call   3ebf <exit>
  }

  a = sbrk(0);
    337c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3383:	e8 bf 0b 00 00       	call   3f47 <sbrk>
    3388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-(sbrk(0) - oldbrk));
    338b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    338e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3395:	e8 ad 0b 00 00       	call   3f47 <sbrk>
    339a:	29 c3                	sub    %eax,%ebx
    339c:	89 d8                	mov    %ebx,%eax
    339e:	89 04 24             	mov    %eax,(%esp)
    33a1:	e8 a1 0b 00 00       	call   3f47 <sbrk>
    33a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a){
    33a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
    33ac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    33af:	74 28                	je     33d9 <sbrktest+0x2e8>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    33b1:	a1 d4 62 00 00       	mov    0x62d4,%eax
    33b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
    33b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
    33bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
    33c0:	89 54 24 08          	mov    %edx,0x8(%esp)
    33c4:	c7 44 24 04 40 59 00 	movl   $0x5940,0x4(%esp)
    33cb:	00 
    33cc:	89 04 24             	mov    %eax,(%esp)
    33cf:	e8 73 0c 00 00       	call   4047 <printf>
    exit();
    33d4:	e8 e6 0a 00 00       	call   3ebf <exit>
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    33d9:	c7 45 f4 00 00 00 80 	movl   $0x80000000,-0xc(%ebp)
    33e0:	eb 7b                	jmp    345d <sbrktest+0x36c>
    ppid = getpid();
    33e2:	e8 58 0b 00 00       	call   3f3f <getpid>
    33e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
    pid = fork();
    33ea:	e8 c8 0a 00 00       	call   3eb7 <fork>
    33ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pid < 0){
    33f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    33f6:	79 1a                	jns    3412 <sbrktest+0x321>
      printf(stdout, "fork failed\n");
    33f8:	a1 d4 62 00 00       	mov    0x62d4,%eax
    33fd:	c7 44 24 04 b5 44 00 	movl   $0x44b5,0x4(%esp)
    3404:	00 
    3405:	89 04 24             	mov    %eax,(%esp)
    3408:	e8 3a 0c 00 00       	call   4047 <printf>
      exit();
    340d:	e8 ad 0a 00 00       	call   3ebf <exit>
    }
    if(pid == 0){
    3412:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3416:	75 39                	jne    3451 <sbrktest+0x360>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    3418:	8b 45 f4             	mov    -0xc(%ebp),%eax
    341b:	0f b6 00             	movzbl (%eax),%eax
    341e:	0f be d0             	movsbl %al,%edx
    3421:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3426:	89 54 24 0c          	mov    %edx,0xc(%esp)
    342a:	8b 55 f4             	mov    -0xc(%ebp),%edx
    342d:	89 54 24 08          	mov    %edx,0x8(%esp)
    3431:	c7 44 24 04 61 59 00 	movl   $0x5961,0x4(%esp)
    3438:	00 
    3439:	89 04 24             	mov    %eax,(%esp)
    343c:	e8 06 0c 00 00       	call   4047 <printf>
      kill(ppid);
    3441:	8b 45 d0             	mov    -0x30(%ebp),%eax
    3444:	89 04 24             	mov    %eax,(%esp)
    3447:	e8 a3 0a 00 00       	call   3eef <kill>
      exit();
    344c:	e8 6e 0a 00 00       	call   3ebf <exit>
    }
    wait();
    3451:	e8 71 0a 00 00       	call   3ec7 <wait>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit();
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    3456:	81 45 f4 50 c3 00 00 	addl   $0xc350,-0xc(%ebp)
    345d:	81 7d f4 7f 84 1e 80 	cmpl   $0x801e847f,-0xc(%ebp)
    3464:	0f 86 78 ff ff ff    	jbe    33e2 <sbrktest+0x2f1>
    wait();
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    346a:	8d 45 c8             	lea    -0x38(%ebp),%eax
    346d:	89 04 24             	mov    %eax,(%esp)
    3470:	e8 5a 0a 00 00       	call   3ecf <pipe>
    3475:	85 c0                	test   %eax,%eax
    3477:	74 19                	je     3492 <sbrktest+0x3a1>
    printf(1, "pipe() failed\n");
    3479:	c7 44 24 04 86 48 00 	movl   $0x4886,0x4(%esp)
    3480:	00 
    3481:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3488:	e8 ba 0b 00 00       	call   4047 <printf>
    exit();
    348d:	e8 2d 0a 00 00       	call   3ebf <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3492:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    3499:	e9 87 00 00 00       	jmp    3525 <sbrktest+0x434>
    if((pids[i] = fork()) == 0){
    349e:	e8 14 0a 00 00       	call   3eb7 <fork>
    34a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
    34a6:	89 44 95 a0          	mov    %eax,-0x60(%ebp,%edx,4)
    34aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
    34ad:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    34b1:	85 c0                	test   %eax,%eax
    34b3:	75 46                	jne    34fb <sbrktest+0x40a>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    34b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    34bc:	e8 86 0a 00 00       	call   3f47 <sbrk>
    34c1:	ba 00 00 40 06       	mov    $0x6400000,%edx
    34c6:	29 c2                	sub    %eax,%edx
    34c8:	89 d0                	mov    %edx,%eax
    34ca:	89 04 24             	mov    %eax,(%esp)
    34cd:	e8 75 0a 00 00       	call   3f47 <sbrk>
      write(fds[1], "x", 1);
    34d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
    34d5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    34dc:	00 
    34dd:	c7 44 24 04 eb 48 00 	movl   $0x48eb,0x4(%esp)
    34e4:	00 
    34e5:	89 04 24             	mov    %eax,(%esp)
    34e8:	e8 f2 09 00 00       	call   3edf <write>
      // sit around until killed
      for(;;) sleep(1000);
    34ed:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
    34f4:	e8 56 0a 00 00       	call   3f4f <sleep>
    34f9:	eb f2                	jmp    34ed <sbrktest+0x3fc>
    }
    if(pids[i] != -1)
    34fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    34fe:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3502:	83 f8 ff             	cmp    $0xffffffff,%eax
    3505:	74 1a                	je     3521 <sbrktest+0x430>
      read(fds[0], &scratch, 1);
    3507:	8b 45 c8             	mov    -0x38(%ebp),%eax
    350a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3511:	00 
    3512:	8d 55 9f             	lea    -0x61(%ebp),%edx
    3515:	89 54 24 04          	mov    %edx,0x4(%esp)
    3519:	89 04 24             	mov    %eax,(%esp)
    351c:	e8 b6 09 00 00       	call   3ed7 <read>
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3521:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3525:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3528:	83 f8 09             	cmp    $0x9,%eax
    352b:	0f 86 6d ff ff ff    	jbe    349e <sbrktest+0x3ad>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    3531:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    3538:	e8 0a 0a 00 00       	call   3f47 <sbrk>
    353d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3540:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    3547:	eb 26                	jmp    356f <sbrktest+0x47e>
    if(pids[i] == -1)
    3549:	8b 45 f0             	mov    -0x10(%ebp),%eax
    354c:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3550:	83 f8 ff             	cmp    $0xffffffff,%eax
    3553:	75 02                	jne    3557 <sbrktest+0x466>
      continue;
    3555:	eb 14                	jmp    356b <sbrktest+0x47a>
    kill(pids[i]);
    3557:	8b 45 f0             	mov    -0x10(%ebp),%eax
    355a:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    355e:	89 04 24             	mov    %eax,(%esp)
    3561:	e8 89 09 00 00       	call   3eef <kill>
    wait();
    3566:	e8 5c 09 00 00       	call   3ec7 <wait>
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    356b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    356f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3572:	83 f8 09             	cmp    $0x9,%eax
    3575:	76 d2                	jbe    3549 <sbrktest+0x458>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    3577:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    357b:	75 1a                	jne    3597 <sbrktest+0x4a6>
    printf(stdout, "failed sbrk leaked memory\n");
    357d:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3582:	c7 44 24 04 7a 59 00 	movl   $0x597a,0x4(%esp)
    3589:	00 
    358a:	89 04 24             	mov    %eax,(%esp)
    358d:	e8 b5 0a 00 00       	call   4047 <printf>
    exit();
    3592:	e8 28 09 00 00       	call   3ebf <exit>
  }

  if(sbrk(0) > oldbrk)
    3597:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    359e:	e8 a4 09 00 00       	call   3f47 <sbrk>
    35a3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    35a6:	76 1b                	jbe    35c3 <sbrktest+0x4d2>
    sbrk(-(sbrk(0) - oldbrk));
    35a8:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    35ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    35b2:	e8 90 09 00 00       	call   3f47 <sbrk>
    35b7:	29 c3                	sub    %eax,%ebx
    35b9:	89 d8                	mov    %ebx,%eax
    35bb:	89 04 24             	mov    %eax,(%esp)
    35be:	e8 84 09 00 00       	call   3f47 <sbrk>

  printf(stdout, "sbrk test OK\n");
    35c3:	a1 d4 62 00 00       	mov    0x62d4,%eax
    35c8:	c7 44 24 04 95 59 00 	movl   $0x5995,0x4(%esp)
    35cf:	00 
    35d0:	89 04 24             	mov    %eax,(%esp)
    35d3:	e8 6f 0a 00 00       	call   4047 <printf>
}
    35d8:	81 c4 84 00 00 00    	add    $0x84,%esp
    35de:	5b                   	pop    %ebx
    35df:	5d                   	pop    %ebp
    35e0:	c3                   	ret    

000035e1 <validateint>:

void
validateint(int *p)
{
    35e1:	55                   	push   %ebp
    35e2:	89 e5                	mov    %esp,%ebp
    35e4:	53                   	push   %ebx
    35e5:	83 ec 10             	sub    $0x10,%esp
  int res;
  asm("mov %%esp, %%ebx\n\t"
    35e8:	b8 0d 00 00 00       	mov    $0xd,%eax
    35ed:	8b 55 08             	mov    0x8(%ebp),%edx
    35f0:	89 d1                	mov    %edx,%ecx
    35f2:	89 e3                	mov    %esp,%ebx
    35f4:	89 cc                	mov    %ecx,%esp
    35f6:	cd 40                	int    $0x40
    35f8:	89 dc                	mov    %ebx,%esp
    35fa:	89 45 f8             	mov    %eax,-0x8(%ebp)
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    35fd:	83 c4 10             	add    $0x10,%esp
    3600:	5b                   	pop    %ebx
    3601:	5d                   	pop    %ebp
    3602:	c3                   	ret    

00003603 <validatetest>:

void
validatetest(void)
{
    3603:	55                   	push   %ebp
    3604:	89 e5                	mov    %esp,%ebp
    3606:	83 ec 28             	sub    $0x28,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    3609:	a1 d4 62 00 00       	mov    0x62d4,%eax
    360e:	c7 44 24 04 a3 59 00 	movl   $0x59a3,0x4(%esp)
    3615:	00 
    3616:	89 04 24             	mov    %eax,(%esp)
    3619:	e8 29 0a 00 00       	call   4047 <printf>
  hi = 1100*1024;
    361e:	c7 45 f0 00 30 11 00 	movl   $0x113000,-0x10(%ebp)

  for(p = 0; p <= (uint)hi; p += 4096){
    3625:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    362c:	eb 7f                	jmp    36ad <validatetest+0xaa>
    if((pid = fork()) == 0){
    362e:	e8 84 08 00 00       	call   3eb7 <fork>
    3633:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3636:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    363a:	75 10                	jne    364c <validatetest+0x49>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
    363c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    363f:	89 04 24             	mov    %eax,(%esp)
    3642:	e8 9a ff ff ff       	call   35e1 <validateint>
      exit();
    3647:	e8 73 08 00 00       	call   3ebf <exit>
    }
    sleep(0);
    364c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3653:	e8 f7 08 00 00       	call   3f4f <sleep>
    sleep(0);
    3658:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    365f:	e8 eb 08 00 00       	call   3f4f <sleep>
    kill(pid);
    3664:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3667:	89 04 24             	mov    %eax,(%esp)
    366a:	e8 80 08 00 00       	call   3eef <kill>
    wait();
    366f:	e8 53 08 00 00       	call   3ec7 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    3674:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3677:	89 44 24 04          	mov    %eax,0x4(%esp)
    367b:	c7 04 24 b2 59 00 00 	movl   $0x59b2,(%esp)
    3682:	e8 98 08 00 00       	call   3f1f <link>
    3687:	83 f8 ff             	cmp    $0xffffffff,%eax
    368a:	74 1a                	je     36a6 <validatetest+0xa3>
      printf(stdout, "link should not succeed\n");
    368c:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3691:	c7 44 24 04 bd 59 00 	movl   $0x59bd,0x4(%esp)
    3698:	00 
    3699:	89 04 24             	mov    %eax,(%esp)
    369c:	e8 a6 09 00 00       	call   4047 <printf>
      exit();
    36a1:	e8 19 08 00 00       	call   3ebf <exit>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    36a6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    36ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
    36b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    36b3:	0f 83 75 ff ff ff    	jae    362e <validatetest+0x2b>
      printf(stdout, "link should not succeed\n");
      exit();
    }
  }

  printf(stdout, "validate ok\n");
    36b9:	a1 d4 62 00 00       	mov    0x62d4,%eax
    36be:	c7 44 24 04 d6 59 00 	movl   $0x59d6,0x4(%esp)
    36c5:	00 
    36c6:	89 04 24             	mov    %eax,(%esp)
    36c9:	e8 79 09 00 00       	call   4047 <printf>
}
    36ce:	c9                   	leave  
    36cf:	c3                   	ret    

000036d0 <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    36d0:	55                   	push   %ebp
    36d1:	89 e5                	mov    %esp,%ebp
    36d3:	83 ec 28             	sub    $0x28,%esp
  int i;

  printf(stdout, "bss test\n");
    36d6:	a1 d4 62 00 00       	mov    0x62d4,%eax
    36db:	c7 44 24 04 e3 59 00 	movl   $0x59e3,0x4(%esp)
    36e2:	00 
    36e3:	89 04 24             	mov    %eax,(%esp)
    36e6:	e8 5c 09 00 00       	call   4047 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    36eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    36f2:	eb 2d                	jmp    3721 <bsstest+0x51>
    if(uninit[i] != '\0'){
    36f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    36f7:	05 a0 63 00 00       	add    $0x63a0,%eax
    36fc:	0f b6 00             	movzbl (%eax),%eax
    36ff:	84 c0                	test   %al,%al
    3701:	74 1a                	je     371d <bsstest+0x4d>
      printf(stdout, "bss test failed\n");
    3703:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3708:	c7 44 24 04 ed 59 00 	movl   $0x59ed,0x4(%esp)
    370f:	00 
    3710:	89 04 24             	mov    %eax,(%esp)
    3713:	e8 2f 09 00 00       	call   4047 <printf>
      exit();
    3718:	e8 a2 07 00 00       	call   3ebf <exit>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    371d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3721:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3724:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    3729:	76 c9                	jbe    36f4 <bsstest+0x24>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit();
    }
  }
  printf(stdout, "bss test ok\n");
    372b:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3730:	c7 44 24 04 fe 59 00 	movl   $0x59fe,0x4(%esp)
    3737:	00 
    3738:	89 04 24             	mov    %eax,(%esp)
    373b:	e8 07 09 00 00       	call   4047 <printf>
}
    3740:	c9                   	leave  
    3741:	c3                   	ret    

00003742 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    3742:	55                   	push   %ebp
    3743:	89 e5                	mov    %esp,%ebp
    3745:	83 ec 28             	sub    $0x28,%esp
  int pid, fd;

  unlink("bigarg-ok");
    3748:	c7 04 24 0b 5a 00 00 	movl   $0x5a0b,(%esp)
    374f:	e8 bb 07 00 00       	call   3f0f <unlink>
  pid = fork();
    3754:	e8 5e 07 00 00       	call   3eb7 <fork>
    3759:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    375c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3760:	0f 85 90 00 00 00    	jne    37f6 <bigargtest+0xb4>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    3766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    376d:	eb 12                	jmp    3781 <bigargtest+0x3f>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    376f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3772:	c7 04 85 00 63 00 00 	movl   $0x5a18,0x6300(,%eax,4)
    3779:	18 5a 00 00 
  unlink("bigarg-ok");
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    377d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3781:	83 7d f4 1e          	cmpl   $0x1e,-0xc(%ebp)
    3785:	7e e8                	jle    376f <bigargtest+0x2d>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    args[MAXARG-1] = 0;
    3787:	c7 05 7c 63 00 00 00 	movl   $0x0,0x637c
    378e:	00 00 00 
    printf(stdout, "bigarg test\n");
    3791:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3796:	c7 44 24 04 f5 5a 00 	movl   $0x5af5,0x4(%esp)
    379d:	00 
    379e:	89 04 24             	mov    %eax,(%esp)
    37a1:	e8 a1 08 00 00       	call   4047 <printf>
    exec("echo", args);
    37a6:	c7 44 24 04 00 63 00 	movl   $0x6300,0x4(%esp)
    37ad:	00 
    37ae:	c7 04 24 14 44 00 00 	movl   $0x4414,(%esp)
    37b5:	e8 3d 07 00 00       	call   3ef7 <exec>
    printf(stdout, "bigarg test ok\n");
    37ba:	a1 d4 62 00 00       	mov    0x62d4,%eax
    37bf:	c7 44 24 04 02 5b 00 	movl   $0x5b02,0x4(%esp)
    37c6:	00 
    37c7:	89 04 24             	mov    %eax,(%esp)
    37ca:	e8 78 08 00 00       	call   4047 <printf>
    fd = open("bigarg-ok", O_CREATE);
    37cf:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    37d6:	00 
    37d7:	c7 04 24 0b 5a 00 00 	movl   $0x5a0b,(%esp)
    37de:	e8 1c 07 00 00       	call   3eff <open>
    37e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    close(fd);
    37e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
    37e9:	89 04 24             	mov    %eax,(%esp)
    37ec:	e8 f6 06 00 00       	call   3ee7 <close>
    exit();
    37f1:	e8 c9 06 00 00       	call   3ebf <exit>
  } else if(pid < 0){
    37f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    37fa:	79 1a                	jns    3816 <bigargtest+0xd4>
    printf(stdout, "bigargtest: fork failed\n");
    37fc:	a1 d4 62 00 00       	mov    0x62d4,%eax
    3801:	c7 44 24 04 12 5b 00 	movl   $0x5b12,0x4(%esp)
    3808:	00 
    3809:	89 04 24             	mov    %eax,(%esp)
    380c:	e8 36 08 00 00       	call   4047 <printf>
    exit();
    3811:	e8 a9 06 00 00       	call   3ebf <exit>
  }
  wait();
    3816:	e8 ac 06 00 00       	call   3ec7 <wait>
  fd = open("bigarg-ok", 0);
    381b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3822:	00 
    3823:	c7 04 24 0b 5a 00 00 	movl   $0x5a0b,(%esp)
    382a:	e8 d0 06 00 00       	call   3eff <open>
    382f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    3832:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3836:	79 1a                	jns    3852 <bigargtest+0x110>
    printf(stdout, "bigarg test failed!\n");
    3838:	a1 d4 62 00 00       	mov    0x62d4,%eax
    383d:	c7 44 24 04 2b 5b 00 	movl   $0x5b2b,0x4(%esp)
    3844:	00 
    3845:	89 04 24             	mov    %eax,(%esp)
    3848:	e8 fa 07 00 00       	call   4047 <printf>
    exit();
    384d:	e8 6d 06 00 00       	call   3ebf <exit>
  }
  close(fd);
    3852:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3855:	89 04 24             	mov    %eax,(%esp)
    3858:	e8 8a 06 00 00       	call   3ee7 <close>
  unlink("bigarg-ok");
    385d:	c7 04 24 0b 5a 00 00 	movl   $0x5a0b,(%esp)
    3864:	e8 a6 06 00 00       	call   3f0f <unlink>
}
    3869:	c9                   	leave  
    386a:	c3                   	ret    

0000386b <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    386b:	55                   	push   %ebp
    386c:	89 e5                	mov    %esp,%ebp
    386e:	53                   	push   %ebx
    386f:	83 ec 74             	sub    $0x74,%esp
  int nfiles;
  int fsblocks = 0;
    3872:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  printf(1, "fsfull test\n");
    3879:	c7 44 24 04 40 5b 00 	movl   $0x5b40,0x4(%esp)
    3880:	00 
    3881:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3888:	e8 ba 07 00 00       	call   4047 <printf>

  for(nfiles = 0; ; nfiles++){
    388d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    char name[64];
    name[0] = 'f';
    3894:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3898:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    389b:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    38a0:	89 c8                	mov    %ecx,%eax
    38a2:	f7 ea                	imul   %edx
    38a4:	c1 fa 06             	sar    $0x6,%edx
    38a7:	89 c8                	mov    %ecx,%eax
    38a9:	c1 f8 1f             	sar    $0x1f,%eax
    38ac:	29 c2                	sub    %eax,%edx
    38ae:	89 d0                	mov    %edx,%eax
    38b0:	83 c0 30             	add    $0x30,%eax
    38b3:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    38b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    38b9:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    38be:	89 d8                	mov    %ebx,%eax
    38c0:	f7 ea                	imul   %edx
    38c2:	c1 fa 06             	sar    $0x6,%edx
    38c5:	89 d8                	mov    %ebx,%eax
    38c7:	c1 f8 1f             	sar    $0x1f,%eax
    38ca:	89 d1                	mov    %edx,%ecx
    38cc:	29 c1                	sub    %eax,%ecx
    38ce:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    38d4:	29 c3                	sub    %eax,%ebx
    38d6:	89 d9                	mov    %ebx,%ecx
    38d8:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    38dd:	89 c8                	mov    %ecx,%eax
    38df:	f7 ea                	imul   %edx
    38e1:	c1 fa 05             	sar    $0x5,%edx
    38e4:	89 c8                	mov    %ecx,%eax
    38e6:	c1 f8 1f             	sar    $0x1f,%eax
    38e9:	29 c2                	sub    %eax,%edx
    38eb:	89 d0                	mov    %edx,%eax
    38ed:	83 c0 30             	add    $0x30,%eax
    38f0:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    38f3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    38f6:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    38fb:	89 d8                	mov    %ebx,%eax
    38fd:	f7 ea                	imul   %edx
    38ff:	c1 fa 05             	sar    $0x5,%edx
    3902:	89 d8                	mov    %ebx,%eax
    3904:	c1 f8 1f             	sar    $0x1f,%eax
    3907:	89 d1                	mov    %edx,%ecx
    3909:	29 c1                	sub    %eax,%ecx
    390b:	6b c1 64             	imul   $0x64,%ecx,%eax
    390e:	29 c3                	sub    %eax,%ebx
    3910:	89 d9                	mov    %ebx,%ecx
    3912:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3917:	89 c8                	mov    %ecx,%eax
    3919:	f7 ea                	imul   %edx
    391b:	c1 fa 02             	sar    $0x2,%edx
    391e:	89 c8                	mov    %ecx,%eax
    3920:	c1 f8 1f             	sar    $0x1f,%eax
    3923:	29 c2                	sub    %eax,%edx
    3925:	89 d0                	mov    %edx,%eax
    3927:	83 c0 30             	add    $0x30,%eax
    392a:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    392d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3930:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3935:	89 c8                	mov    %ecx,%eax
    3937:	f7 ea                	imul   %edx
    3939:	c1 fa 02             	sar    $0x2,%edx
    393c:	89 c8                	mov    %ecx,%eax
    393e:	c1 f8 1f             	sar    $0x1f,%eax
    3941:	29 c2                	sub    %eax,%edx
    3943:	89 d0                	mov    %edx,%eax
    3945:	c1 e0 02             	shl    $0x2,%eax
    3948:	01 d0                	add    %edx,%eax
    394a:	01 c0                	add    %eax,%eax
    394c:	29 c1                	sub    %eax,%ecx
    394e:	89 ca                	mov    %ecx,%edx
    3950:	89 d0                	mov    %edx,%eax
    3952:	83 c0 30             	add    $0x30,%eax
    3955:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3958:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    printf(1, "writing %s\n", name);
    395c:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    395f:	89 44 24 08          	mov    %eax,0x8(%esp)
    3963:	c7 44 24 04 4d 5b 00 	movl   $0x5b4d,0x4(%esp)
    396a:	00 
    396b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3972:	e8 d0 06 00 00       	call   4047 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3977:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    397e:	00 
    397f:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3982:	89 04 24             	mov    %eax,(%esp)
    3985:	e8 75 05 00 00       	call   3eff <open>
    398a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(fd < 0){
    398d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    3991:	79 1d                	jns    39b0 <fsfull+0x145>
      printf(1, "open %s failed\n", name);
    3993:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3996:	89 44 24 08          	mov    %eax,0x8(%esp)
    399a:	c7 44 24 04 59 5b 00 	movl   $0x5b59,0x4(%esp)
    39a1:	00 
    39a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    39a9:	e8 99 06 00 00       	call   4047 <printf>
      break;
    39ae:	eb 74                	jmp    3a24 <fsfull+0x1b9>
    }
    int total = 0;
    39b0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(1){
      int cc = write(fd, buf, 512);
    39b7:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    39be:	00 
    39bf:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    39c6:	00 
    39c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
    39ca:	89 04 24             	mov    %eax,(%esp)
    39cd:	e8 0d 05 00 00       	call   3edf <write>
    39d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(cc < 512)
    39d5:	81 7d e4 ff 01 00 00 	cmpl   $0x1ff,-0x1c(%ebp)
    39dc:	7f 2f                	jg     3a0d <fsfull+0x1a2>
        break;
    39de:	90                   	nop
      total += cc;
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    39df:	8b 45 ec             	mov    -0x14(%ebp),%eax
    39e2:	89 44 24 08          	mov    %eax,0x8(%esp)
    39e6:	c7 44 24 04 69 5b 00 	movl   $0x5b69,0x4(%esp)
    39ed:	00 
    39ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    39f5:	e8 4d 06 00 00       	call   4047 <printf>
    close(fd);
    39fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
    39fd:	89 04 24             	mov    %eax,(%esp)
    3a00:	e8 e2 04 00 00       	call   3ee7 <close>
    if(total == 0)
    3a05:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3a09:	75 10                	jne    3a1b <fsfull+0x1b0>
    3a0b:	eb 0c                	jmp    3a19 <fsfull+0x1ae>
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
      total += cc;
    3a0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3a10:	01 45 ec             	add    %eax,-0x14(%ebp)
      fsblocks++;
    3a13:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    }
    3a17:	eb 9e                	jmp    39b7 <fsfull+0x14c>
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
    3a19:	eb 09                	jmp    3a24 <fsfull+0x1b9>
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");

  for(nfiles = 0; ; nfiles++){
    3a1b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
  }
    3a1f:	e9 70 fe ff ff       	jmp    3894 <fsfull+0x29>

  while(nfiles >= 0){
    3a24:	e9 d7 00 00 00       	jmp    3b00 <fsfull+0x295>
    char name[64];
    name[0] = 'f';
    3a29:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3a2d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3a30:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3a35:	89 c8                	mov    %ecx,%eax
    3a37:	f7 ea                	imul   %edx
    3a39:	c1 fa 06             	sar    $0x6,%edx
    3a3c:	89 c8                	mov    %ecx,%eax
    3a3e:	c1 f8 1f             	sar    $0x1f,%eax
    3a41:	29 c2                	sub    %eax,%edx
    3a43:	89 d0                	mov    %edx,%eax
    3a45:	83 c0 30             	add    $0x30,%eax
    3a48:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3a4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3a4e:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3a53:	89 d8                	mov    %ebx,%eax
    3a55:	f7 ea                	imul   %edx
    3a57:	c1 fa 06             	sar    $0x6,%edx
    3a5a:	89 d8                	mov    %ebx,%eax
    3a5c:	c1 f8 1f             	sar    $0x1f,%eax
    3a5f:	89 d1                	mov    %edx,%ecx
    3a61:	29 c1                	sub    %eax,%ecx
    3a63:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3a69:	29 c3                	sub    %eax,%ebx
    3a6b:	89 d9                	mov    %ebx,%ecx
    3a6d:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3a72:	89 c8                	mov    %ecx,%eax
    3a74:	f7 ea                	imul   %edx
    3a76:	c1 fa 05             	sar    $0x5,%edx
    3a79:	89 c8                	mov    %ecx,%eax
    3a7b:	c1 f8 1f             	sar    $0x1f,%eax
    3a7e:	29 c2                	sub    %eax,%edx
    3a80:	89 d0                	mov    %edx,%eax
    3a82:	83 c0 30             	add    $0x30,%eax
    3a85:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3a88:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3a8b:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3a90:	89 d8                	mov    %ebx,%eax
    3a92:	f7 ea                	imul   %edx
    3a94:	c1 fa 05             	sar    $0x5,%edx
    3a97:	89 d8                	mov    %ebx,%eax
    3a99:	c1 f8 1f             	sar    $0x1f,%eax
    3a9c:	89 d1                	mov    %edx,%ecx
    3a9e:	29 c1                	sub    %eax,%ecx
    3aa0:	6b c1 64             	imul   $0x64,%ecx,%eax
    3aa3:	29 c3                	sub    %eax,%ebx
    3aa5:	89 d9                	mov    %ebx,%ecx
    3aa7:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3aac:	89 c8                	mov    %ecx,%eax
    3aae:	f7 ea                	imul   %edx
    3ab0:	c1 fa 02             	sar    $0x2,%edx
    3ab3:	89 c8                	mov    %ecx,%eax
    3ab5:	c1 f8 1f             	sar    $0x1f,%eax
    3ab8:	29 c2                	sub    %eax,%edx
    3aba:	89 d0                	mov    %edx,%eax
    3abc:	83 c0 30             	add    $0x30,%eax
    3abf:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    3ac2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3ac5:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3aca:	89 c8                	mov    %ecx,%eax
    3acc:	f7 ea                	imul   %edx
    3ace:	c1 fa 02             	sar    $0x2,%edx
    3ad1:	89 c8                	mov    %ecx,%eax
    3ad3:	c1 f8 1f             	sar    $0x1f,%eax
    3ad6:	29 c2                	sub    %eax,%edx
    3ad8:	89 d0                	mov    %edx,%eax
    3ada:	c1 e0 02             	shl    $0x2,%eax
    3add:	01 d0                	add    %edx,%eax
    3adf:	01 c0                	add    %eax,%eax
    3ae1:	29 c1                	sub    %eax,%ecx
    3ae3:	89 ca                	mov    %ecx,%edx
    3ae5:	89 d0                	mov    %edx,%eax
    3ae7:	83 c0 30             	add    $0x30,%eax
    3aea:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3aed:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    unlink(name);
    3af1:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3af4:	89 04 24             	mov    %eax,(%esp)
    3af7:	e8 13 04 00 00       	call   3f0f <unlink>
    nfiles--;
    3afc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    3b00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3b04:	0f 89 1f ff ff ff    	jns    3a29 <fsfull+0x1be>
    name[5] = '\0';
    unlink(name);
    nfiles--;
  }

  printf(1, "fsfull test finished\n");
    3b0a:	c7 44 24 04 79 5b 00 	movl   $0x5b79,0x4(%esp)
    3b11:	00 
    3b12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b19:	e8 29 05 00 00       	call   4047 <printf>
}
    3b1e:	83 c4 74             	add    $0x74,%esp
    3b21:	5b                   	pop    %ebx
    3b22:	5d                   	pop    %ebp
    3b23:	c3                   	ret    

00003b24 <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    3b24:	55                   	push   %ebp
    3b25:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    3b27:	a1 d8 62 00 00       	mov    0x62d8,%eax
    3b2c:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
    3b32:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    3b37:	a3 d8 62 00 00       	mov    %eax,0x62d8
  return randstate;
    3b3c:	a1 d8 62 00 00       	mov    0x62d8,%eax
}
    3b41:	5d                   	pop    %ebp
    3b42:	c3                   	ret    

00003b43 <main>:

int
main(int argc, char *argv[])
{
    3b43:	55                   	push   %ebp
    3b44:	89 e5                	mov    %esp,%ebp
    3b46:	83 e4 f0             	and    $0xfffffff0,%esp
    3b49:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
    3b4c:	c7 44 24 04 8f 5b 00 	movl   $0x5b8f,0x4(%esp)
    3b53:	00 
    3b54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b5b:	e8 e7 04 00 00       	call   4047 <printf>

  if(open("usertests.ran", 0) >= 0){
    3b60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3b67:	00 
    3b68:	c7 04 24 a3 5b 00 00 	movl   $0x5ba3,(%esp)
    3b6f:	e8 8b 03 00 00       	call   3eff <open>
    3b74:	85 c0                	test   %eax,%eax
    3b76:	78 19                	js     3b91 <main+0x4e>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    3b78:	c7 44 24 04 b4 5b 00 	movl   $0x5bb4,0x4(%esp)
    3b7f:	00 
    3b80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b87:	e8 bb 04 00 00       	call   4047 <printf>
    exit();
    3b8c:	e8 2e 03 00 00       	call   3ebf <exit>
  }
  close(open("usertests.ran", O_CREATE));
    3b91:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3b98:	00 
    3b99:	c7 04 24 a3 5b 00 00 	movl   $0x5ba3,(%esp)
    3ba0:	e8 5a 03 00 00       	call   3eff <open>
    3ba5:	89 04 24             	mov    %eax,(%esp)
    3ba8:	e8 3a 03 00 00       	call   3ee7 <close>
  createdelete();
    3bad:	e8 df d6 ff ff       	call   1291 <createdelete>
  linkunlink();
    3bb2:	e8 1e e1 ff ff       	call   1cd5 <linkunlink>
  concreate();
    3bb7:	e8 66 dd ff ff       	call   1922 <concreate>
  fourfiles();
    3bbc:	e8 68 d4 ff ff       	call   1029 <fourfiles>
  sharedfd();
    3bc1:	e8 56 d2 ff ff       	call   e1c <sharedfd>

  bigargtest();
    3bc6:	e8 77 fb ff ff       	call   3742 <bigargtest>
  bigwrite();
    3bcb:	e8 e6 ea ff ff       	call   26b6 <bigwrite>
  bigargtest();
    3bd0:	e8 6d fb ff ff       	call   3742 <bigargtest>
  bsstest();
    3bd5:	e8 f6 fa ff ff       	call   36d0 <bsstest>
  sbrktest();
    3bda:	e8 12 f5 ff ff       	call   30f1 <sbrktest>
  validatetest();
    3bdf:	e8 1f fa ff ff       	call   3603 <validatetest>

  opentest();
    3be4:	e8 de c6 ff ff       	call   2c7 <opentest>
  writetest();
    3be9:	e8 84 c7 ff ff       	call   372 <writetest>
  writetest1();
    3bee:	e8 94 c9 ff ff       	call   587 <writetest1>
  createtest();
    3bf3:	e8 9a cb ff ff       	call   792 <createtest>

  openiputtest();
    3bf8:	e8 c9 c5 ff ff       	call   1c6 <openiputtest>
  exitiputtest();
    3bfd:	e8 d8 c4 ff ff       	call   da <exitiputtest>
  iputtest();
    3c02:	e8 f9 c3 ff ff       	call   0 <iputtest>

  mem();
    3c07:	e8 2b d1 ff ff       	call   d37 <mem>
  pipe1();
    3c0c:	e8 62 cd ff ff       	call   973 <pipe1>
  preempt();
    3c11:	e8 4a cf ff ff       	call   b60 <preempt>
  exitwait();
    3c16:	e8 9e d0 ff ff       	call   cb9 <exitwait>

  rmdot();
    3c1b:	e8 1f ef ff ff       	call   2b3f <rmdot>
  fourteen();
    3c20:	e8 c4 ed ff ff       	call   29e9 <fourteen>
  bigfile();
    3c25:	e8 94 eb ff ff       	call   27be <bigfile>
  subdir();
    3c2a:	e8 41 e3 ff ff       	call   1f70 <subdir>
  linktest();
    3c2f:	e8 a5 da ff ff       	call   16d9 <linktest>
  unlinkread();
    3c34:	e8 cb d8 ff ff       	call   1504 <unlinkread>
  dirfile();
    3c39:	e8 79 f0 ff ff       	call   2cb7 <dirfile>
  iref();
    3c3e:	e8 b6 f2 ff ff       	call   2ef9 <iref>
  forktest();
    3c43:	e8 d5 f3 ff ff       	call   301d <forktest>
  bigdir(); // slow
    3c48:	e8 b6 e1 ff ff       	call   1e03 <bigdir>
  exectest();
    3c4d:	e8 d2 cc ff ff       	call   924 <exectest>

  exit();
    3c52:	e8 68 02 00 00       	call   3ebf <exit>

00003c57 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    3c57:	55                   	push   %ebp
    3c58:	89 e5                	mov    %esp,%ebp
    3c5a:	57                   	push   %edi
    3c5b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    3c5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
    3c5f:	8b 55 10             	mov    0x10(%ebp),%edx
    3c62:	8b 45 0c             	mov    0xc(%ebp),%eax
    3c65:	89 cb                	mov    %ecx,%ebx
    3c67:	89 df                	mov    %ebx,%edi
    3c69:	89 d1                	mov    %edx,%ecx
    3c6b:	fc                   	cld    
    3c6c:	f3 aa                	rep stos %al,%es:(%edi)
    3c6e:	89 ca                	mov    %ecx,%edx
    3c70:	89 fb                	mov    %edi,%ebx
    3c72:	89 5d 08             	mov    %ebx,0x8(%ebp)
    3c75:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    3c78:	5b                   	pop    %ebx
    3c79:	5f                   	pop    %edi
    3c7a:	5d                   	pop    %ebp
    3c7b:	c3                   	ret    

00003c7c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    3c7c:	55                   	push   %ebp
    3c7d:	89 e5                	mov    %esp,%ebp
    3c7f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    3c82:	8b 45 08             	mov    0x8(%ebp),%eax
    3c85:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    3c88:	90                   	nop
    3c89:	8b 45 08             	mov    0x8(%ebp),%eax
    3c8c:	8d 50 01             	lea    0x1(%eax),%edx
    3c8f:	89 55 08             	mov    %edx,0x8(%ebp)
    3c92:	8b 55 0c             	mov    0xc(%ebp),%edx
    3c95:	8d 4a 01             	lea    0x1(%edx),%ecx
    3c98:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    3c9b:	0f b6 12             	movzbl (%edx),%edx
    3c9e:	88 10                	mov    %dl,(%eax)
    3ca0:	0f b6 00             	movzbl (%eax),%eax
    3ca3:	84 c0                	test   %al,%al
    3ca5:	75 e2                	jne    3c89 <strcpy+0xd>
    ;
  return os;
    3ca7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3caa:	c9                   	leave  
    3cab:	c3                   	ret    

00003cac <strcmp>:

int
strcmp(const char *p, const char *q)
{
    3cac:	55                   	push   %ebp
    3cad:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    3caf:	eb 08                	jmp    3cb9 <strcmp+0xd>
    p++, q++;
    3cb1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3cb5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    3cb9:	8b 45 08             	mov    0x8(%ebp),%eax
    3cbc:	0f b6 00             	movzbl (%eax),%eax
    3cbf:	84 c0                	test   %al,%al
    3cc1:	74 10                	je     3cd3 <strcmp+0x27>
    3cc3:	8b 45 08             	mov    0x8(%ebp),%eax
    3cc6:	0f b6 10             	movzbl (%eax),%edx
    3cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
    3ccc:	0f b6 00             	movzbl (%eax),%eax
    3ccf:	38 c2                	cmp    %al,%dl
    3cd1:	74 de                	je     3cb1 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    3cd3:	8b 45 08             	mov    0x8(%ebp),%eax
    3cd6:	0f b6 00             	movzbl (%eax),%eax
    3cd9:	0f b6 d0             	movzbl %al,%edx
    3cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
    3cdf:	0f b6 00             	movzbl (%eax),%eax
    3ce2:	0f b6 c0             	movzbl %al,%eax
    3ce5:	29 c2                	sub    %eax,%edx
    3ce7:	89 d0                	mov    %edx,%eax
}
    3ce9:	5d                   	pop    %ebp
    3cea:	c3                   	ret    

00003ceb <strlen>:

uint
strlen(char *s)
{
    3ceb:	55                   	push   %ebp
    3cec:	89 e5                	mov    %esp,%ebp
    3cee:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    3cf1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    3cf8:	eb 04                	jmp    3cfe <strlen+0x13>
    3cfa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    3cfe:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3d01:	8b 45 08             	mov    0x8(%ebp),%eax
    3d04:	01 d0                	add    %edx,%eax
    3d06:	0f b6 00             	movzbl (%eax),%eax
    3d09:	84 c0                	test   %al,%al
    3d0b:	75 ed                	jne    3cfa <strlen+0xf>
    ;
  return n;
    3d0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3d10:	c9                   	leave  
    3d11:	c3                   	ret    

00003d12 <memset>:

void*
memset(void *dst, int c, uint n)
{
    3d12:	55                   	push   %ebp
    3d13:	89 e5                	mov    %esp,%ebp
    3d15:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    3d18:	8b 45 10             	mov    0x10(%ebp),%eax
    3d1b:	89 44 24 08          	mov    %eax,0x8(%esp)
    3d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d22:	89 44 24 04          	mov    %eax,0x4(%esp)
    3d26:	8b 45 08             	mov    0x8(%ebp),%eax
    3d29:	89 04 24             	mov    %eax,(%esp)
    3d2c:	e8 26 ff ff ff       	call   3c57 <stosb>
  return dst;
    3d31:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3d34:	c9                   	leave  
    3d35:	c3                   	ret    

00003d36 <strchr>:

char*
strchr(const char *s, char c)
{
    3d36:	55                   	push   %ebp
    3d37:	89 e5                	mov    %esp,%ebp
    3d39:	83 ec 04             	sub    $0x4,%esp
    3d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d3f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    3d42:	eb 14                	jmp    3d58 <strchr+0x22>
    if(*s == c)
    3d44:	8b 45 08             	mov    0x8(%ebp),%eax
    3d47:	0f b6 00             	movzbl (%eax),%eax
    3d4a:	3a 45 fc             	cmp    -0x4(%ebp),%al
    3d4d:	75 05                	jne    3d54 <strchr+0x1e>
      return (char*)s;
    3d4f:	8b 45 08             	mov    0x8(%ebp),%eax
    3d52:	eb 13                	jmp    3d67 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    3d54:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3d58:	8b 45 08             	mov    0x8(%ebp),%eax
    3d5b:	0f b6 00             	movzbl (%eax),%eax
    3d5e:	84 c0                	test   %al,%al
    3d60:	75 e2                	jne    3d44 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    3d62:	b8 00 00 00 00       	mov    $0x0,%eax
}
    3d67:	c9                   	leave  
    3d68:	c3                   	ret    

00003d69 <gets>:

char*
gets(char *buf, int max)
{
    3d69:	55                   	push   %ebp
    3d6a:	89 e5                	mov    %esp,%ebp
    3d6c:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3d6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3d76:	eb 4c                	jmp    3dc4 <gets+0x5b>
    cc = read(0, &c, 1);
    3d78:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3d7f:	00 
    3d80:	8d 45 ef             	lea    -0x11(%ebp),%eax
    3d83:	89 44 24 04          	mov    %eax,0x4(%esp)
    3d87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3d8e:	e8 44 01 00 00       	call   3ed7 <read>
    3d93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    3d96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3d9a:	7f 02                	jg     3d9e <gets+0x35>
      break;
    3d9c:	eb 31                	jmp    3dcf <gets+0x66>
    buf[i++] = c;
    3d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3da1:	8d 50 01             	lea    0x1(%eax),%edx
    3da4:	89 55 f4             	mov    %edx,-0xc(%ebp)
    3da7:	89 c2                	mov    %eax,%edx
    3da9:	8b 45 08             	mov    0x8(%ebp),%eax
    3dac:	01 c2                	add    %eax,%edx
    3dae:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3db2:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    3db4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3db8:	3c 0a                	cmp    $0xa,%al
    3dba:	74 13                	je     3dcf <gets+0x66>
    3dbc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3dc0:	3c 0d                	cmp    $0xd,%al
    3dc2:	74 0b                	je     3dcf <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3dc7:	83 c0 01             	add    $0x1,%eax
    3dca:	3b 45 0c             	cmp    0xc(%ebp),%eax
    3dcd:	7c a9                	jl     3d78 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    3dcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3dd2:	8b 45 08             	mov    0x8(%ebp),%eax
    3dd5:	01 d0                	add    %edx,%eax
    3dd7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    3dda:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3ddd:	c9                   	leave  
    3dde:	c3                   	ret    

00003ddf <stat>:

int
stat(char *n, struct stat *st)
{
    3ddf:	55                   	push   %ebp
    3de0:	89 e5                	mov    %esp,%ebp
    3de2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3de5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3dec:	00 
    3ded:	8b 45 08             	mov    0x8(%ebp),%eax
    3df0:	89 04 24             	mov    %eax,(%esp)
    3df3:	e8 07 01 00 00       	call   3eff <open>
    3df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    3dfb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3dff:	79 07                	jns    3e08 <stat+0x29>
    return -1;
    3e01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    3e06:	eb 23                	jmp    3e2b <stat+0x4c>
  r = fstat(fd, st);
    3e08:	8b 45 0c             	mov    0xc(%ebp),%eax
    3e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
    3e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3e12:	89 04 24             	mov    %eax,(%esp)
    3e15:	e8 fd 00 00 00       	call   3f17 <fstat>
    3e1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    3e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3e20:	89 04 24             	mov    %eax,(%esp)
    3e23:	e8 bf 00 00 00       	call   3ee7 <close>
  return r;
    3e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    3e2b:	c9                   	leave  
    3e2c:	c3                   	ret    

00003e2d <atoi>:

int
atoi(const char *s)
{
    3e2d:	55                   	push   %ebp
    3e2e:	89 e5                	mov    %esp,%ebp
    3e30:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    3e33:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    3e3a:	eb 25                	jmp    3e61 <atoi+0x34>
    n = n*10 + *s++ - '0';
    3e3c:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3e3f:	89 d0                	mov    %edx,%eax
    3e41:	c1 e0 02             	shl    $0x2,%eax
    3e44:	01 d0                	add    %edx,%eax
    3e46:	01 c0                	add    %eax,%eax
    3e48:	89 c1                	mov    %eax,%ecx
    3e4a:	8b 45 08             	mov    0x8(%ebp),%eax
    3e4d:	8d 50 01             	lea    0x1(%eax),%edx
    3e50:	89 55 08             	mov    %edx,0x8(%ebp)
    3e53:	0f b6 00             	movzbl (%eax),%eax
    3e56:	0f be c0             	movsbl %al,%eax
    3e59:	01 c8                	add    %ecx,%eax
    3e5b:	83 e8 30             	sub    $0x30,%eax
    3e5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    3e61:	8b 45 08             	mov    0x8(%ebp),%eax
    3e64:	0f b6 00             	movzbl (%eax),%eax
    3e67:	3c 2f                	cmp    $0x2f,%al
    3e69:	7e 0a                	jle    3e75 <atoi+0x48>
    3e6b:	8b 45 08             	mov    0x8(%ebp),%eax
    3e6e:	0f b6 00             	movzbl (%eax),%eax
    3e71:	3c 39                	cmp    $0x39,%al
    3e73:	7e c7                	jle    3e3c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    3e75:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3e78:	c9                   	leave  
    3e79:	c3                   	ret    

00003e7a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    3e7a:	55                   	push   %ebp
    3e7b:	89 e5                	mov    %esp,%ebp
    3e7d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    3e80:	8b 45 08             	mov    0x8(%ebp),%eax
    3e83:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    3e86:	8b 45 0c             	mov    0xc(%ebp),%eax
    3e89:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    3e8c:	eb 17                	jmp    3ea5 <memmove+0x2b>
    *dst++ = *src++;
    3e8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    3e91:	8d 50 01             	lea    0x1(%eax),%edx
    3e94:	89 55 fc             	mov    %edx,-0x4(%ebp)
    3e97:	8b 55 f8             	mov    -0x8(%ebp),%edx
    3e9a:	8d 4a 01             	lea    0x1(%edx),%ecx
    3e9d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    3ea0:	0f b6 12             	movzbl (%edx),%edx
    3ea3:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    3ea5:	8b 45 10             	mov    0x10(%ebp),%eax
    3ea8:	8d 50 ff             	lea    -0x1(%eax),%edx
    3eab:	89 55 10             	mov    %edx,0x10(%ebp)
    3eae:	85 c0                	test   %eax,%eax
    3eb0:	7f dc                	jg     3e8e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    3eb2:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3eb5:	c9                   	leave  
    3eb6:	c3                   	ret    

00003eb7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3eb7:	b8 01 00 00 00       	mov    $0x1,%eax
    3ebc:	cd 40                	int    $0x40
    3ebe:	c3                   	ret    

00003ebf <exit>:
SYSCALL(exit)
    3ebf:	b8 02 00 00 00       	mov    $0x2,%eax
    3ec4:	cd 40                	int    $0x40
    3ec6:	c3                   	ret    

00003ec7 <wait>:
SYSCALL(wait)
    3ec7:	b8 03 00 00 00       	mov    $0x3,%eax
    3ecc:	cd 40                	int    $0x40
    3ece:	c3                   	ret    

00003ecf <pipe>:
SYSCALL(pipe)
    3ecf:	b8 04 00 00 00       	mov    $0x4,%eax
    3ed4:	cd 40                	int    $0x40
    3ed6:	c3                   	ret    

00003ed7 <read>:
SYSCALL(read)
    3ed7:	b8 05 00 00 00       	mov    $0x5,%eax
    3edc:	cd 40                	int    $0x40
    3ede:	c3                   	ret    

00003edf <write>:
SYSCALL(write)
    3edf:	b8 10 00 00 00       	mov    $0x10,%eax
    3ee4:	cd 40                	int    $0x40
    3ee6:	c3                   	ret    

00003ee7 <close>:
SYSCALL(close)
    3ee7:	b8 15 00 00 00       	mov    $0x15,%eax
    3eec:	cd 40                	int    $0x40
    3eee:	c3                   	ret    

00003eef <kill>:
SYSCALL(kill)
    3eef:	b8 06 00 00 00       	mov    $0x6,%eax
    3ef4:	cd 40                	int    $0x40
    3ef6:	c3                   	ret    

00003ef7 <exec>:
SYSCALL(exec)
    3ef7:	b8 07 00 00 00       	mov    $0x7,%eax
    3efc:	cd 40                	int    $0x40
    3efe:	c3                   	ret    

00003eff <open>:
SYSCALL(open)
    3eff:	b8 0f 00 00 00       	mov    $0xf,%eax
    3f04:	cd 40                	int    $0x40
    3f06:	c3                   	ret    

00003f07 <mknod>:
SYSCALL(mknod)
    3f07:	b8 11 00 00 00       	mov    $0x11,%eax
    3f0c:	cd 40                	int    $0x40
    3f0e:	c3                   	ret    

00003f0f <unlink>:
SYSCALL(unlink)
    3f0f:	b8 12 00 00 00       	mov    $0x12,%eax
    3f14:	cd 40                	int    $0x40
    3f16:	c3                   	ret    

00003f17 <fstat>:
SYSCALL(fstat)
    3f17:	b8 08 00 00 00       	mov    $0x8,%eax
    3f1c:	cd 40                	int    $0x40
    3f1e:	c3                   	ret    

00003f1f <link>:
SYSCALL(link)
    3f1f:	b8 13 00 00 00       	mov    $0x13,%eax
    3f24:	cd 40                	int    $0x40
    3f26:	c3                   	ret    

00003f27 <mkdir>:
SYSCALL(mkdir)
    3f27:	b8 14 00 00 00       	mov    $0x14,%eax
    3f2c:	cd 40                	int    $0x40
    3f2e:	c3                   	ret    

00003f2f <chdir>:
SYSCALL(chdir)
    3f2f:	b8 09 00 00 00       	mov    $0x9,%eax
    3f34:	cd 40                	int    $0x40
    3f36:	c3                   	ret    

00003f37 <dup>:
SYSCALL(dup)
    3f37:	b8 0a 00 00 00       	mov    $0xa,%eax
    3f3c:	cd 40                	int    $0x40
    3f3e:	c3                   	ret    

00003f3f <getpid>:
SYSCALL(getpid)
    3f3f:	b8 0b 00 00 00       	mov    $0xb,%eax
    3f44:	cd 40                	int    $0x40
    3f46:	c3                   	ret    

00003f47 <sbrk>:
SYSCALL(sbrk)
    3f47:	b8 0c 00 00 00       	mov    $0xc,%eax
    3f4c:	cd 40                	int    $0x40
    3f4e:	c3                   	ret    

00003f4f <sleep>:
SYSCALL(sleep)
    3f4f:	b8 0d 00 00 00       	mov    $0xd,%eax
    3f54:	cd 40                	int    $0x40
    3f56:	c3                   	ret    

00003f57 <uptime>:
SYSCALL(uptime)
    3f57:	b8 0e 00 00 00       	mov    $0xe,%eax
    3f5c:	cd 40                	int    $0x40
    3f5e:	c3                   	ret    

00003f5f <mount>:
SYSCALL(mount)
    3f5f:	b8 16 00 00 00       	mov    $0x16,%eax
    3f64:	cd 40                	int    $0x40
    3f66:	c3                   	ret    

00003f67 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    3f67:	55                   	push   %ebp
    3f68:	89 e5                	mov    %esp,%ebp
    3f6a:	83 ec 18             	sub    $0x18,%esp
    3f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
    3f70:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    3f73:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3f7a:	00 
    3f7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
    3f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
    3f82:	8b 45 08             	mov    0x8(%ebp),%eax
    3f85:	89 04 24             	mov    %eax,(%esp)
    3f88:	e8 52 ff ff ff       	call   3edf <write>
}
    3f8d:	c9                   	leave  
    3f8e:	c3                   	ret    

00003f8f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    3f8f:	55                   	push   %ebp
    3f90:	89 e5                	mov    %esp,%ebp
    3f92:	56                   	push   %esi
    3f93:	53                   	push   %ebx
    3f94:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    3f97:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    3f9e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    3fa2:	74 17                	je     3fbb <printint+0x2c>
    3fa4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    3fa8:	79 11                	jns    3fbb <printint+0x2c>
    neg = 1;
    3faa:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    3fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
    3fb4:	f7 d8                	neg    %eax
    3fb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3fb9:	eb 06                	jmp    3fc1 <printint+0x32>
  } else {
    x = xx;
    3fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
    3fbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    3fc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    3fc8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3fcb:	8d 41 01             	lea    0x1(%ecx),%eax
    3fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    3fd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    3fd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3fd7:	ba 00 00 00 00       	mov    $0x0,%edx
    3fdc:	f7 f3                	div    %ebx
    3fde:	89 d0                	mov    %edx,%eax
    3fe0:	0f b6 80 dc 62 00 00 	movzbl 0x62dc(%eax),%eax
    3fe7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    3feb:	8b 75 10             	mov    0x10(%ebp),%esi
    3fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3ff1:	ba 00 00 00 00       	mov    $0x0,%edx
    3ff6:	f7 f6                	div    %esi
    3ff8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3ffb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3fff:	75 c7                	jne    3fc8 <printint+0x39>
  if(neg)
    4001:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4005:	74 10                	je     4017 <printint+0x88>
    buf[i++] = '-';
    4007:	8b 45 f4             	mov    -0xc(%ebp),%eax
    400a:	8d 50 01             	lea    0x1(%eax),%edx
    400d:	89 55 f4             	mov    %edx,-0xc(%ebp)
    4010:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    4015:	eb 1f                	jmp    4036 <printint+0xa7>
    4017:	eb 1d                	jmp    4036 <printint+0xa7>
    putc(fd, buf[i]);
    4019:	8d 55 dc             	lea    -0x24(%ebp),%edx
    401c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    401f:	01 d0                	add    %edx,%eax
    4021:	0f b6 00             	movzbl (%eax),%eax
    4024:	0f be c0             	movsbl %al,%eax
    4027:	89 44 24 04          	mov    %eax,0x4(%esp)
    402b:	8b 45 08             	mov    0x8(%ebp),%eax
    402e:	89 04 24             	mov    %eax,(%esp)
    4031:	e8 31 ff ff ff       	call   3f67 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    4036:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    403a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    403e:	79 d9                	jns    4019 <printint+0x8a>
    putc(fd, buf[i]);
}
    4040:	83 c4 30             	add    $0x30,%esp
    4043:	5b                   	pop    %ebx
    4044:	5e                   	pop    %esi
    4045:	5d                   	pop    %ebp
    4046:	c3                   	ret    

00004047 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    4047:	55                   	push   %ebp
    4048:	89 e5                	mov    %esp,%ebp
    404a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    404d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    4054:	8d 45 0c             	lea    0xc(%ebp),%eax
    4057:	83 c0 04             	add    $0x4,%eax
    405a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    405d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    4064:	e9 7c 01 00 00       	jmp    41e5 <printf+0x19e>
    c = fmt[i] & 0xff;
    4069:	8b 55 0c             	mov    0xc(%ebp),%edx
    406c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    406f:	01 d0                	add    %edx,%eax
    4071:	0f b6 00             	movzbl (%eax),%eax
    4074:	0f be c0             	movsbl %al,%eax
    4077:	25 ff 00 00 00       	and    $0xff,%eax
    407c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    407f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    4083:	75 2c                	jne    40b1 <printf+0x6a>
      if(c == '%'){
    4085:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    4089:	75 0c                	jne    4097 <printf+0x50>
        state = '%';
    408b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    4092:	e9 4a 01 00 00       	jmp    41e1 <printf+0x19a>
      } else {
        putc(fd, c);
    4097:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    409a:	0f be c0             	movsbl %al,%eax
    409d:	89 44 24 04          	mov    %eax,0x4(%esp)
    40a1:	8b 45 08             	mov    0x8(%ebp),%eax
    40a4:	89 04 24             	mov    %eax,(%esp)
    40a7:	e8 bb fe ff ff       	call   3f67 <putc>
    40ac:	e9 30 01 00 00       	jmp    41e1 <printf+0x19a>
      }
    } else if(state == '%'){
    40b1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    40b5:	0f 85 26 01 00 00    	jne    41e1 <printf+0x19a>
      if(c == 'd'){
    40bb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    40bf:	75 2d                	jne    40ee <printf+0xa7>
        printint(fd, *ap, 10, 1);
    40c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    40c4:	8b 00                	mov    (%eax),%eax
    40c6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    40cd:	00 
    40ce:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    40d5:	00 
    40d6:	89 44 24 04          	mov    %eax,0x4(%esp)
    40da:	8b 45 08             	mov    0x8(%ebp),%eax
    40dd:	89 04 24             	mov    %eax,(%esp)
    40e0:	e8 aa fe ff ff       	call   3f8f <printint>
        ap++;
    40e5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    40e9:	e9 ec 00 00 00       	jmp    41da <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    40ee:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    40f2:	74 06                	je     40fa <printf+0xb3>
    40f4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    40f8:	75 2d                	jne    4127 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    40fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
    40fd:	8b 00                	mov    (%eax),%eax
    40ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    4106:	00 
    4107:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    410e:	00 
    410f:	89 44 24 04          	mov    %eax,0x4(%esp)
    4113:	8b 45 08             	mov    0x8(%ebp),%eax
    4116:	89 04 24             	mov    %eax,(%esp)
    4119:	e8 71 fe ff ff       	call   3f8f <printint>
        ap++;
    411e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    4122:	e9 b3 00 00 00       	jmp    41da <printf+0x193>
      } else if(c == 's'){
    4127:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    412b:	75 45                	jne    4172 <printf+0x12b>
        s = (char*)*ap;
    412d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4130:	8b 00                	mov    (%eax),%eax
    4132:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    4135:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    4139:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    413d:	75 09                	jne    4148 <printf+0x101>
          s = "(null)";
    413f:	c7 45 f4 de 5b 00 00 	movl   $0x5bde,-0xc(%ebp)
        while(*s != 0){
    4146:	eb 1e                	jmp    4166 <printf+0x11f>
    4148:	eb 1c                	jmp    4166 <printf+0x11f>
          putc(fd, *s);
    414a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    414d:	0f b6 00             	movzbl (%eax),%eax
    4150:	0f be c0             	movsbl %al,%eax
    4153:	89 44 24 04          	mov    %eax,0x4(%esp)
    4157:	8b 45 08             	mov    0x8(%ebp),%eax
    415a:	89 04 24             	mov    %eax,(%esp)
    415d:	e8 05 fe ff ff       	call   3f67 <putc>
          s++;
    4162:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    4166:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4169:	0f b6 00             	movzbl (%eax),%eax
    416c:	84 c0                	test   %al,%al
    416e:	75 da                	jne    414a <printf+0x103>
    4170:	eb 68                	jmp    41da <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    4172:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    4176:	75 1d                	jne    4195 <printf+0x14e>
        putc(fd, *ap);
    4178:	8b 45 e8             	mov    -0x18(%ebp),%eax
    417b:	8b 00                	mov    (%eax),%eax
    417d:	0f be c0             	movsbl %al,%eax
    4180:	89 44 24 04          	mov    %eax,0x4(%esp)
    4184:	8b 45 08             	mov    0x8(%ebp),%eax
    4187:	89 04 24             	mov    %eax,(%esp)
    418a:	e8 d8 fd ff ff       	call   3f67 <putc>
        ap++;
    418f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    4193:	eb 45                	jmp    41da <printf+0x193>
      } else if(c == '%'){
    4195:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    4199:	75 17                	jne    41b2 <printf+0x16b>
        putc(fd, c);
    419b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    419e:	0f be c0             	movsbl %al,%eax
    41a1:	89 44 24 04          	mov    %eax,0x4(%esp)
    41a5:	8b 45 08             	mov    0x8(%ebp),%eax
    41a8:	89 04 24             	mov    %eax,(%esp)
    41ab:	e8 b7 fd ff ff       	call   3f67 <putc>
    41b0:	eb 28                	jmp    41da <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    41b2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    41b9:	00 
    41ba:	8b 45 08             	mov    0x8(%ebp),%eax
    41bd:	89 04 24             	mov    %eax,(%esp)
    41c0:	e8 a2 fd ff ff       	call   3f67 <putc>
        putc(fd, c);
    41c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    41c8:	0f be c0             	movsbl %al,%eax
    41cb:	89 44 24 04          	mov    %eax,0x4(%esp)
    41cf:	8b 45 08             	mov    0x8(%ebp),%eax
    41d2:	89 04 24             	mov    %eax,(%esp)
    41d5:	e8 8d fd ff ff       	call   3f67 <putc>
      }
      state = 0;
    41da:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    41e1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    41e5:	8b 55 0c             	mov    0xc(%ebp),%edx
    41e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    41eb:	01 d0                	add    %edx,%eax
    41ed:	0f b6 00             	movzbl (%eax),%eax
    41f0:	84 c0                	test   %al,%al
    41f2:	0f 85 71 fe ff ff    	jne    4069 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    41f8:	c9                   	leave  
    41f9:	c3                   	ret    

000041fa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    41fa:	55                   	push   %ebp
    41fb:	89 e5                	mov    %esp,%ebp
    41fd:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    4200:	8b 45 08             	mov    0x8(%ebp),%eax
    4203:	83 e8 08             	sub    $0x8,%eax
    4206:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4209:	a1 88 63 00 00       	mov    0x6388,%eax
    420e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    4211:	eb 24                	jmp    4237 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4213:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4216:	8b 00                	mov    (%eax),%eax
    4218:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    421b:	77 12                	ja     422f <free+0x35>
    421d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4220:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4223:	77 24                	ja     4249 <free+0x4f>
    4225:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4228:	8b 00                	mov    (%eax),%eax
    422a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    422d:	77 1a                	ja     4249 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    422f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4232:	8b 00                	mov    (%eax),%eax
    4234:	89 45 fc             	mov    %eax,-0x4(%ebp)
    4237:	8b 45 f8             	mov    -0x8(%ebp),%eax
    423a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    423d:	76 d4                	jbe    4213 <free+0x19>
    423f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4242:	8b 00                	mov    (%eax),%eax
    4244:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    4247:	76 ca                	jbe    4213 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    4249:	8b 45 f8             	mov    -0x8(%ebp),%eax
    424c:	8b 40 04             	mov    0x4(%eax),%eax
    424f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    4256:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4259:	01 c2                	add    %eax,%edx
    425b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    425e:	8b 00                	mov    (%eax),%eax
    4260:	39 c2                	cmp    %eax,%edx
    4262:	75 24                	jne    4288 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    4264:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4267:	8b 50 04             	mov    0x4(%eax),%edx
    426a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    426d:	8b 00                	mov    (%eax),%eax
    426f:	8b 40 04             	mov    0x4(%eax),%eax
    4272:	01 c2                	add    %eax,%edx
    4274:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4277:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    427a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    427d:	8b 00                	mov    (%eax),%eax
    427f:	8b 10                	mov    (%eax),%edx
    4281:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4284:	89 10                	mov    %edx,(%eax)
    4286:	eb 0a                	jmp    4292 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    4288:	8b 45 fc             	mov    -0x4(%ebp),%eax
    428b:	8b 10                	mov    (%eax),%edx
    428d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4290:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    4292:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4295:	8b 40 04             	mov    0x4(%eax),%eax
    4298:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    429f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42a2:	01 d0                	add    %edx,%eax
    42a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    42a7:	75 20                	jne    42c9 <free+0xcf>
    p->s.size += bp->s.size;
    42a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42ac:	8b 50 04             	mov    0x4(%eax),%edx
    42af:	8b 45 f8             	mov    -0x8(%ebp),%eax
    42b2:	8b 40 04             	mov    0x4(%eax),%eax
    42b5:	01 c2                	add    %eax,%edx
    42b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42ba:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    42bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
    42c0:	8b 10                	mov    (%eax),%edx
    42c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42c5:	89 10                	mov    %edx,(%eax)
    42c7:	eb 08                	jmp    42d1 <free+0xd7>
  } else
    p->s.ptr = bp;
    42c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42cc:	8b 55 f8             	mov    -0x8(%ebp),%edx
    42cf:	89 10                	mov    %edx,(%eax)
  freep = p;
    42d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42d4:	a3 88 63 00 00       	mov    %eax,0x6388
}
    42d9:	c9                   	leave  
    42da:	c3                   	ret    

000042db <morecore>:

static Header*
morecore(uint nu)
{
    42db:	55                   	push   %ebp
    42dc:	89 e5                	mov    %esp,%ebp
    42de:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    42e1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    42e8:	77 07                	ja     42f1 <morecore+0x16>
    nu = 4096;
    42ea:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    42f1:	8b 45 08             	mov    0x8(%ebp),%eax
    42f4:	c1 e0 03             	shl    $0x3,%eax
    42f7:	89 04 24             	mov    %eax,(%esp)
    42fa:	e8 48 fc ff ff       	call   3f47 <sbrk>
    42ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    4302:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    4306:	75 07                	jne    430f <morecore+0x34>
    return 0;
    4308:	b8 00 00 00 00       	mov    $0x0,%eax
    430d:	eb 22                	jmp    4331 <morecore+0x56>
  hp = (Header*)p;
    430f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4312:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    4315:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4318:	8b 55 08             	mov    0x8(%ebp),%edx
    431b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    431e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4321:	83 c0 08             	add    $0x8,%eax
    4324:	89 04 24             	mov    %eax,(%esp)
    4327:	e8 ce fe ff ff       	call   41fa <free>
  return freep;
    432c:	a1 88 63 00 00       	mov    0x6388,%eax
}
    4331:	c9                   	leave  
    4332:	c3                   	ret    

00004333 <malloc>:

void*
malloc(uint nbytes)
{
    4333:	55                   	push   %ebp
    4334:	89 e5                	mov    %esp,%ebp
    4336:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    4339:	8b 45 08             	mov    0x8(%ebp),%eax
    433c:	83 c0 07             	add    $0x7,%eax
    433f:	c1 e8 03             	shr    $0x3,%eax
    4342:	83 c0 01             	add    $0x1,%eax
    4345:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    4348:	a1 88 63 00 00       	mov    0x6388,%eax
    434d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4350:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4354:	75 23                	jne    4379 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    4356:	c7 45 f0 80 63 00 00 	movl   $0x6380,-0x10(%ebp)
    435d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4360:	a3 88 63 00 00       	mov    %eax,0x6388
    4365:	a1 88 63 00 00       	mov    0x6388,%eax
    436a:	a3 80 63 00 00       	mov    %eax,0x6380
    base.s.size = 0;
    436f:	c7 05 84 63 00 00 00 	movl   $0x0,0x6384
    4376:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4379:	8b 45 f0             	mov    -0x10(%ebp),%eax
    437c:	8b 00                	mov    (%eax),%eax
    437e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    4381:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4384:	8b 40 04             	mov    0x4(%eax),%eax
    4387:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    438a:	72 4d                	jb     43d9 <malloc+0xa6>
      if(p->s.size == nunits)
    438c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    438f:	8b 40 04             	mov    0x4(%eax),%eax
    4392:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    4395:	75 0c                	jne    43a3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    4397:	8b 45 f4             	mov    -0xc(%ebp),%eax
    439a:	8b 10                	mov    (%eax),%edx
    439c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    439f:	89 10                	mov    %edx,(%eax)
    43a1:	eb 26                	jmp    43c9 <malloc+0x96>
      else {
        p->s.size -= nunits;
    43a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43a6:	8b 40 04             	mov    0x4(%eax),%eax
    43a9:	2b 45 ec             	sub    -0x14(%ebp),%eax
    43ac:	89 c2                	mov    %eax,%edx
    43ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43b1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    43b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43b7:	8b 40 04             	mov    0x4(%eax),%eax
    43ba:	c1 e0 03             	shl    $0x3,%eax
    43bd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    43c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
    43c6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    43c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    43cc:	a3 88 63 00 00       	mov    %eax,0x6388
      return (void*)(p + 1);
    43d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43d4:	83 c0 08             	add    $0x8,%eax
    43d7:	eb 38                	jmp    4411 <malloc+0xde>
    }
    if(p == freep)
    43d9:	a1 88 63 00 00       	mov    0x6388,%eax
    43de:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    43e1:	75 1b                	jne    43fe <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    43e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    43e6:	89 04 24             	mov    %eax,(%esp)
    43e9:	e8 ed fe ff ff       	call   42db <morecore>
    43ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    43f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    43f5:	75 07                	jne    43fe <malloc+0xcb>
        return 0;
    43f7:	b8 00 00 00 00       	mov    $0x0,%eax
    43fc:	eb 13                	jmp    4411 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    43fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4401:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4404:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4407:	8b 00                	mov    (%eax),%eax
    4409:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    440c:	e9 70 ff ff ff       	jmp    4381 <malloc+0x4e>
}
    4411:	c9                   	leave  
    4412:	c3                   	ret    
