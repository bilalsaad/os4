
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 7c 3f 10 80       	mov    $0x80103f7c,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 7c 8c 10 	movl   $0x80108c7c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100049:	e8 ef 55 00 00       	call   8010563d <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 15 11 80 64 	movl   $0x80111564,0x80111570
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 15 11 80 64 	movl   $0x80111564,0x80111574
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 15 11 80       	mov    0x80111574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 15 11 80       	mov    %eax,0x80111574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801000bd:	e8 9c 55 00 00       	call   8010565e <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 15 11 80       	mov    0x80111574,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100104:	e8 b7 55 00 00       	call   801056c0 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 d6 10 	movl   $0x8010d660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 70 52 00 00       	call   80105394 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 15 11 80       	mov    0x80111570,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010017c:	e8 3f 55 00 00       	call   801056c0 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 83 8c 10 80 	movl   $0x80108c83,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;
  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 36 2e 00 00       	call   8010300e <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 94 8c 10 80 	movl   $0x80108c94,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 f9 2d 00 00       	call   8010300e <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 9b 8c 10 80 	movl   $0x80108c9b,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010023c:	e8 1d 54 00 00       	call   8010565e <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 15 11 80       	mov    0x80111574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 15 11 80       	mov    %eax,0x80111574

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 cb 51 00 00       	call   8010546d <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801002a9:	e8 12 54 00 00       	call   801056c0 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 dc 03 00 00       	call   8010076b <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801003bb:	e8 9e 52 00 00       	call   8010565e <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 a2 8c 10 80 	movl   $0x80108ca2,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 75 03 00 00       	call   8010076b <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec ab 8c 10 80 	movl   $0x80108cab,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 9f 02 00 00       	call   8010076b <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 83 02 00 00       	call   8010076b <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 75 02 00 00       	call   8010076b <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 6a 02 00 00       	call   8010076b <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100533:	e8 88 51 00 00       	call   801056c0 <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 b2 8c 10 80 	movl   $0x80108cb2,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 c1 8c 10 80 	movl   $0x80108cc1,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 7b 51 00 00       	call   8010570f <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 c3 8c 10 80 	movl   $0x80108cc3,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
8010068a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068e:	78 09                	js     80100699 <cgaputc+0xcf>
80100690:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100697:	7e 0c                	jle    801006a5 <cgaputc+0xdb>
    panic("pos under/overflow");
80100699:	c7 04 24 c7 8c 10 80 	movl   $0x80108cc7,(%esp)
801006a0:	e8 95 fe ff ff       	call   8010053a <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006a5:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006ac:	7e 53                	jle    80100701 <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006ae:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006b3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b9:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006be:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c5:	00 
801006c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801006ca:	89 04 24             	mov    %eax,(%esp)
801006cd:	e8 af 52 00 00       	call   80105981 <memmove>
    pos -= 80;
801006d2:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d6:	b8 80 07 00 00       	mov    $0x780,%eax
801006db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006de:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006e1:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006e9:	01 c9                	add    %ecx,%ecx
801006eb:	01 c8                	add    %ecx,%eax
801006ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801006f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f8:	00 
801006f9:	89 04 24             	mov    %eax,(%esp)
801006fc:	e8 b1 51 00 00       	call   801058b2 <memset>
  }
  
  outb(CRTPORT, 14);
80100701:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100708:	00 
80100709:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100710:	e8 b8 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
80100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100718:	c1 f8 08             	sar    $0x8,%eax
8010071b:	0f b6 c0             	movzbl %al,%eax
8010071e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100722:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100729:	e8 9f fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
8010072e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100735:	00 
80100736:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010073d:	e8 8b fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100745:	0f b6 c0             	movzbl %al,%eax
80100748:	89 44 24 04          	mov    %eax,0x4(%esp)
8010074c:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100753:	e8 75 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
80100758:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100760:	01 d2                	add    %edx,%edx
80100762:	01 d0                	add    %edx,%eax
80100764:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100769:	c9                   	leave  
8010076a:	c3                   	ret    

8010076b <consputc>:

void
consputc(int c)
{
8010076b:	55                   	push   %ebp
8010076c:	89 e5                	mov    %esp,%ebp
8010076e:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100771:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
80100776:	85 c0                	test   %eax,%eax
80100778:	74 07                	je     80100781 <consputc+0x16>
    cli();
8010077a:	e8 6c fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
8010077f:	eb fe                	jmp    8010077f <consputc+0x14>
  }

  if(c == BACKSPACE){
80100781:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100788:	75 26                	jne    801007b0 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100791:	e8 29 6b 00 00       	call   801072bf <uartputc>
80100796:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079d:	e8 1d 6b 00 00       	call   801072bf <uartputc>
801007a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a9:	e8 11 6b 00 00       	call   801072bf <uartputc>
801007ae:	eb 0b                	jmp    801007bb <consputc+0x50>
  } else
    uartputc(c);
801007b0:	8b 45 08             	mov    0x8(%ebp),%eax
801007b3:	89 04 24             	mov    %eax,(%esp)
801007b6:	e8 04 6b 00 00       	call   801072bf <uartputc>
  cgaputc(c);
801007bb:	8b 45 08             	mov    0x8(%ebp),%eax
801007be:	89 04 24             	mov    %eax,(%esp)
801007c1:	e8 04 fe ff ff       	call   801005ca <cgaputc>
}
801007c6:	c9                   	leave  
801007c7:	c3                   	ret    

801007c8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007c8:	55                   	push   %ebp
801007c9:	89 e5                	mov    %esp,%ebp
801007cb:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007d5:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801007dc:	e8 7d 4e 00 00       	call   8010565e <acquire>
  while((c = getc()) >= 0){
801007e1:	e9 39 01 00 00       	jmp    8010091f <consoleintr+0x157>
    switch(c){
801007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801007e9:	83 f8 10             	cmp    $0x10,%eax
801007ec:	74 1e                	je     8010080c <consoleintr+0x44>
801007ee:	83 f8 10             	cmp    $0x10,%eax
801007f1:	7f 0a                	jg     801007fd <consoleintr+0x35>
801007f3:	83 f8 08             	cmp    $0x8,%eax
801007f6:	74 66                	je     8010085e <consoleintr+0x96>
801007f8:	e9 93 00 00 00       	jmp    80100890 <consoleintr+0xc8>
801007fd:	83 f8 15             	cmp    $0x15,%eax
80100800:	74 31                	je     80100833 <consoleintr+0x6b>
80100802:	83 f8 7f             	cmp    $0x7f,%eax
80100805:	74 57                	je     8010085e <consoleintr+0x96>
80100807:	e9 84 00 00 00       	jmp    80100890 <consoleintr+0xc8>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010080c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100813:	e9 07 01 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100818:	a1 08 18 11 80       	mov    0x80111808,%eax
8010081d:	83 e8 01             	sub    $0x1,%eax
80100820:	a3 08 18 11 80       	mov    %eax,0x80111808
        consputc(BACKSPACE);
80100825:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010082c:	e8 3a ff ff ff       	call   8010076b <consputc>
80100831:	eb 01                	jmp    80100834 <consoleintr+0x6c>
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100833:	90                   	nop
80100834:	8b 15 08 18 11 80    	mov    0x80111808,%edx
8010083a:	a1 04 18 11 80       	mov    0x80111804,%eax
8010083f:	39 c2                	cmp    %eax,%edx
80100841:	74 16                	je     80100859 <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100843:	a1 08 18 11 80       	mov    0x80111808,%eax
80100848:	83 e8 01             	sub    $0x1,%eax
8010084b:	83 e0 7f             	and    $0x7f,%eax
8010084e:	0f b6 80 80 17 11 80 	movzbl -0x7feee880(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100855:	3c 0a                	cmp    $0xa,%al
80100857:	75 bf                	jne    80100818 <consoleintr+0x50>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100859:	e9 c1 00 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010085e:	8b 15 08 18 11 80    	mov    0x80111808,%edx
80100864:	a1 04 18 11 80       	mov    0x80111804,%eax
80100869:	39 c2                	cmp    %eax,%edx
8010086b:	74 1e                	je     8010088b <consoleintr+0xc3>
        input.e--;
8010086d:	a1 08 18 11 80       	mov    0x80111808,%eax
80100872:	83 e8 01             	sub    $0x1,%eax
80100875:	a3 08 18 11 80       	mov    %eax,0x80111808
        consputc(BACKSPACE);
8010087a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100881:	e8 e5 fe ff ff       	call   8010076b <consputc>
      }
      break;
80100886:	e9 94 00 00 00       	jmp    8010091f <consoleintr+0x157>
8010088b:	e9 8f 00 00 00       	jmp    8010091f <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100894:	0f 84 84 00 00 00    	je     8010091e <consoleintr+0x156>
8010089a:	8b 15 08 18 11 80    	mov    0x80111808,%edx
801008a0:	a1 00 18 11 80       	mov    0x80111800,%eax
801008a5:	29 c2                	sub    %eax,%edx
801008a7:	89 d0                	mov    %edx,%eax
801008a9:	83 f8 7f             	cmp    $0x7f,%eax
801008ac:	77 70                	ja     8010091e <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
801008ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008b2:	74 05                	je     801008b9 <consoleintr+0xf1>
801008b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008b7:	eb 05                	jmp    801008be <consoleintr+0xf6>
801008b9:	b8 0a 00 00 00       	mov    $0xa,%eax
801008be:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008c1:	a1 08 18 11 80       	mov    0x80111808,%eax
801008c6:	8d 50 01             	lea    0x1(%eax),%edx
801008c9:	89 15 08 18 11 80    	mov    %edx,0x80111808
801008cf:	83 e0 7f             	and    $0x7f,%eax
801008d2:	89 c2                	mov    %eax,%edx
801008d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d7:	88 82 80 17 11 80    	mov    %al,-0x7feee880(%edx)
        consputc(c);
801008dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008e0:	89 04 24             	mov    %eax,(%esp)
801008e3:	e8 83 fe ff ff       	call   8010076b <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008e8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801008ec:	74 18                	je     80100906 <consoleintr+0x13e>
801008ee:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801008f2:	74 12                	je     80100906 <consoleintr+0x13e>
801008f4:	a1 08 18 11 80       	mov    0x80111808,%eax
801008f9:	8b 15 00 18 11 80    	mov    0x80111800,%edx
801008ff:	83 ea 80             	sub    $0xffffff80,%edx
80100902:	39 d0                	cmp    %edx,%eax
80100904:	75 18                	jne    8010091e <consoleintr+0x156>
          input.w = input.e;
80100906:	a1 08 18 11 80       	mov    0x80111808,%eax
8010090b:	a3 04 18 11 80       	mov    %eax,0x80111804
          wakeup(&input.r);
80100910:	c7 04 24 00 18 11 80 	movl   $0x80111800,(%esp)
80100917:	e8 51 4b 00 00       	call   8010546d <wakeup>
        }
      }
      break;
8010091c:	eb 00                	jmp    8010091e <consoleintr+0x156>
8010091e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010091f:	8b 45 08             	mov    0x8(%ebp),%eax
80100922:	ff d0                	call   *%eax
80100924:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100927:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010092b:	0f 89 b5 fe ff ff    	jns    801007e6 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100931:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100938:	e8 83 4d 00 00       	call   801056c0 <release>
  if(doprocdump) {
8010093d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100941:	74 05                	je     80100948 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
80100943:	e8 c8 4b 00 00       	call   80105510 <procdump>
  }
}
80100948:	c9                   	leave  
80100949:	c3                   	ret    

8010094a <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010094a:	55                   	push   %ebp
8010094b:	89 e5                	mov    %esp,%ebp
8010094d:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	89 04 24             	mov    %eax,(%esp)
80100956:	e8 79 14 00 00       	call   80101dd4 <iunlock>
  target = n;
8010095b:	8b 45 10             	mov    0x10(%ebp),%eax
8010095e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100961:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100968:	e8 f1 4c 00 00       	call   8010565e <acquire>
  while(n > 0){
8010096d:	e9 aa 00 00 00       	jmp    80100a1c <consoleread+0xd2>
    while(input.r == input.w){
80100972:	eb 42                	jmp    801009b6 <consoleread+0x6c>
      if(proc->killed){
80100974:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010097a:	8b 40 24             	mov    0x24(%eax),%eax
8010097d:	85 c0                	test   %eax,%eax
8010097f:	74 21                	je     801009a2 <consoleread+0x58>
        release(&cons.lock);
80100981:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100988:	e8 33 4d 00 00       	call   801056c0 <release>
        ilock(ip);
8010098d:	8b 45 08             	mov    0x8(%ebp),%eax
80100990:	89 04 24             	mov    %eax,(%esp)
80100993:	e8 7e 12 00 00       	call   80101c16 <ilock>
        return -1;
80100998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010099d:	e9 a5 00 00 00       	jmp    80100a47 <consoleread+0xfd>
      }
      sleep(&input.r, &cons.lock);
801009a2:	c7 44 24 04 c0 c5 10 	movl   $0x8010c5c0,0x4(%esp)
801009a9:	80 
801009aa:	c7 04 24 00 18 11 80 	movl   $0x80111800,(%esp)
801009b1:	e8 de 49 00 00       	call   80105394 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801009b6:	8b 15 00 18 11 80    	mov    0x80111800,%edx
801009bc:	a1 04 18 11 80       	mov    0x80111804,%eax
801009c1:	39 c2                	cmp    %eax,%edx
801009c3:	74 af                	je     80100974 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009c5:	a1 00 18 11 80       	mov    0x80111800,%eax
801009ca:	8d 50 01             	lea    0x1(%eax),%edx
801009cd:	89 15 00 18 11 80    	mov    %edx,0x80111800
801009d3:	83 e0 7f             	and    $0x7f,%eax
801009d6:	0f b6 80 80 17 11 80 	movzbl -0x7feee880(%eax),%eax
801009dd:	0f be c0             	movsbl %al,%eax
801009e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009e3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009e7:	75 19                	jne    80100a02 <consoleread+0xb8>
      if(n < target){
801009e9:	8b 45 10             	mov    0x10(%ebp),%eax
801009ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009ef:	73 0f                	jae    80100a00 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009f1:	a1 00 18 11 80       	mov    0x80111800,%eax
801009f6:	83 e8 01             	sub    $0x1,%eax
801009f9:	a3 00 18 11 80       	mov    %eax,0x80111800
      }
      break;
801009fe:	eb 26                	jmp    80100a26 <consoleread+0xdc>
80100a00:	eb 24                	jmp    80100a26 <consoleread+0xdc>
    }
    *dst++ = c;
80100a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a05:	8d 50 01             	lea    0x1(%eax),%edx
80100a08:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a0e:	88 10                	mov    %dl,(%eax)
    --n;
80100a10:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a14:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a18:	75 02                	jne    80100a1c <consoleread+0xd2>
      break;
80100a1a:	eb 0a                	jmp    80100a26 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a20:	0f 8f 4c ff ff ff    	jg     80100972 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100a26:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a2d:	e8 8e 4c 00 00       	call   801056c0 <release>
  ilock(ip);
80100a32:	8b 45 08             	mov    0x8(%ebp),%eax
80100a35:	89 04 24             	mov    %eax,(%esp)
80100a38:	e8 d9 11 00 00       	call   80101c16 <ilock>

  return target - n;
80100a3d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	29 c2                	sub    %eax,%edx
80100a45:	89 d0                	mov    %edx,%eax
}
80100a47:	c9                   	leave  
80100a48:	c3                   	ret    

80100a49 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a49:	55                   	push   %ebp
80100a4a:	89 e5                	mov    %esp,%ebp
80100a4c:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a52:	89 04 24             	mov    %eax,(%esp)
80100a55:	e8 7a 13 00 00       	call   80101dd4 <iunlock>
  acquire(&cons.lock);
80100a5a:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a61:	e8 f8 4b 00 00       	call   8010565e <acquire>
  for(i = 0; i < n; i++)
80100a66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a6d:	eb 1d                	jmp    80100a8c <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a75:	01 d0                	add    %edx,%eax
80100a77:	0f b6 00             	movzbl (%eax),%eax
80100a7a:	0f be c0             	movsbl %al,%eax
80100a7d:	0f b6 c0             	movzbl %al,%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 e3 fc ff ff       	call   8010076b <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a92:	7c db                	jl     80100a6f <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a94:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a9b:	e8 20 4c 00 00       	call   801056c0 <release>
  ilock(ip);
80100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80100aa3:	89 04 24             	mov    %eax,(%esp)
80100aa6:	e8 6b 11 00 00       	call   80101c16 <ilock>

  return n;
80100aab:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100aae:	c9                   	leave  
80100aaf:	c3                   	ret    

80100ab0 <consoleinit>:

void
consoleinit(void)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100ab6:	c7 44 24 04 da 8c 10 	movl   $0x80108cda,0x4(%esp)
80100abd:	80 
80100abe:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100ac5:	e8 73 4b 00 00       	call   8010563d <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aca:	c7 05 cc 21 11 80 49 	movl   $0x80100a49,0x801121cc
80100ad1:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ad4:	c7 05 c8 21 11 80 4a 	movl   $0x8010094a,0x801121c8
80100adb:	09 10 80 
  cons.locking = 1;
80100ade:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100ae5:	00 00 00 

  picenable(IRQ_KBD);
80100ae8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100aef:	e8 20 3b 00 00       	call   80104614 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100af4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100afb:	00 
80100afc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b03:	e8 c2 26 00 00       	call   801031ca <ioapicenable>
}
80100b08:	c9                   	leave  
80100b09:	c3                   	ret    

80100b0a <exec>:
#include "x86.h"
#include "elf.h"
#define d2 cprintf("%d %s \n", __LINE__, __func__);
int
exec(char *path, char **argv)
{
80100b0a:	55                   	push   %ebp
80100b0b:	89 e5                	mov    %esp,%ebp
80100b0d:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  begin_op();
80100b13:	e8 5d 31 00 00       	call   80103c75 <begin_op>
  if((ip = namei(path)) == 0){
80100b18:	8b 45 08             	mov    0x8(%ebp),%eax
80100b1b:	89 04 24             	mov    %eax,(%esp)
80100b1e:	e8 37 1e 00 00       	call   8010295a <namei>
80100b23:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b26:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b2a:	75 0f                	jne    80100b3b <exec+0x31>
    end_op();
80100b2c:	e8 c8 31 00 00       	call   80103cf9 <end_op>
    return -1;
80100b31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b36:	e9 e8 03 00 00       	jmp    80100f23 <exec+0x419>
  }
  ilock(ip);
80100b3b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b3e:	89 04 24             	mov    %eax,(%esp)
80100b41:	e8 d0 10 00 00       	call   80101c16 <ilock>
  pgdir = 0;
80100b46:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b4d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b54:	00 
80100b55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b5c:	00 
80100b5d:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b63:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b67:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b6a:	89 04 24             	mov    %eax,(%esp)
80100b6d:	e8 88 16 00 00       	call   801021fa <readi>
80100b72:	83 f8 33             	cmp    $0x33,%eax
80100b75:	77 05                	ja     80100b7c <exec+0x72>
    goto bad;
80100b77:	e9 7b 03 00 00       	jmp    80100ef7 <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100b7c:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b82:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b87:	74 05                	je     80100b8e <exec+0x84>
    goto bad;
80100b89:	e9 69 03 00 00       	jmp    80100ef7 <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
80100b8e:	e8 7d 78 00 00       	call   80108410 <setupkvm>
80100b93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b96:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b9a:	75 05                	jne    80100ba1 <exec+0x97>
    goto bad;
80100b9c:	e9 56 03 00 00       	jmp    80100ef7 <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100ba1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ba8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100baf:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bb8:	e9 cb 00 00 00       	jmp    80100c88 <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bc0:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bc7:	00 
80100bc8:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bcc:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bd6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bd9:	89 04 24             	mov    %eax,(%esp)
80100bdc:	e8 19 16 00 00       	call   801021fa <readi>
80100be1:	83 f8 20             	cmp    $0x20,%eax
80100be4:	74 05                	je     80100beb <exec+0xe1>
      goto bad;
80100be6:	e9 0c 03 00 00       	jmp    80100ef7 <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100beb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bf1:	83 f8 01             	cmp    $0x1,%eax
80100bf4:	74 05                	je     80100bfb <exec+0xf1>
      continue;
80100bf6:	e9 80 00 00 00       	jmp    80100c7b <exec+0x171>
    if(ph.memsz < ph.filesz)
80100bfb:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c01:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c07:	39 c2                	cmp    %eax,%edx
80100c09:	73 05                	jae    80100c10 <exec+0x106>
      goto bad;
80100c0b:	e9 e7 02 00 00       	jmp    80100ef7 <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c10:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c16:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c1c:	01 d0                	add    %edx,%eax
80100c1e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c25:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c2c:	89 04 24             	mov    %eax,(%esp)
80100c2f:	e8 aa 7b 00 00       	call   801087de <allocuvm>
80100c34:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c37:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c3b:	75 05                	jne    80100c42 <exec+0x138>
      goto bad;
80100c3d:	e9 b5 02 00 00       	jmp    80100ef7 <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c42:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c48:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c4e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c54:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c58:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c5c:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c5f:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c63:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c6a:	89 04 24             	mov    %eax,(%esp)
80100c6d:	e8 81 7a 00 00       	call   801086f3 <loaduvm>
80100c72:	85 c0                	test   %eax,%eax
80100c74:	79 05                	jns    80100c7b <exec+0x171>
      goto bad;
80100c76:	e9 7c 02 00 00       	jmp    80100ef7 <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c7b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c82:	83 c0 20             	add    $0x20,%eax
80100c85:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c88:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c8f:	0f b7 c0             	movzwl %ax,%eax
80100c92:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c95:	0f 8f 22 ff ff ff    	jg     80100bbd <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c9e:	89 04 24             	mov    %eax,(%esp)
80100ca1:	e8 64 12 00 00       	call   80101f0a <iunlockput>
  end_op();
80100ca6:	e8 4e 30 00 00       	call   80103cf9 <end_op>
  ip = 0;
80100cab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb5:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc5:	05 00 20 00 00       	add    $0x2000,%eax
80100cca:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cce:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cd8:	89 04 24             	mov    %eax,(%esp)
80100cdb:	e8 fe 7a 00 00       	call   801087de <allocuvm>
80100ce0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce7:	75 05                	jne    80100cee <exec+0x1e4>
    goto bad;
80100ce9:	e9 09 02 00 00       	jmp    80100ef7 <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf1:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cfd:	89 04 24             	mov    %eax,(%esp)
80100d00:	e8 09 7d 00 00       	call   80108a0e <clearpteu>
  sp = sz;
80100d05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d08:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d0b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d12:	e9 9a 00 00 00       	jmp    80100db1 <exec+0x2a7>
    if(argc >= MAXARG)
80100d17:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d1b:	76 05                	jbe    80100d22 <exec+0x218>
      goto bad;
80100d1d:	e9 d5 01 00 00       	jmp    80100ef7 <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d2f:	01 d0                	add    %edx,%eax
80100d31:	8b 00                	mov    (%eax),%eax
80100d33:	89 04 24             	mov    %eax,(%esp)
80100d36:	e8 e1 4d 00 00       	call   80105b1c <strlen>
80100d3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d3e:	29 c2                	sub    %eax,%edx
80100d40:	89 d0                	mov    %edx,%eax
80100d42:	83 e8 01             	sub    $0x1,%eax
80100d45:	83 e0 fc             	and    $0xfffffffc,%eax
80100d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d58:	01 d0                	add    %edx,%eax
80100d5a:	8b 00                	mov    (%eax),%eax
80100d5c:	89 04 24             	mov    %eax,(%esp)
80100d5f:	e8 b8 4d 00 00       	call   80105b1c <strlen>
80100d64:	83 c0 01             	add    $0x1,%eax
80100d67:	89 c2                	mov    %eax,%edx
80100d69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d73:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d76:	01 c8                	add    %ecx,%eax
80100d78:	8b 00                	mov    (%eax),%eax
80100d7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d82:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d85:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d89:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d8c:	89 04 24             	mov    %eax,(%esp)
80100d8f:	e8 3f 7e 00 00       	call   80108bd3 <copyout>
80100d94:	85 c0                	test   %eax,%eax
80100d96:	79 05                	jns    80100d9d <exec+0x293>
      goto bad;
80100d98:	e9 5a 01 00 00       	jmp    80100ef7 <exec+0x3ed>
    ustack[3+argc] = sp;
80100d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da0:	8d 50 03             	lea    0x3(%eax),%edx
80100da3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da6:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dad:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100db1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dbe:	01 d0                	add    %edx,%eax
80100dc0:	8b 00                	mov    (%eax),%eax
80100dc2:	85 c0                	test   %eax,%eax
80100dc4:	0f 85 4d ff ff ff    	jne    80100d17 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcd:	83 c0 03             	add    $0x3,%eax
80100dd0:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dd7:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ddb:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100de2:	ff ff ff 
  ustack[1] = argc;
80100de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de8:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df1:	83 c0 01             	add    $0x1,%eax
80100df4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dfb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dfe:	29 d0                	sub    %edx,%eax
80100e00:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e09:	83 c0 04             	add    $0x4,%eax
80100e0c:	c1 e0 02             	shl    $0x2,%eax
80100e0f:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e15:	83 c0 04             	add    $0x4,%eax
80100e18:	c1 e0 02             	shl    $0x2,%eax
80100e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e1f:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e25:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e29:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e33:	89 04 24             	mov    %eax,(%esp)
80100e36:	e8 98 7d 00 00       	call   80108bd3 <copyout>
80100e3b:	85 c0                	test   %eax,%eax
80100e3d:	79 05                	jns    80100e44 <exec+0x33a>
    goto bad;
80100e3f:	e9 b3 00 00 00       	jmp    80100ef7 <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e44:	8b 45 08             	mov    0x8(%ebp),%eax
80100e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e50:	eb 17                	jmp    80100e69 <exec+0x35f>
    if(*s == '/')
80100e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e55:	0f b6 00             	movzbl (%eax),%eax
80100e58:	3c 2f                	cmp    $0x2f,%al
80100e5a:	75 09                	jne    80100e65 <exec+0x35b>
      last = s+1;
80100e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5f:	83 c0 01             	add    $0x1,%eax
80100e62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6c:	0f b6 00             	movzbl (%eax),%eax
80100e6f:	84 c0                	test   %al,%al
80100e71:	75 df                	jne    80100e52 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e79:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e7c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e83:	00 
80100e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e87:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e8b:	89 14 24             	mov    %edx,(%esp)
80100e8e:	e8 3f 4c 00 00       	call   80105ad2 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e99:	8b 40 04             	mov    0x4(%eax),%eax
80100e9c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ea8:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eb4:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebc:	8b 40 18             	mov    0x18(%eax),%eax
80100ebf:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ec5:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ec8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ece:	8b 40 18             	mov    0x18(%eax),%eax
80100ed1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ed4:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100edd:	89 04 24             	mov    %eax,(%esp)
80100ee0:	e8 1c 76 00 00       	call   80108501 <switchuvm>
  freevm(oldpgdir);
80100ee5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee8:	89 04 24             	mov    %eax,(%esp)
80100eeb:	e8 84 7a 00 00       	call   80108974 <freevm>
  return 0;
80100ef0:	b8 00 00 00 00       	mov    $0x0,%eax
80100ef5:	eb 2c                	jmp    80100f23 <exec+0x419>

 bad:
  if(pgdir)
80100ef7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100efb:	74 0b                	je     80100f08 <exec+0x3fe>
    freevm(pgdir);
80100efd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f00:	89 04 24             	mov    %eax,(%esp)
80100f03:	e8 6c 7a 00 00       	call   80108974 <freevm>
  if(ip){
80100f08:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f0c:	74 10                	je     80100f1e <exec+0x414>
    iunlockput(ip);
80100f0e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f11:	89 04 24             	mov    %eax,(%esp)
80100f14:	e8 f1 0f 00 00       	call   80101f0a <iunlockput>
    end_op();
80100f19:	e8 db 2d 00 00       	call   80103cf9 <end_op>
  }
  return -1;
80100f1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f23:	c9                   	leave  
80100f24:	c3                   	ret    

80100f25 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f25:	55                   	push   %ebp
80100f26:	89 e5                	mov    %esp,%ebp
80100f28:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f2b:	c7 44 24 04 e2 8c 10 	movl   $0x80108ce2,0x4(%esp)
80100f32:	80 
80100f33:	c7 04 24 20 18 11 80 	movl   $0x80111820,(%esp)
80100f3a:	e8 fe 46 00 00       	call   8010563d <initlock>
}
80100f3f:	c9                   	leave  
80100f40:	c3                   	ret    

80100f41 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f41:	55                   	push   %ebp
80100f42:	89 e5                	mov    %esp,%ebp
80100f44:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f47:	c7 04 24 20 18 11 80 	movl   $0x80111820,(%esp)
80100f4e:	e8 0b 47 00 00       	call   8010565e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f53:	c7 45 f4 54 18 11 80 	movl   $0x80111854,-0xc(%ebp)
80100f5a:	eb 29                	jmp    80100f85 <filealloc+0x44>
    if(f->ref == 0){
80100f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5f:	8b 40 04             	mov    0x4(%eax),%eax
80100f62:	85 c0                	test   %eax,%eax
80100f64:	75 1b                	jne    80100f81 <filealloc+0x40>
      f->ref = 1;
80100f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f69:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f70:	c7 04 24 20 18 11 80 	movl   $0x80111820,(%esp)
80100f77:	e8 44 47 00 00       	call   801056c0 <release>
      return f;
80100f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7f:	eb 1e                	jmp    80100f9f <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f81:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f85:	81 7d f4 b4 21 11 80 	cmpl   $0x801121b4,-0xc(%ebp)
80100f8c:	72 ce                	jb     80100f5c <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f8e:	c7 04 24 20 18 11 80 	movl   $0x80111820,(%esp)
80100f95:	e8 26 47 00 00       	call   801056c0 <release>
  return 0;
80100f9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f9f:	c9                   	leave  
80100fa0:	c3                   	ret    

80100fa1 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fa1:	55                   	push   %ebp
80100fa2:	89 e5                	mov    %esp,%ebp
80100fa4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fa7:	c7 04 24 20 18 11 80 	movl   $0x80111820,(%esp)
80100fae:	e8 ab 46 00 00       	call   8010565e <acquire>
  if(f->ref < 1)
80100fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb6:	8b 40 04             	mov    0x4(%eax),%eax
80100fb9:	85 c0                	test   %eax,%eax
80100fbb:	7f 0c                	jg     80100fc9 <filedup+0x28>
    panic("filedup");
80100fbd:	c7 04 24 e9 8c 10 80 	movl   $0x80108ce9,(%esp)
80100fc4:	e8 71 f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcc:	8b 40 04             	mov    0x4(%eax),%eax
80100fcf:	8d 50 01             	lea    0x1(%eax),%edx
80100fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd5:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fd8:	c7 04 24 20 18 11 80 	movl   $0x80111820,(%esp)
80100fdf:	e8 dc 46 00 00       	call   801056c0 <release>
  return f;
80100fe4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fe7:	c9                   	leave  
80100fe8:	c3                   	ret    

80100fe9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fe9:	55                   	push   %ebp
80100fea:	89 e5                	mov    %esp,%ebp
80100fec:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fef:	c7 04 24 20 18 11 80 	movl   $0x80111820,(%esp)
80100ff6:	e8 63 46 00 00       	call   8010565e <acquire>
  if(f->ref < 1)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7f 0c                	jg     80101011 <fileclose+0x28>
    panic("fileclose");
80101005:	c7 04 24 f1 8c 10 80 	movl   $0x80108cf1,(%esp)
8010100c:	e8 29 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101011:	8b 45 08             	mov    0x8(%ebp),%eax
80101014:	8b 40 04             	mov    0x4(%eax),%eax
80101017:	8d 50 ff             	lea    -0x1(%eax),%edx
8010101a:	8b 45 08             	mov    0x8(%ebp),%eax
8010101d:	89 50 04             	mov    %edx,0x4(%eax)
80101020:	8b 45 08             	mov    0x8(%ebp),%eax
80101023:	8b 40 04             	mov    0x4(%eax),%eax
80101026:	85 c0                	test   %eax,%eax
80101028:	7e 11                	jle    8010103b <fileclose+0x52>
    release(&ftable.lock);
8010102a:	c7 04 24 20 18 11 80 	movl   $0x80111820,(%esp)
80101031:	e8 8a 46 00 00       	call   801056c0 <release>
80101036:	e9 82 00 00 00       	jmp    801010bd <fileclose+0xd4>
    return;
  }
  ff = *f;
8010103b:	8b 45 08             	mov    0x8(%ebp),%eax
8010103e:	8b 10                	mov    (%eax),%edx
80101040:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101043:	8b 50 04             	mov    0x4(%eax),%edx
80101046:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101049:	8b 50 08             	mov    0x8(%eax),%edx
8010104c:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010104f:	8b 50 0c             	mov    0xc(%eax),%edx
80101052:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101055:	8b 50 10             	mov    0x10(%eax),%edx
80101058:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010105b:	8b 40 14             	mov    0x14(%eax),%eax
8010105e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101061:	8b 45 08             	mov    0x8(%ebp),%eax
80101064:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010106b:	8b 45 08             	mov    0x8(%ebp),%eax
8010106e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101074:	c7 04 24 20 18 11 80 	movl   $0x80111820,(%esp)
8010107b:	e8 40 46 00 00       	call   801056c0 <release>
  
  if(ff.type == FD_PIPE)
80101080:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101083:	83 f8 01             	cmp    $0x1,%eax
80101086:	75 18                	jne    801010a0 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101088:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010108c:	0f be d0             	movsbl %al,%edx
8010108f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101092:	89 54 24 04          	mov    %edx,0x4(%esp)
80101096:	89 04 24             	mov    %eax,(%esp)
80101099:	e8 26 38 00 00       	call   801048c4 <pipeclose>
8010109e:	eb 1d                	jmp    801010bd <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010a3:	83 f8 02             	cmp    $0x2,%eax
801010a6:	75 15                	jne    801010bd <fileclose+0xd4>
    begin_op();
801010a8:	e8 c8 2b 00 00       	call   80103c75 <begin_op>
    iput(ff.ip);
801010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010b0:	89 04 24             	mov    %eax,(%esp)
801010b3:	e8 81 0d 00 00       	call   80101e39 <iput>
    end_op();
801010b8:	e8 3c 2c 00 00       	call   80103cf9 <end_op>
  }
}
801010bd:	c9                   	leave  
801010be:	c3                   	ret    

801010bf <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010bf:	55                   	push   %ebp
801010c0:	89 e5                	mov    %esp,%ebp
801010c2:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 00                	mov    (%eax),%eax
801010ca:	83 f8 02             	cmp    $0x2,%eax
801010cd:	75 38                	jne    80101107 <filestat+0x48>
    ilock(f->ip);
801010cf:	8b 45 08             	mov    0x8(%ebp),%eax
801010d2:	8b 40 10             	mov    0x10(%eax),%eax
801010d5:	89 04 24             	mov    %eax,(%esp)
801010d8:	e8 39 0b 00 00       	call   80101c16 <ilock>
    stati(f->ip, st);
801010dd:	8b 45 08             	mov    0x8(%ebp),%eax
801010e0:	8b 40 10             	mov    0x10(%eax),%eax
801010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801010e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801010ea:	89 04 24             	mov    %eax,(%esp)
801010ed:	e8 9f 10 00 00       	call   80102191 <stati>
    iunlock(f->ip);
801010f2:	8b 45 08             	mov    0x8(%ebp),%eax
801010f5:	8b 40 10             	mov    0x10(%eax),%eax
801010f8:	89 04 24             	mov    %eax,(%esp)
801010fb:	e8 d4 0c 00 00       	call   80101dd4 <iunlock>
    return 0;
80101100:	b8 00 00 00 00       	mov    $0x0,%eax
80101105:	eb 05                	jmp    8010110c <filestat+0x4d>
  }
  return -1;
80101107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010110c:	c9                   	leave  
8010110d:	c3                   	ret    

8010110e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010110e:	55                   	push   %ebp
8010110f:	89 e5                	mov    %esp,%ebp
80101111:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101114:	8b 45 08             	mov    0x8(%ebp),%eax
80101117:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010111b:	84 c0                	test   %al,%al
8010111d:	75 0a                	jne    80101129 <fileread+0x1b>
    return -1;
8010111f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101124:	e9 9f 00 00 00       	jmp    801011c8 <fileread+0xba>
  if(f->type == FD_PIPE)
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 00                	mov    (%eax),%eax
8010112e:	83 f8 01             	cmp    $0x1,%eax
80101131:	75 1e                	jne    80101151 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101133:	8b 45 08             	mov    0x8(%ebp),%eax
80101136:	8b 40 0c             	mov    0xc(%eax),%eax
80101139:	8b 55 10             	mov    0x10(%ebp),%edx
8010113c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101140:	8b 55 0c             	mov    0xc(%ebp),%edx
80101143:	89 54 24 04          	mov    %edx,0x4(%esp)
80101147:	89 04 24             	mov    %eax,(%esp)
8010114a:	e8 f6 38 00 00       	call   80104a45 <piperead>
8010114f:	eb 77                	jmp    801011c8 <fileread+0xba>
  if(f->type == FD_INODE){
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
80101154:	8b 00                	mov    (%eax),%eax
80101156:	83 f8 02             	cmp    $0x2,%eax
80101159:	75 61                	jne    801011bc <fileread+0xae>
    ilock(f->ip);
8010115b:	8b 45 08             	mov    0x8(%ebp),%eax
8010115e:	8b 40 10             	mov    0x10(%eax),%eax
80101161:	89 04 24             	mov    %eax,(%esp)
80101164:	e8 ad 0a 00 00       	call   80101c16 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101169:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	8b 50 14             	mov    0x14(%eax),%edx
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	8b 40 10             	mov    0x10(%eax),%eax
80101178:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010117c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101180:	8b 55 0c             	mov    0xc(%ebp),%edx
80101183:	89 54 24 04          	mov    %edx,0x4(%esp)
80101187:	89 04 24             	mov    %eax,(%esp)
8010118a:	e8 6b 10 00 00       	call   801021fa <readi>
8010118f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101192:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101196:	7e 11                	jle    801011a9 <fileread+0x9b>
      f->off += r;
80101198:	8b 45 08             	mov    0x8(%ebp),%eax
8010119b:	8b 50 14             	mov    0x14(%eax),%edx
8010119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a1:	01 c2                	add    %eax,%edx
801011a3:	8b 45 08             	mov    0x8(%ebp),%eax
801011a6:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011a9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ac:	8b 40 10             	mov    0x10(%eax),%eax
801011af:	89 04 24             	mov    %eax,(%esp)
801011b2:	e8 1d 0c 00 00       	call   80101dd4 <iunlock>
    return r;
801011b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011ba:	eb 0c                	jmp    801011c8 <fileread+0xba>
  }
  panic("fileread");
801011bc:	c7 04 24 fb 8c 10 80 	movl   $0x80108cfb,(%esp)
801011c3:	e8 72 f3 ff ff       	call   8010053a <panic>
}
801011c8:	c9                   	leave  
801011c9:	c3                   	ret    

801011ca <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011ca:	55                   	push   %ebp
801011cb:	89 e5                	mov    %esp,%ebp
801011cd:	53                   	push   %ebx
801011ce:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011d1:	8b 45 08             	mov    0x8(%ebp),%eax
801011d4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011d8:	84 c0                	test   %al,%al
801011da:	75 0a                	jne    801011e6 <filewrite+0x1c>
    return -1;
801011dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e1:	e9 20 01 00 00       	jmp    80101306 <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8b 00                	mov    (%eax),%eax
801011eb:	83 f8 01             	cmp    $0x1,%eax
801011ee:	75 21                	jne    80101211 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 40 0c             	mov    0xc(%eax),%eax
801011f6:	8b 55 10             	mov    0x10(%ebp),%edx
801011f9:	89 54 24 08          	mov    %edx,0x8(%esp)
801011fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101200:	89 54 24 04          	mov    %edx,0x4(%esp)
80101204:	89 04 24             	mov    %eax,(%esp)
80101207:	e8 4a 37 00 00       	call   80104956 <pipewrite>
8010120c:	e9 f5 00 00 00       	jmp    80101306 <filewrite+0x13c>
  if(f->type == FD_INODE){
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 00                	mov    (%eax),%eax
80101216:	83 f8 02             	cmp    $0x2,%eax
80101219:	0f 85 db 00 00 00    	jne    801012fa <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010121f:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101226:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010122d:	e9 a8 00 00 00       	jmp    801012da <filewrite+0x110>
      int n1 = n - i;
80101232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101235:	8b 55 10             	mov    0x10(%ebp),%edx
80101238:	29 c2                	sub    %eax,%edx
8010123a:	89 d0                	mov    %edx,%eax
8010123c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101242:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101245:	7e 06                	jle    8010124d <filewrite+0x83>
        n1 = max;
80101247:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010124a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010124d:	e8 23 2a 00 00       	call   80103c75 <begin_op>
      ilock(f->ip);
80101252:	8b 45 08             	mov    0x8(%ebp),%eax
80101255:	8b 40 10             	mov    0x10(%eax),%eax
80101258:	89 04 24             	mov    %eax,(%esp)
8010125b:	e8 b6 09 00 00       	call   80101c16 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101260:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101263:	8b 45 08             	mov    0x8(%ebp),%eax
80101266:	8b 50 14             	mov    0x14(%eax),%edx
80101269:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010126c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010126f:	01 c3                	add    %eax,%ebx
80101271:	8b 45 08             	mov    0x8(%ebp),%eax
80101274:	8b 40 10             	mov    0x10(%eax),%eax
80101277:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010127b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010127f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101283:	89 04 24             	mov    %eax,(%esp)
80101286:	e8 ea 10 00 00       	call   80102375 <writei>
8010128b:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010128e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101292:	7e 11                	jle    801012a5 <filewrite+0xdb>
        f->off += r;
80101294:	8b 45 08             	mov    0x8(%ebp),%eax
80101297:	8b 50 14             	mov    0x14(%eax),%edx
8010129a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010129d:	01 c2                	add    %eax,%edx
8010129f:	8b 45 08             	mov    0x8(%ebp),%eax
801012a2:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012a5:	8b 45 08             	mov    0x8(%ebp),%eax
801012a8:	8b 40 10             	mov    0x10(%eax),%eax
801012ab:	89 04 24             	mov    %eax,(%esp)
801012ae:	e8 21 0b 00 00       	call   80101dd4 <iunlock>
      end_op();
801012b3:	e8 41 2a 00 00       	call   80103cf9 <end_op>

      if(r < 0)
801012b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012bc:	79 02                	jns    801012c0 <filewrite+0xf6>
        break;
801012be:	eb 26                	jmp    801012e6 <filewrite+0x11c>
      if(r != n1)
801012c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012c6:	74 0c                	je     801012d4 <filewrite+0x10a>
        panic("short filewrite");
801012c8:	c7 04 24 04 8d 10 80 	movl   $0x80108d04,(%esp)
801012cf:	e8 66 f2 ff ff       	call   8010053a <panic>
      i += r;
801012d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012d7:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012dd:	3b 45 10             	cmp    0x10(%ebp),%eax
801012e0:	0f 8c 4c ff ff ff    	jl     80101232 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e9:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ec:	75 05                	jne    801012f3 <filewrite+0x129>
801012ee:	8b 45 10             	mov    0x10(%ebp),%eax
801012f1:	eb 05                	jmp    801012f8 <filewrite+0x12e>
801012f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f8:	eb 0c                	jmp    80101306 <filewrite+0x13c>
  }
  panic("filewrite");
801012fa:	c7 04 24 14 8d 10 80 	movl   $0x80108d14,(%esp)
80101301:	e8 34 f2 ff ff       	call   8010053a <panic>
}
80101306:	83 c4 24             	add    $0x24,%esp
80101309:	5b                   	pop    %ebx
8010130a:	5d                   	pop    %ebp
8010130b:	c3                   	ret    

8010130c <cas>:
outw(ushort port, ushort data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline int cas(volatile int* addr, int expected, int newval) {
8010130c:	55                   	push   %ebp
8010130d:	89 e5                	mov    %esp,%ebp
8010130f:	83 ec 10             	sub    $0x10,%esp
  int result = 0; 
80101312:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  asm volatile("lock; cmpxchgl %1, %2; sete %%al;":/* assembly code template */  
80101319:	8b 55 10             	mov    0x10(%ebp),%edx
8010131c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010131f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101322:	f0 0f b1 11          	lock cmpxchg %edx,(%ecx)
80101326:	0f 94 c0             	sete   %al
80101329:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "=a"(result) : /* output parameters */
               "r"(newval), "m"(*addr), "a"(expected) : /* input params */ 
               "cc", "memory");
  return result;
8010132c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010132f:	c9                   	leave  
80101330:	c3                   	ret    

80101331 <readsb>:


// Read the super block.
void
readsb(struct partition* part, struct superblock *sb)
{
80101331:	55                   	push   %ebp
80101332:	89 e5                	mov    %esp,%ebp
80101334:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  uint offset = part->prt.offset;
80101337:	8b 45 08             	mov    0x8(%ebp),%eax
8010133a:	8b 40 0c             	mov    0xc(%eax),%eax
8010133d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bp = bread(part->dev, part->prt.offset);
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	8b 50 0c             	mov    0xc(%eax),%edx
80101346:	8b 45 08             	mov    0x8(%ebp),%eax
80101349:	8b 00                	mov    (%eax),%eax
8010134b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010134f:	89 04 24             	mov    %eax,(%esp)
80101352:	e8 4f ee ff ff       	call   801001a6 <bread>
80101357:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010135a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010135d:	83 c0 18             	add    $0x18,%eax
80101360:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101367:	00 
80101368:	89 44 24 04          	mov    %eax,0x4(%esp)
8010136c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010136f:	89 04 24             	mov    %eax,(%esp)
80101372:	e8 0a 46 00 00       	call   80105981 <memmove>
  sb->logstart += offset;
80101377:	8b 45 0c             	mov    0xc(%ebp),%eax
8010137a:	8b 50 10             	mov    0x10(%eax),%edx
8010137d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101380:	01 c2                	add    %eax,%edx
80101382:	8b 45 0c             	mov    0xc(%ebp),%eax
80101385:	89 50 10             	mov    %edx,0x10(%eax)
  sb->inodestart += offset;
80101388:	8b 45 0c             	mov    0xc(%ebp),%eax
8010138b:	8b 50 14             	mov    0x14(%eax),%edx
8010138e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101391:	01 c2                	add    %eax,%edx
80101393:	8b 45 0c             	mov    0xc(%ebp),%eax
80101396:	89 50 14             	mov    %edx,0x14(%eax)
  sb->bmapstart += offset;
80101399:	8b 45 0c             	mov    0xc(%ebp),%eax
8010139c:	8b 50 18             	mov    0x18(%eax),%edx
8010139f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a2:	01 c2                	add    %eax,%edx
801013a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801013a7:	89 50 18             	mov    %edx,0x18(%eax)
  brelse(bp);
801013aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013ad:	89 04 24             	mov    %eax,(%esp)
801013b0:	e8 62 ee ff ff       	call   80100217 <brelse>
}
801013b5:	c9                   	leave  
801013b6:	c3                   	ret    

801013b7 <readmbr>:
// reads the MBR from block 0 of ROOTDEV (w/e) stores the mbr and prints it out.
void
readmbr(int dev) {
801013b7:	55                   	push   %ebp
801013b8:	89 e5                	mov    %esp,%ebp
801013ba:	56                   	push   %esi
801013bb:	53                   	push   %ebx
801013bc:	83 ec 50             	sub    $0x50,%esp
  struct buf *bp;
  struct dpartition* part = mbr.partitions;
801013bf:	c7 45 f4 5e 3b 11 80 	movl   $0x80113b5e,-0xc(%ebp)
  int i;
  struct superblock sb;
  bp = bread(dev, 0); // location of le mbr.
801013c6:	8b 45 08             	mov    0x8(%ebp),%eax
801013c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801013d0:	00 
801013d1:	89 04 24             	mov    %eax,(%esp)
801013d4:	e8 cd ed ff ff       	call   801001a6 <bread>
801013d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  memmove(&mbr, bp->data, sizeof(mbr));
801013dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013df:	83 c0 18             	add    $0x18,%eax
801013e2:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801013e9:	00 
801013ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801013ee:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801013f5:	e8 87 45 00 00       	call   80105981 <memmove>
  brelse(bp);
801013fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013fd:	89 04 24             	mov    %eax,(%esp)
80101400:	e8 12 ee ff ff       	call   80100217 <brelse>
  // print output of partitions
  for (i = 0; i < NPARTITIONS; ++i) {
80101405:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010140c:	e9 2d 01 00 00       	jmp    8010153e <readmbr+0x187>
    if (part[i].flags != 0) {  // guess this means it exists.
80101411:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101414:	c1 e0 04             	shl    $0x4,%eax
80101417:	89 c2                	mov    %eax,%edx
80101419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141c:	01 d0                	add    %edx,%eax
8010141e:	8b 00                	mov    (%eax),%eax
80101420:	85 c0                	test   %eax,%eax
80101422:	0f 84 a3 00 00 00    	je     801014cb <readmbr+0x114>
      cprintf("Partition %d; bootable %s, type %s, offset %d, size %d \n",
          i, (part + i)->flags & PART_BOOTABLE ? "YES" : "NO",
           part[i].type == FS_INODE ? "INODE" :
           part[i].type == FS_FAT ?   "FAT" :
           "???", part[i].offset, part[i].size);
80101428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142b:	c1 e0 04             	shl    $0x4,%eax
8010142e:	89 c2                	mov    %eax,%edx
80101430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101433:	01 d0                	add    %edx,%eax
  memmove(&mbr, bp->data, sizeof(mbr));
  brelse(bp);
  // print output of partitions
  for (i = 0; i < NPARTITIONS; ++i) {
    if (part[i].flags != 0) {  // guess this means it exists.
      cprintf("Partition %d; bootable %s, type %s, offset %d, size %d \n",
80101435:	8b 58 0c             	mov    0xc(%eax),%ebx
          i, (part + i)->flags & PART_BOOTABLE ? "YES" : "NO",
           part[i].type == FS_INODE ? "INODE" :
           part[i].type == FS_FAT ?   "FAT" :
           "???", part[i].offset, part[i].size);
80101438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010143b:	c1 e0 04             	shl    $0x4,%eax
8010143e:	89 c2                	mov    %eax,%edx
80101440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101443:	01 d0                	add    %edx,%eax
  memmove(&mbr, bp->data, sizeof(mbr));
  brelse(bp);
  // print output of partitions
  for (i = 0; i < NPARTITIONS; ++i) {
    if (part[i].flags != 0) {  // guess this means it exists.
      cprintf("Partition %d; bootable %s, type %s, offset %d, size %d \n",
80101445:	8b 48 08             	mov    0x8(%eax),%ecx
          i, (part + i)->flags & PART_BOOTABLE ? "YES" : "NO",
           part[i].type == FS_INODE ? "INODE" :
80101448:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010144b:	c1 e0 04             	shl    $0x4,%eax
8010144e:	89 c2                	mov    %eax,%edx
80101450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101453:	01 d0                	add    %edx,%eax
80101455:	8b 40 04             	mov    0x4(%eax),%eax
  memmove(&mbr, bp->data, sizeof(mbr));
  brelse(bp);
  // print output of partitions
  for (i = 0; i < NPARTITIONS; ++i) {
    if (part[i].flags != 0) {  // guess this means it exists.
      cprintf("Partition %d; bootable %s, type %s, offset %d, size %d \n",
80101458:	85 c0                	test   %eax,%eax
8010145a:	74 25                	je     80101481 <readmbr+0xca>
          i, (part + i)->flags & PART_BOOTABLE ? "YES" : "NO",
           part[i].type == FS_INODE ? "INODE" :
           part[i].type == FS_FAT ?   "FAT" :
8010145c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010145f:	c1 e0 04             	shl    $0x4,%eax
80101462:	89 c2                	mov    %eax,%edx
80101464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101467:	01 d0                	add    %edx,%eax
80101469:	8b 40 04             	mov    0x4(%eax),%eax
8010146c:	83 f8 01             	cmp    $0x1,%eax
8010146f:	75 07                	jne    80101478 <readmbr+0xc1>
80101471:	b8 20 8d 10 80       	mov    $0x80108d20,%eax
80101476:	eb 05                	jmp    8010147d <readmbr+0xc6>
80101478:	b8 24 8d 10 80       	mov    $0x80108d24,%eax
  memmove(&mbr, bp->data, sizeof(mbr));
  brelse(bp);
  // print output of partitions
  for (i = 0; i < NPARTITIONS; ++i) {
    if (part[i].flags != 0) {  // guess this means it exists.
      cprintf("Partition %d; bootable %s, type %s, offset %d, size %d \n",
8010147d:	89 c2                	mov    %eax,%edx
8010147f:	eb 05                	jmp    80101486 <readmbr+0xcf>
80101481:	ba 28 8d 10 80       	mov    $0x80108d28,%edx
          i, (part + i)->flags & PART_BOOTABLE ? "YES" : "NO",
80101486:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101489:	c1 e0 04             	shl    $0x4,%eax
8010148c:	89 c6                	mov    %eax,%esi
8010148e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101491:	01 f0                	add    %esi,%eax
80101493:	8b 00                	mov    (%eax),%eax
80101495:	83 e0 02             	and    $0x2,%eax
  memmove(&mbr, bp->data, sizeof(mbr));
  brelse(bp);
  // print output of partitions
  for (i = 0; i < NPARTITIONS; ++i) {
    if (part[i].flags != 0) {  // guess this means it exists.
      cprintf("Partition %d; bootable %s, type %s, offset %d, size %d \n",
80101498:	85 c0                	test   %eax,%eax
8010149a:	74 07                	je     801014a3 <readmbr+0xec>
8010149c:	b8 2e 8d 10 80       	mov    $0x80108d2e,%eax
801014a1:	eb 05                	jmp    801014a8 <readmbr+0xf1>
801014a3:	b8 32 8d 10 80       	mov    $0x80108d32,%eax
801014a8:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801014ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801014b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
801014b4:	89 44 24 08          	mov    %eax,0x8(%esp)
801014b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801014bf:	c7 04 24 38 8d 10 80 	movl   $0x80108d38,(%esp)
801014c6:	e8 d5 ee ff ff       	call   801003a0 <cprintf>
          i, (part + i)->flags & PART_BOOTABLE ? "YES" : "NO",
           part[i].type == FS_INODE ? "INODE" :
           part[i].type == FS_FAT ?   "FAT" :
           "???", part[i].offset, part[i].size);
    }
    partitions[i].dev = dev; 
801014cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
801014ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801014d1:	89 d0                	mov    %edx,%eax
801014d3:	c1 e0 02             	shl    $0x2,%eax
801014d6:	01 d0                	add    %edx,%eax
801014d8:	c1 e0 02             	shl    $0x2,%eax
801014db:	05 c0 3b 11 80       	add    $0x80113bc0,%eax
801014e0:	89 08                	mov    %ecx,(%eax)
    partitions[i].prt = part[i];
801014e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e5:	c1 e0 04             	shl    $0x4,%eax
801014e8:	89 c2                	mov    %eax,%edx
801014ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ed:	01 c2                	add    %eax,%edx
801014ef:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801014f2:	89 c8                	mov    %ecx,%eax
801014f4:	c1 e0 02             	shl    $0x2,%eax
801014f7:	01 c8                	add    %ecx,%eax
801014f9:	c1 e0 02             	shl    $0x2,%eax
801014fc:	05 c0 3b 11 80       	add    $0x80113bc0,%eax
80101501:	8b 0a                	mov    (%edx),%ecx
80101503:	89 48 04             	mov    %ecx,0x4(%eax)
80101506:	8b 4a 04             	mov    0x4(%edx),%ecx
80101509:	89 48 08             	mov    %ecx,0x8(%eax)
8010150c:	8b 4a 08             	mov    0x8(%edx),%ecx
8010150f:	89 48 0c             	mov    %ecx,0xc(%eax)
80101512:	8b 52 0c             	mov    0xc(%edx),%edx
80101515:	89 50 10             	mov    %edx,0x10(%eax)
    readsb(&partitions[i], &sb);
80101518:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010151b:	89 d0                	mov    %edx,%eax
8010151d:	c1 e0 02             	shl    $0x2,%eax
80101520:	01 d0                	add    %edx,%eax
80101522:	c1 e0 02             	shl    $0x2,%eax
80101525:	8d 90 c0 3b 11 80    	lea    -0x7feec440(%eax),%edx
8010152b:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010152e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101532:	89 14 24             	mov    %edx,(%esp)
80101535:	e8 f7 fd ff ff       	call   80101331 <readsb>
  struct superblock sb;
  bp = bread(dev, 0); // location of le mbr.
  memmove(&mbr, bp->data, sizeof(mbr));
  brelse(bp);
  // print output of partitions
  for (i = 0; i < NPARTITIONS; ++i) {
8010153a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010153e:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80101542:	0f 8e c9 fe ff ff    	jle    80101411 <readmbr+0x5a>
    /*cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d"
        " inodestart %d bmap start %d\n\n", sb.size,
        sb.nblocks, sb.ninodes, sb.nlog,
        sb.logstart, sb.inodestart, sb.bmapstart); */
  }
  while (part != mbr.partitions + NPARTITIONS) {
80101548:	eb 6d                	jmp    801015b7 <readmbr+0x200>
    if (part->flags & PART_BOOTABLE) {
8010154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154d:	8b 00                	mov    (%eax),%eax
8010154f:	83 e0 02             	and    $0x2,%eax
80101552:	85 c0                	test   %eax,%eax
80101554:	74 5d                	je     801015b3 <readmbr+0x1fc>
      set_part(part - mbr.partitions);
80101556:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101559:	b8 5e 3b 11 80       	mov    $0x80113b5e,%eax
8010155e:	29 c2                	sub    %eax,%edx
80101560:	89 d0                	mov    %edx,%eax
80101562:	c1 f8 04             	sar    $0x4,%eax
80101565:	89 04 24             	mov    %eax,(%esp)
80101568:	e8 47 14 00 00       	call   801029b4 <set_part>
      boot_part = partitions + (part - mbr.partitions);
8010156d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101570:	b8 5e 3b 11 80       	mov    $0x80113b5e,%eax
80101575:	29 c2                	sub    %eax,%edx
80101577:	89 d0                	mov    %edx,%eax
80101579:	c1 f8 04             	sar    $0x4,%eax
8010157c:	89 c2                	mov    %eax,%edx
8010157e:	89 d0                	mov    %edx,%eax
80101580:	c1 e0 02             	shl    $0x2,%eax
80101583:	01 d0                	add    %edx,%eax
80101585:	c1 e0 02             	shl    $0x2,%eax
80101588:	05 c0 3b 11 80       	add    $0x80113bc0,%eax
8010158d:	a3 10 3c 11 80       	mov    %eax,0x80113c10
      cprintf("setting current partition to %d \n", part - mbr.partitions);
80101592:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101595:	b8 5e 3b 11 80       	mov    $0x80113b5e,%eax
8010159a:	29 c2                	sub    %eax,%edx
8010159c:	89 d0                	mov    %edx,%eax
8010159e:	c1 f8 04             	sar    $0x4,%eax
801015a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801015a5:	c7 04 24 74 8d 10 80 	movl   $0x80108d74,(%esp)
801015ac:	e8 ef ed ff ff       	call   801003a0 <cprintf>
      return;
801015b1:	eb 19                	jmp    801015cc <readmbr+0x215>
    }
    ++part;
801015b3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
    /*cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d"
        " inodestart %d bmap start %d\n\n", sb.size,
        sb.nblocks, sb.ninodes, sb.nlog,
        sb.logstart, sb.inodestart, sb.bmapstart); */
  }
  while (part != mbr.partitions + NPARTITIONS) {
801015b7:	81 7d f4 9e 3b 11 80 	cmpl   $0x80113b9e,-0xc(%ebp)
801015be:	75 8a                	jne    8010154a <readmbr+0x193>
      cprintf("setting current partition to %d \n", part - mbr.partitions);
      return;
    }
    ++part;
  }
  panic("no bootable partition found");
801015c0:	c7 04 24 96 8d 10 80 	movl   $0x80108d96,(%esp)
801015c7:	e8 6e ef ff ff       	call   8010053a <panic>
}
801015cc:	83 c4 50             	add    $0x50,%esp
801015cf:	5b                   	pop    %ebx
801015d0:	5e                   	pop    %esi
801015d1:	5d                   	pop    %ebp
801015d2:	c3                   	ret    

801015d3 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801015d3:	55                   	push   %ebp
801015d4:	89 e5                	mov    %esp,%ebp
801015d6:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801015d9:	8b 55 0c             	mov    0xc(%ebp),%edx
801015dc:	8b 45 08             	mov    0x8(%ebp),%eax
801015df:	89 54 24 04          	mov    %edx,0x4(%esp)
801015e3:	89 04 24             	mov    %eax,(%esp)
801015e6:	e8 bb eb ff ff       	call   801001a6 <bread>
801015eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801015ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f1:	83 c0 18             	add    $0x18,%eax
801015f4:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801015fb:	00 
801015fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101603:	00 
80101604:	89 04 24             	mov    %eax,(%esp)
80101607:	e8 a6 42 00 00       	call   801058b2 <memset>
  log_write(bp);
8010160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160f:	89 04 24             	mov    %eax,(%esp)
80101612:	e8 69 28 00 00       	call   80103e80 <log_write>
  brelse(bp);
80101617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161a:	89 04 24             	mov    %eax,(%esp)
8010161d:	e8 f5 eb ff ff       	call   80100217 <brelse>
}
80101622:	c9                   	leave  
80101623:	c3                   	ret    

80101624 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(struct partition* prt)
{
80101624:	55                   	push   %ebp
80101625:	89 e5                	mov    %esp,%ebp
80101627:	83 ec 58             	sub    $0x58,%esp
  int b, bi, m;
  uint freeblock_offset;
  struct buf *bp;
  struct superblock sb;
  uint dev = prt->dev;
8010162a:	8b 45 08             	mov    0x8(%ebp),%eax
8010162d:	8b 00                	mov    (%eax),%eax
8010162f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  readsb(prt, &sb);
80101632:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80101635:	89 44 24 04          	mov    %eax,0x4(%esp)
80101639:	8b 45 08             	mov    0x8(%ebp),%eax
8010163c:	89 04 24             	mov    %eax,(%esp)
8010163f:	e8 ed fc ff ff       	call   80101331 <readsb>
//  psb;
  freeblock_offset = sb.bmapstart + 1 - prt->prt.offset;
80101644:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101647:	8b 45 08             	mov    0x8(%ebp),%eax
8010164a:	8b 40 0c             	mov    0xc(%eax),%eax
8010164d:	29 c2                	sub    %eax,%edx
8010164f:	89 d0                	mov    %edx,%eax
80101651:	83 c0 01             	add    $0x1,%eax
80101654:	89 45 e8             	mov    %eax,-0x18(%ebp)
  bp = 0;
80101657:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010165e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101665:	e9 17 01 00 00       	jmp    80101781 <balloc+0x15d>
    if (0 && proc && proc->pid > 2) {
      cprintf("bread(%d, %d) \n",dev, BBLOCK(b, sb));
    }
    bp = bread(dev, BBLOCK(b, sb));
8010166a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010166d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101673:	85 c0                	test   %eax,%eax
80101675:	0f 48 c2             	cmovs  %edx,%eax
80101678:	c1 f8 0c             	sar    $0xc,%eax
8010167b:	89 c2                	mov    %eax,%edx
8010167d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101680:	01 d0                	add    %edx,%eax
80101682:	89 44 24 04          	mov    %eax,0x4(%esp)
80101686:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101689:	89 04 24             	mov    %eax,(%esp)
8010168c:	e8 15 eb ff ff       	call   801001a6 <bread>
80101691:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101694:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010169b:	e9 b1 00 00 00       	jmp    80101751 <balloc+0x12d>
      m = 1 << (bi % 8);
801016a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a3:	99                   	cltd   
801016a4:	c1 ea 1d             	shr    $0x1d,%edx
801016a7:	01 d0                	add    %edx,%eax
801016a9:	83 e0 07             	and    $0x7,%eax
801016ac:	29 d0                	sub    %edx,%eax
801016ae:	ba 01 00 00 00       	mov    $0x1,%edx
801016b3:	89 c1                	mov    %eax,%ecx
801016b5:	d3 e2                	shl    %cl,%edx
801016b7:	89 d0                	mov    %edx,%eax
801016b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801016bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016bf:	8d 50 07             	lea    0x7(%eax),%edx
801016c2:	85 c0                	test   %eax,%eax
801016c4:	0f 48 c2             	cmovs  %edx,%eax
801016c7:	c1 f8 03             	sar    $0x3,%eax
801016ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016cd:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801016d2:	0f b6 c0             	movzbl %al,%eax
801016d5:	23 45 e0             	and    -0x20(%ebp),%eax
801016d8:	85 c0                	test   %eax,%eax
801016da:	75 71                	jne    8010174d <balloc+0x129>
        bp->data[bi/8] |= m;  // Mark block in use.
801016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016df:	8d 50 07             	lea    0x7(%eax),%edx
801016e2:	85 c0                	test   %eax,%eax
801016e4:	0f 48 c2             	cmovs  %edx,%eax
801016e7:	c1 f8 03             	sar    $0x3,%eax
801016ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016ed:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016f2:	89 d1                	mov    %edx,%ecx
801016f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801016f7:	09 ca                	or     %ecx,%edx
801016f9:	89 d1                	mov    %edx,%ecx
801016fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016fe:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101702:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101705:	89 04 24             	mov    %eax,(%esp)
80101708:	e8 73 27 00 00       	call   80103e80 <log_write>
        brelse(bp);
8010170d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101710:	89 04 24             	mov    %eax,(%esp)
80101713:	e8 ff ea ff ff       	call   80100217 <brelse>
        // TODO(bilals) should an offset be added here?
        bzero(dev, freeblock_offset + b + bi + prt->prt.offset);
80101718:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010171b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010171e:	01 c2                	add    %eax,%edx
80101720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101723:	01 c2                	add    %eax,%edx
80101725:	8b 45 08             	mov    0x8(%ebp),%eax
80101728:	8b 40 0c             	mov    0xc(%eax),%eax
8010172b:	01 d0                	add    %edx,%eax
8010172d:	89 c2                	mov    %eax,%edx
8010172f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101732:	89 54 24 04          	mov    %edx,0x4(%esp)
80101736:	89 04 24             	mov    %eax,(%esp)
80101739:	e8 95 fe ff ff       	call   801015d3 <bzero>
        if(0 && proc && proc->pid > 2) {
          cprintf("balloc'd %d \n", freeblock_offset+b+bi);
        }
        return freeblock_offset + b + bi;
8010173e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101741:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101744:	01 c2                	add    %eax,%edx
80101746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101749:	01 d0                	add    %edx,%eax
8010174b:	eb 4e                	jmp    8010179b <balloc+0x177>
  for(b = 0; b < sb.size; b += BPB){
    if (0 && proc && proc->pid > 2) {
      cprintf("bread(%d, %d) \n",dev, BBLOCK(b, sb));
    }
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010174d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101751:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101758:	7f 15                	jg     8010176f <balloc+0x14b>
8010175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101760:	01 d0                	add    %edx,%eax
80101762:	89 c2                	mov    %eax,%edx
80101764:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80101767:	39 c2                	cmp    %eax,%edx
80101769:	0f 82 31 ff ff ff    	jb     801016a0 <balloc+0x7c>
          cprintf("balloc'd %d \n", freeblock_offset+b+bi);
        }
        return freeblock_offset + b + bi;
      }
    }
    brelse(bp);
8010176f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101772:	89 04 24             	mov    %eax,(%esp)
80101775:	e8 9d ea ff ff       	call   80100217 <brelse>
  uint dev = prt->dev;
  readsb(prt, &sb);
//  psb;
  freeblock_offset = sb.bmapstart + 1 - prt->prt.offset;
  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010177a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101781:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101784:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80101787:	39 c2                	cmp    %eax,%edx
80101789:	0f 82 db fe ff ff    	jb     8010166a <balloc+0x46>
        return freeblock_offset + b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010178f:	c7 04 24 b2 8d 10 80 	movl   $0x80108db2,(%esp)
80101796:	e8 9f ed ff ff       	call   8010053a <panic>
}
8010179b:	c9                   	leave  
8010179c:	c3                   	ret    

8010179d <bfree>:

// Free a disk block.
static void
bfree(struct partition* prt, uint b)
{
8010179d:	55                   	push   %ebp
8010179e:	89 e5                	mov    %esp,%ebp
801017a0:	83 ec 48             	sub    $0x48,%esp
  struct buf *bp;
  int bi, m;
  uint freeblock_offset;
  struct superblock sb;
  readsb(prt, &sb);
801017a3:	8d 45 cc             	lea    -0x34(%ebp),%eax
801017a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801017aa:	8b 45 08             	mov    0x8(%ebp),%eax
801017ad:	89 04 24             	mov    %eax,(%esp)
801017b0:	e8 7c fb ff ff       	call   80101331 <readsb>
  freeblock_offset = sb.bmapstart + 1;
801017b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801017b8:	83 c0 01             	add    $0x1,%eax
801017bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  b = b - freeblock_offset ;
801017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c1:	29 45 0c             	sub    %eax,0xc(%ebp)
  bp = bread(prt->dev, BBLOCK(b, sb));
801017c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801017c7:	c1 e8 0c             	shr    $0xc,%eax
801017ca:	89 c2                	mov    %eax,%edx
801017cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801017cf:	01 c2                	add    %eax,%edx
801017d1:	8b 45 08             	mov    0x8(%ebp),%eax
801017d4:	8b 00                	mov    (%eax),%eax
801017d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801017da:	89 04 24             	mov    %eax,(%esp)
801017dd:	e8 c4 e9 ff ff       	call   801001a6 <bread>
801017e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  bi = b % BPB;
801017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801017e8:	25 ff 0f 00 00       	and    $0xfff,%eax
801017ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  m = 1 << (bi % 8);
801017f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017f3:	99                   	cltd   
801017f4:	c1 ea 1d             	shr    $0x1d,%edx
801017f7:	01 d0                	add    %edx,%eax
801017f9:	83 e0 07             	and    $0x7,%eax
801017fc:	29 d0                	sub    %edx,%eax
801017fe:	ba 01 00 00 00       	mov    $0x1,%edx
80101803:	89 c1                	mov    %eax,%ecx
80101805:	d3 e2                	shl    %cl,%edx
80101807:	89 d0                	mov    %edx,%eax
80101809:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if((bp->data[bi/8] & m) == 0) {
8010180c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010180f:	8d 50 07             	lea    0x7(%eax),%edx
80101812:	85 c0                	test   %eax,%eax
80101814:	0f 48 c2             	cmovs  %edx,%eax
80101817:	c1 f8 03             	sar    $0x3,%eax
8010181a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010181d:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101822:	0f b6 c0             	movzbl %al,%eax
80101825:	23 45 e8             	and    -0x18(%ebp),%eax
80101828:	85 c0                	test   %eax,%eax
8010182a:	75 1f                	jne    8010184b <bfree+0xae>
    cprintf("tried to free blockno %d \n", b);
8010182c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010182f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101833:	c7 04 24 c8 8d 10 80 	movl   $0x80108dc8,(%esp)
8010183a:	e8 61 eb ff ff       	call   801003a0 <cprintf>
    panic("freeing free block");
8010183f:	c7 04 24 e3 8d 10 80 	movl   $0x80108de3,(%esp)
80101846:	e8 ef ec ff ff       	call   8010053a <panic>
  }
  bp->data[bi/8] &= ~m;
8010184b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010184e:	8d 50 07             	lea    0x7(%eax),%edx
80101851:	85 c0                	test   %eax,%eax
80101853:	0f 48 c2             	cmovs  %edx,%eax
80101856:	c1 f8 03             	sar    $0x3,%eax
80101859:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010185c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101861:	8b 4d e8             	mov    -0x18(%ebp),%ecx
80101864:	f7 d1                	not    %ecx
80101866:	21 ca                	and    %ecx,%edx
80101868:	89 d1                	mov    %edx,%ecx
8010186a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010186d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101874:	89 04 24             	mov    %eax,(%esp)
80101877:	e8 04 26 00 00       	call   80103e80 <log_write>
  brelse(bp);
8010187c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187f:	89 04 24             	mov    %eax,(%esp)
80101882:	e8 90 e9 ff ff       	call   80100217 <brelse>
}
80101887:	c9                   	leave  
80101888:	c3                   	ret    

80101889 <iinit>:
} icache;

static struct inode* iget(struct partition*, uint inum);
void
iinit(int dev)
{
80101889:	55                   	push   %ebp
8010188a:	89 e5                	mov    %esp,%ebp
8010188c:	57                   	push   %edi
8010188d:	56                   	push   %esi
8010188e:	53                   	push   %ebx
8010188f:	83 ec 4c             	sub    $0x4c,%esp
  struct inode* ip;
  initlock(&icache.lock, "icache");
80101892:	c7 44 24 04 f6 8d 10 	movl   $0x80108df6,0x4(%esp)
80101899:	80 
8010189a:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
801018a1:	e8 97 3d 00 00       	call   8010563d <initlock>
  readmbr(dev);
801018a6:	8b 45 08             	mov    0x8(%ebp),%eax
801018a9:	89 04 24             	mov    %eax,(%esp)
801018ac:	e8 06 fb ff ff       	call   801013b7 <readmbr>
  readsb(boot_part, &sb);
801018b1:	a1 10 3c 11 80       	mov    0x80113c10,%eax
801018b6:	c7 44 24 04 a0 3b 11 	movl   $0x80113ba0,0x4(%esp)
801018bd:	80 
801018be:	89 04 24             	mov    %eax,(%esp)
801018c1:	e8 6b fa ff ff       	call   80101331 <readsb>
  // this should make sure that rooino->prt is the boot block.
  ip = iget(boot_part, ROOTINO);
801018c6:	a1 10 3c 11 80       	mov    0x80113c10,%eax
801018cb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801018d2:	00 
801018d3:	89 04 24             	mov    %eax,(%esp)
801018d6:	e8 2d 02 00 00       	call   80101b08 <iget>
801018db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  proc->cwd = ip;
801018de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801018e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801018e7:	89 50 68             	mov    %edx,0x68(%eax)
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d"
801018ea:	a1 b8 3b 11 80       	mov    0x80113bb8,%eax
801018ef:	8b 3d b4 3b 11 80    	mov    0x80113bb4,%edi
801018f5:	8b 35 b0 3b 11 80    	mov    0x80113bb0,%esi
801018fb:	8b 1d ac 3b 11 80    	mov    0x80113bac,%ebx
80101901:	8b 0d a8 3b 11 80    	mov    0x80113ba8,%ecx
80101907:	8b 15 a4 3b 11 80    	mov    0x80113ba4,%edx
8010190d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101910:	8b 15 a0 3b 11 80    	mov    0x80113ba0,%edx
80101916:	89 44 24 1c          	mov    %eax,0x1c(%esp)
8010191a:	89 7c 24 18          	mov    %edi,0x18(%esp)
8010191e:	89 74 24 14          	mov    %esi,0x14(%esp)
80101922:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101926:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010192a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010192d:	89 44 24 08          	mov    %eax,0x8(%esp)
80101931:	89 d0                	mov    %edx,%eax
80101933:	89 44 24 04          	mov    %eax,0x4(%esp)
80101937:	c7 04 24 00 8e 10 80 	movl   $0x80108e00,(%esp)
8010193e:	e8 5d ea ff ff       	call   801003a0 <cprintf>
          " inodestart %d bmap start %d\n", sb.size,
          sb.nblocks, sb.ninodes, sb.nlog,
          sb.logstart, sb.inodestart, sb.bmapstart);
}
80101943:	83 c4 4c             	add    $0x4c,%esp
80101946:	5b                   	pop    %ebx
80101947:	5e                   	pop    %esi
80101948:	5f                   	pop    %edi
80101949:	5d                   	pop    %ebp
8010194a:	c3                   	ret    

8010194b <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(struct partition* prt, short type)
{
8010194b:	55                   	push   %ebp
8010194c:	89 e5                	mov    %esp,%ebp
8010194e:	83 ec 48             	sub    $0x48,%esp
80101951:	8b 45 0c             	mov    0xc(%ebp),%eax
80101954:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;
  uint dev = prt->dev;
80101958:	8b 45 08             	mov    0x8(%ebp),%eax
8010195b:	8b 00                	mov    (%eax),%eax
8010195d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  readsb(prt, &sb);
80101960:	8d 45 cc             	lea    -0x34(%ebp),%eax
80101963:	89 44 24 04          	mov    %eax,0x4(%esp)
80101967:	8b 45 08             	mov    0x8(%ebp),%eax
8010196a:	89 04 24             	mov    %eax,(%esp)
8010196d:	e8 bf f9 ff ff       	call   80101331 <readsb>
  for(inum = 1; inum < sb.ninodes; inum++){
80101972:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101979:	e9 9c 00 00 00       	jmp    80101a1a <ialloc+0xcf>
    bp = bread(dev, IBLOCK(inum, sb));
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	c1 e8 03             	shr    $0x3,%eax
80101984:	89 c2                	mov    %eax,%edx
80101986:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101989:	01 d0                	add    %edx,%eax
8010198b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101992:	89 04 24             	mov    %eax,(%esp)
80101995:	e8 0c e8 ff ff       	call   801001a6 <bread>
8010199a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010199d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019a0:	8d 50 18             	lea    0x18(%eax),%edx
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	83 e0 07             	and    $0x7,%eax
801019a9:	c1 e0 06             	shl    $0x6,%eax
801019ac:	01 d0                	add    %edx,%eax
801019ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(dip->type == 0){  // a free inode
801019b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801019b4:	0f b7 00             	movzwl (%eax),%eax
801019b7:	66 85 c0             	test   %ax,%ax
801019ba:	75 4f                	jne    80101a0b <ialloc+0xc0>
      memset(dip, 0, sizeof(*dip));
801019bc:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801019c3:	00 
801019c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801019cb:	00 
801019cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801019cf:	89 04 24             	mov    %eax,(%esp)
801019d2:	e8 db 3e 00 00       	call   801058b2 <memset>
      dip->type = type;
801019d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801019da:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
801019de:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801019e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019e4:	89 04 24             	mov    %eax,(%esp)
801019e7:	e8 94 24 00 00       	call   80103e80 <log_write>
      brelse(bp);
801019ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019ef:	89 04 24             	mov    %eax,(%esp)
801019f2:	e8 20 e8 ff ff       	call   80100217 <brelse>
      return iget(prt, inum);
801019f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	89 04 24             	mov    %eax,(%esp)
80101a04:	e8 ff 00 00 00       	call   80101b08 <iget>
80101a09:	eb 29                	jmp    80101a34 <ialloc+0xe9>
    }
    brelse(bp);
80101a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a0e:	89 04 24             	mov    %eax,(%esp)
80101a11:	e8 01 e8 ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;
  uint dev = prt->dev;
  readsb(prt, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){
80101a16:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101a1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101a1d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101a20:	39 c2                	cmp    %eax,%edx
80101a22:	0f 82 56 ff ff ff    	jb     8010197e <ialloc+0x33>
      brelse(bp);
      return iget(prt, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101a28:	c7 04 24 53 8e 10 80 	movl   $0x80108e53,(%esp)
80101a2f:	e8 06 eb ff ff       	call   8010053a <panic>
}
80101a34:	c9                   	leave  
80101a35:	c3                   	ret    

80101a36 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101a36:	55                   	push   %ebp
80101a37:	89 e5                	mov    %esp,%ebp
80101a39:	83 ec 48             	sub    $0x48,%esp
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb; 
  readsb(ip->prt, &sb);
80101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a42:	8d 55 d4             	lea    -0x2c(%ebp),%edx
80101a45:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a49:	89 04 24             	mov    %eax,(%esp)
80101a4c:	e8 e0 f8 ff ff       	call   80101331 <readsb>
  bp = bread(ip->prt->dev, IBLOCK(ip->inum, sb));
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	8b 00                	mov    (%eax),%eax
80101a56:	c1 e8 03             	shr    $0x3,%eax
80101a59:	89 c2                	mov    %eax,%edx
80101a5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101a5e:	01 c2                	add    %eax,%edx
80101a60:	8b 45 08             	mov    0x8(%ebp),%eax
80101a63:	8b 40 0c             	mov    0xc(%eax),%eax
80101a66:	8b 00                	mov    (%eax),%eax
80101a68:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a6c:	89 04 24             	mov    %eax,(%esp)
80101a6f:	e8 32 e7 ff ff       	call   801001a6 <bread>
80101a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7a:	8d 50 18             	lea    0x18(%eax),%edx
80101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a80:	8b 00                	mov    (%eax),%eax
80101a82:	83 e0 07             	and    $0x7,%eax
80101a85:	c1 e0 06             	shl    $0x6,%eax
80101a88:	01 d0                	add    %edx,%eax
80101a8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	0f b7 50 1c          	movzwl 0x1c(%eax),%edx
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9d:	0f b7 50 1e          	movzwl 0x1e(%eax),%edx
80101aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa4:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	0f b7 50 20          	movzwl 0x20(%eax),%edx
80101aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab2:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab9:	0f b7 50 22          	movzwl 0x22(%eax),%edx
80101abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ac0:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac7:	8b 50 24             	mov    0x24(%eax),%edx
80101aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101acd:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	8d 50 28             	lea    0x28(%eax),%edx
80101ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad9:	83 c0 0c             	add    $0xc,%eax
80101adc:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101ae3:	00 
80101ae4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ae8:	89 04 24             	mov    %eax,(%esp)
80101aeb:	e8 91 3e 00 00       	call   80105981 <memmove>
  log_write(bp);
80101af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af3:	89 04 24             	mov    %eax,(%esp)
80101af6:	e8 85 23 00 00       	call   80103e80 <log_write>
  brelse(bp);
80101afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101afe:	89 04 24             	mov    %eax,(%esp)
80101b01:	e8 11 e7 ff ff       	call   80100217 <brelse>
}
80101b06:	c9                   	leave  
80101b07:	c3                   	ret    

80101b08 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(struct partition* prt, uint inum)
{
80101b08:	55                   	push   %ebp
80101b09:	89 e5                	mov    %esp,%ebp
80101b0b:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101b0e:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101b15:	e8 44 3b 00 00       	call   8010565e <acquire>

  // Is the inode already cached?
  empty = 0;
80101b1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b21:	c7 45 f4 54 3c 11 80 	movl   $0x80113c54,-0xc(%ebp)
80101b28:	eb 59                	jmp    80101b83 <iget+0x7b>
    if(ip->ref > 0 && ip->prt == prt && ip->inum == inum){
80101b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2d:	8b 40 04             	mov    0x4(%eax),%eax
80101b30:	85 c0                	test   %eax,%eax
80101b32:	7e 35                	jle    80101b69 <iget+0x61>
80101b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b37:	8b 40 0c             	mov    0xc(%eax),%eax
80101b3a:	3b 45 08             	cmp    0x8(%ebp),%eax
80101b3d:	75 2a                	jne    80101b69 <iget+0x61>
80101b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b42:	8b 00                	mov    (%eax),%eax
80101b44:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101b47:	75 20                	jne    80101b69 <iget+0x61>
      ip->ref++;
80101b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b4c:	8b 40 04             	mov    0x4(%eax),%eax
80101b4f:	8d 50 01             	lea    0x1(%eax),%edx
80101b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b55:	89 50 04             	mov    %edx,0x4(%eax)
      release(&icache.lock);
80101b58:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101b5f:	e8 5c 3b 00 00       	call   801056c0 <release>
      return ip;
80101b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b67:	eb 79                	jmp    80101be2 <iget+0xda>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101b69:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b6d:	75 10                	jne    80101b7f <iget+0x77>
80101b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b72:	8b 40 04             	mov    0x4(%eax),%eax
80101b75:	85 c0                	test   %eax,%eax
80101b77:	75 06                	jne    80101b7f <iget+0x77>
      empty = ip;
80101b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b7c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b7f:	83 45 f4 5c          	addl   $0x5c,-0xc(%ebp)
80101b83:	81 7d f4 4c 4e 11 80 	cmpl   $0x80114e4c,-0xc(%ebp)
80101b8a:	72 9e                	jb     80101b2a <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101b8c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b90:	75 0c                	jne    80101b9e <iget+0x96>
    panic("iget: no inodes");
80101b92:	c7 04 24 65 8e 10 80 	movl   $0x80108e65,(%esp)
80101b99:	e8 9c e9 ff ff       	call   8010053a <panic>
  ip = empty;
80101b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->prt = prt;
80101ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba7:	8b 55 08             	mov    0x8(%ebp),%edx
80101baa:	89 50 0c             	mov    %edx,0xc(%eax)
  ip->inum = inum;
80101bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bb3:	89 10                	mov    %edx,(%eax)
  ip->ref = 1;
80101bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bb8:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
  ip->flags = 0;
80101bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  ip->mnt_info.is_mnt = 0;
80101bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bcc:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
  release(&icache.lock);
80101bd3:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101bda:	e8 e1 3a 00 00       	call   801056c0 <release>

  return ip;
80101bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101be2:	c9                   	leave  
80101be3:	c3                   	ret    

80101be4 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101be4:	55                   	push   %ebp
80101be5:	89 e5                	mov    %esp,%ebp
80101be7:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101bea:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101bf1:	e8 68 3a 00 00       	call   8010565e <acquire>
  ip->ref++;
80101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf9:	8b 40 04             	mov    0x4(%eax),%eax
80101bfc:	8d 50 01             	lea    0x1(%eax),%edx
80101bff:	8b 45 08             	mov    0x8(%ebp),%eax
80101c02:	89 50 04             	mov    %edx,0x4(%eax)
  release(&icache.lock);
80101c05:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101c0c:	e8 af 3a 00 00       	call   801056c0 <release>
  return ip;
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101c14:	c9                   	leave  
80101c15:	c3                   	ret    

80101c16 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101c16:	55                   	push   %ebp
80101c17:	89 e5                	mov    %esp,%ebp
80101c19:	53                   	push   %ebx
80101c1a:	83 ec 54             	sub    $0x54,%esp
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;
  if(ip == 0 || ip->ref < 1)
80101c1d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c21:	74 0a                	je     80101c2d <ilock+0x17>
80101c23:	8b 45 08             	mov    0x8(%ebp),%eax
80101c26:	8b 40 04             	mov    0x4(%eax),%eax
80101c29:	85 c0                	test   %eax,%eax
80101c2b:	7f 0c                	jg     80101c39 <ilock+0x23>
    panic("ilock");
80101c2d:	c7 04 24 75 8e 10 80 	movl   $0x80108e75,(%esp)
80101c34:	e8 01 e9 ff ff       	call   8010053a <panic>
  if (ip->prt == 0) {
80101c39:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3c:	8b 40 0c             	mov    0xc(%eax),%eax
80101c3f:	85 c0                	test   %eax,%eax
80101c41:	75 47                	jne    80101c8a <ilock+0x74>
    cprintf("ip w/- : inum: %d major: %d minor: %d prt: %p\n",
80101c43:	8b 45 08             	mov    0x8(%ebp),%eax
80101c46:	8b 58 0c             	mov    0xc(%eax),%ebx
        ip->inum, ip->major, ip->minor, ip->prt);
80101c49:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4c:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  struct dinode *dip;
  struct superblock sb;
  if(ip == 0 || ip->ref < 1)
    panic("ilock");
  if (ip->prt == 0) {
    cprintf("ip w/- : inum: %d major: %d minor: %d prt: %p\n",
80101c50:	0f bf c8             	movswl %ax,%ecx
        ip->inum, ip->major, ip->minor, ip->prt);
80101c53:	8b 45 08             	mov    0x8(%ebp),%eax
80101c56:	0f b7 40 1e          	movzwl 0x1e(%eax),%eax
  struct dinode *dip;
  struct superblock sb;
  if(ip == 0 || ip->ref < 1)
    panic("ilock");
  if (ip->prt == 0) {
    cprintf("ip w/- : inum: %d major: %d minor: %d prt: %p\n",
80101c5a:	0f bf d0             	movswl %ax,%edx
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	8b 00                	mov    (%eax),%eax
80101c62:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101c66:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101c6a:	89 54 24 08          	mov    %edx,0x8(%esp)
80101c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101c72:	c7 04 24 7c 8e 10 80 	movl   $0x80108e7c,(%esp)
80101c79:	e8 22 e7 ff ff       	call   801003a0 <cprintf>
        ip->inum, ip->major, ip->minor, ip->prt);
    panic("ilock no partition");
80101c7e:	c7 04 24 ab 8e 10 80 	movl   $0x80108eab,(%esp)
80101c85:	e8 b0 e8 ff ff       	call   8010053a <panic>
  }
  acquire(&icache.lock);
80101c8a:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101c91:	e8 c8 39 00 00       	call   8010565e <acquire>
  while(ip->flags & I_BUSY)
80101c96:	eb 13                	jmp    80101cab <ilock+0x95>
    sleep(ip, &icache.lock);
80101c98:	c7 44 24 04 20 3c 11 	movl   $0x80113c20,0x4(%esp)
80101c9f:	80 
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 04 24             	mov    %eax,(%esp)
80101ca6:	e8 e9 36 00 00       	call   80105394 <sleep>
    cprintf("ip w/- : inum: %d major: %d minor: %d prt: %p\n",
        ip->inum, ip->major, ip->minor, ip->prt);
    panic("ilock no partition");
  }
  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101cab:	8b 45 08             	mov    0x8(%ebp),%eax
80101cae:	8b 40 08             	mov    0x8(%eax),%eax
80101cb1:	83 e0 01             	and    $0x1,%eax
80101cb4:	85 c0                	test   %eax,%eax
80101cb6:	75 e0                	jne    80101c98 <ilock+0x82>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101cb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbb:	8b 40 08             	mov    0x8(%eax),%eax
80101cbe:	83 c8 01             	or     $0x1,%eax
80101cc1:	89 c2                	mov    %eax,%edx
80101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc6:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cc9:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101cd0:	e8 eb 39 00 00       	call   801056c0 <release>
  readsb(ip->prt, &sb);
80101cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd8:	8b 40 0c             	mov    0xc(%eax),%eax
80101cdb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
80101cde:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ce2:	89 04 24             	mov    %eax,(%esp)
80101ce5:	e8 47 f6 ff ff       	call   80101331 <readsb>
  if(!(ip->flags & I_VALID)){
80101cea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ced:	8b 40 08             	mov    0x8(%eax),%eax
80101cf0:	83 e0 02             	and    $0x2,%eax
80101cf3:	85 c0                	test   %eax,%eax
80101cf5:	0f 85 d3 00 00 00    	jne    80101dce <ilock+0x1b8>
    bp = bread(ip->prt->dev, IBLOCK(ip->inum, sb));
80101cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfe:	8b 00                	mov    (%eax),%eax
80101d00:	c1 e8 03             	shr    $0x3,%eax
80101d03:	89 c2                	mov    %eax,%edx
80101d05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d08:	01 c2                	add    %eax,%edx
80101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0d:	8b 40 0c             	mov    0xc(%eax),%eax
80101d10:	8b 00                	mov    (%eax),%eax
80101d12:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d16:	89 04 24             	mov    %eax,(%esp)
80101d19:	e8 88 e4 ff ff       	call   801001a6 <bread>
80101d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d24:	8d 50 18             	lea    0x18(%eax),%edx
80101d27:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2a:	8b 00                	mov    (%eax),%eax
80101d2c:	83 e0 07             	and    $0x7,%eax
80101d2f:	c1 e0 06             	shl    $0x6,%eax
80101d32:	01 d0                	add    %edx,%eax
80101d34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d3a:	0f b7 10             	movzwl (%eax),%edx
80101d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d40:	66 89 50 1c          	mov    %dx,0x1c(%eax)
    ip->major = dip->major;
80101d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d47:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4e:	66 89 50 1e          	mov    %dx,0x1e(%eax)
    ip->minor = dip->minor;
80101d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d55:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	66 89 50 20          	mov    %dx,0x20(%eax)
    ip->nlink = dip->nlink;
80101d60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d63:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101d67:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6a:	66 89 50 22          	mov    %dx,0x22(%eax)
    ip->size = dip->size;
80101d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d71:	8b 50 08             	mov    0x8(%eax),%edx
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	89 50 24             	mov    %edx,0x24(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d7d:	8d 50 0c             	lea    0xc(%eax),%edx
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	83 c0 28             	add    $0x28,%eax
80101d86:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101d8d:	00 
80101d8e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d92:	89 04 24             	mov    %eax,(%esp)
80101d95:	e8 e7 3b 00 00       	call   80105981 <memmove>
    brelse(bp);
80101d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d9d:	89 04 24             	mov    %eax,(%esp)
80101da0:	e8 72 e4 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101da5:	8b 45 08             	mov    0x8(%ebp),%eax
80101da8:	8b 40 08             	mov    0x8(%eax),%eax
80101dab:	83 c8 02             	or     $0x2,%eax
80101dae:	89 c2                	mov    %eax,%edx
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	89 50 08             	mov    %edx,0x8(%eax)
    if(ip->type == 0)
80101db6:	8b 45 08             	mov    0x8(%ebp),%eax
80101db9:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
80101dbd:	66 85 c0             	test   %ax,%ax
80101dc0:	75 0c                	jne    80101dce <ilock+0x1b8>
      panic("ilock: no type");
80101dc2:	c7 04 24 be 8e 10 80 	movl   $0x80108ebe,(%esp)
80101dc9:	e8 6c e7 ff ff       	call   8010053a <panic>
  }
}
80101dce:	83 c4 54             	add    $0x54,%esp
80101dd1:	5b                   	pop    %ebx
80101dd2:	5d                   	pop    %ebp
80101dd3:	c3                   	ret    

80101dd4 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101dd4:	55                   	push   %ebp
80101dd5:	89 e5                	mov    %esp,%ebp
80101dd7:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101dda:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101dde:	74 17                	je     80101df7 <iunlock+0x23>
80101de0:	8b 45 08             	mov    0x8(%ebp),%eax
80101de3:	8b 40 08             	mov    0x8(%eax),%eax
80101de6:	83 e0 01             	and    $0x1,%eax
80101de9:	85 c0                	test   %eax,%eax
80101deb:	74 0a                	je     80101df7 <iunlock+0x23>
80101ded:	8b 45 08             	mov    0x8(%ebp),%eax
80101df0:	8b 40 04             	mov    0x4(%eax),%eax
80101df3:	85 c0                	test   %eax,%eax
80101df5:	7f 0c                	jg     80101e03 <iunlock+0x2f>
    panic("iunlock");
80101df7:	c7 04 24 cd 8e 10 80 	movl   $0x80108ecd,(%esp)
80101dfe:	e8 37 e7 ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
80101e03:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101e0a:	e8 4f 38 00 00       	call   8010565e <acquire>
  ip->flags &= ~I_BUSY;
80101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e12:	8b 40 08             	mov    0x8(%eax),%eax
80101e15:	83 e0 fe             	and    $0xfffffffe,%eax
80101e18:	89 c2                	mov    %eax,%edx
80101e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1d:	89 50 08             	mov    %edx,0x8(%eax)
  wakeup(ip);
80101e20:	8b 45 08             	mov    0x8(%ebp),%eax
80101e23:	89 04 24             	mov    %eax,(%esp)
80101e26:	e8 42 36 00 00       	call   8010546d <wakeup>
  release(&icache.lock);
80101e2b:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101e32:	e8 89 38 00 00       	call   801056c0 <release>
}
80101e37:	c9                   	leave  
80101e38:	c3                   	ret    

80101e39 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101e39:	55                   	push   %ebp
80101e3a:	89 e5                	mov    %esp,%ebp
80101e3c:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101e3f:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101e46:	e8 13 38 00 00       	call   8010565e <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4e:	8b 40 04             	mov    0x4(%eax),%eax
80101e51:	83 f8 01             	cmp    $0x1,%eax
80101e54:	0f 85 93 00 00 00    	jne    80101eed <iput+0xb4>
80101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5d:	8b 40 08             	mov    0x8(%eax),%eax
80101e60:	83 e0 02             	and    $0x2,%eax
80101e63:	85 c0                	test   %eax,%eax
80101e65:	0f 84 82 00 00 00    	je     80101eed <iput+0xb4>
80101e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6e:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80101e72:	66 85 c0             	test   %ax,%ax
80101e75:	75 76                	jne    80101eed <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	8b 40 08             	mov    0x8(%eax),%eax
80101e7d:	83 e0 01             	and    $0x1,%eax
80101e80:	85 c0                	test   %eax,%eax
80101e82:	74 0c                	je     80101e90 <iput+0x57>
      panic("iput busy");
80101e84:	c7 04 24 d5 8e 10 80 	movl   $0x80108ed5,(%esp)
80101e8b:	e8 aa e6 ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101e90:	8b 45 08             	mov    0x8(%ebp),%eax
80101e93:	8b 40 08             	mov    0x8(%eax),%eax
80101e96:	83 c8 01             	or     $0x1,%eax
80101e99:	89 c2                	mov    %eax,%edx
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
80101ea1:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101ea8:	e8 13 38 00 00       	call   801056c0 <release>
    itrunc(ip);
80101ead:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb0:	89 04 24             	mov    %eax,(%esp)
80101eb3:	e8 8e 01 00 00       	call   80102046 <itrunc>
    ip->type = 0;
80101eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebb:	66 c7 40 1c 00 00    	movw   $0x0,0x1c(%eax)
    iupdate(ip);
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	89 04 24             	mov    %eax,(%esp)
80101ec7:	e8 6a fb ff ff       	call   80101a36 <iupdate>
    acquire(&icache.lock);
80101ecc:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101ed3:	e8 86 37 00 00       	call   8010565e <acquire>
    ip->flags = 0;
80101ed8:	8b 45 08             	mov    0x8(%ebp),%eax
80101edb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    wakeup(ip);
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	89 04 24             	mov    %eax,(%esp)
80101ee8:	e8 80 35 00 00       	call   8010546d <wakeup>
  }
  ip->ref--;
80101eed:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef0:	8b 40 04             	mov    0x4(%eax),%eax
80101ef3:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef9:	89 50 04             	mov    %edx,0x4(%eax)
  release(&icache.lock);
80101efc:	c7 04 24 20 3c 11 80 	movl   $0x80113c20,(%esp)
80101f03:	e8 b8 37 00 00       	call   801056c0 <release>
}
80101f08:	c9                   	leave  
80101f09:	c3                   	ret    

80101f0a <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101f0a:	55                   	push   %ebp
80101f0b:	89 e5                	mov    %esp,%ebp
80101f0d:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101f10:	8b 45 08             	mov    0x8(%ebp),%eax
80101f13:	89 04 24             	mov    %eax,(%esp)
80101f16:	e8 b9 fe ff ff       	call   80101dd4 <iunlock>
  iput(ip);
80101f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1e:	89 04 24             	mov    %eax,(%esp)
80101f21:	e8 13 ff ff ff       	call   80101e39 <iput>
}
80101f26:	c9                   	leave  
80101f27:	c3                   	ret    

80101f28 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101f28:	55                   	push   %ebp
80101f29:	89 e5                	mov    %esp,%ebp
80101f2b:	53                   	push   %ebx
80101f2c:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101f2f:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101f33:	77 3f                	ja     80101f74 <bmap+0x4c>
    if((addr = ip->addrs[bn]) == 0) {
80101f35:	8b 45 08             	mov    0x8(%ebp),%eax
80101f38:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f3b:	83 c2 08             	add    $0x8,%edx
80101f3e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80101f42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f49:	75 21                	jne    80101f6c <bmap+0x44>
      ip->addrs[bn] = addr = balloc(ip->prt);
80101f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4e:	8b 40 0c             	mov    0xc(%eax),%eax
80101f51:	89 04 24             	mov    %eax,(%esp)
80101f54:	e8 cb f6 ff ff       	call   80101624 <balloc>
80101f59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f62:	8d 4a 08             	lea    0x8(%edx),%ecx
80101f65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f68:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
    }
    return addr;
80101f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f6f:	e9 cc 00 00 00       	jmp    80102040 <bmap+0x118>
  }
  bn -= NDIRECT;
80101f74:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101f78:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101f7c:	0f 87 b2 00 00 00    	ja     80102034 <bmap+0x10c>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0) {
80101f82:	8b 45 08             	mov    0x8(%ebp),%eax
80101f85:	8b 40 58             	mov    0x58(%eax),%eax
80101f88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f8f:	75 1a                	jne    80101fab <bmap+0x83>
      ip->addrs[NDIRECT] = addr = balloc(ip->prt);
80101f91:	8b 45 08             	mov    0x8(%ebp),%eax
80101f94:	8b 40 0c             	mov    0xc(%eax),%eax
80101f97:	89 04 24             	mov    %eax,(%esp)
80101f9a:	e8 85 f6 ff ff       	call   80101624 <balloc>
80101f9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fa8:	89 50 58             	mov    %edx,0x58(%eax)
    }
    bp = bread(ip->prt->dev, addr + ip->prt->prt.offset);
80101fab:	8b 45 08             	mov    0x8(%ebp),%eax
80101fae:	8b 40 0c             	mov    0xc(%eax),%eax
80101fb1:	8b 50 0c             	mov    0xc(%eax),%edx
80101fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fb7:	01 c2                	add    %eax,%edx
80101fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbc:	8b 40 0c             	mov    0xc(%eax),%eax
80101fbf:	8b 00                	mov    (%eax),%eax
80101fc1:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fc5:	89 04 24             	mov    %eax,(%esp)
80101fc8:	e8 d9 e1 ff ff       	call   801001a6 <bread>
80101fcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fd3:	83 c0 18             	add    $0x18,%eax
80101fd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fdc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	8b 00                	mov    (%eax),%eax
80101fea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101fed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ff1:	75 31                	jne    80102024 <bmap+0xfc>
      a[bn] = addr = balloc(ip->prt);
80101ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102000:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80102003:	8b 45 08             	mov    0x8(%ebp),%eax
80102006:	8b 40 0c             	mov    0xc(%eax),%eax
80102009:	89 04 24             	mov    %eax,(%esp)
8010200c:	e8 13 f6 ff ff       	call   80101624 <balloc>
80102011:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102017:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80102019:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010201c:	89 04 24             	mov    %eax,(%esp)
8010201f:	e8 5c 1e 00 00       	call   80103e80 <log_write>
    }
    brelse(bp);
80102024:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102027:	89 04 24             	mov    %eax,(%esp)
8010202a:	e8 e8 e1 ff ff       	call   80100217 <brelse>
    return addr;
8010202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102032:	eb 0c                	jmp    80102040 <bmap+0x118>
  }

  panic("bmap: out of range");
80102034:	c7 04 24 df 8e 10 80 	movl   $0x80108edf,(%esp)
8010203b:	e8 fa e4 ff ff       	call   8010053a <panic>
}
80102040:	83 c4 24             	add    $0x24,%esp
80102043:	5b                   	pop    %ebx
80102044:	5d                   	pop    %ebp
80102045:	c3                   	ret    

80102046 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80102046:	55                   	push   %ebp
80102047:	89 e5                	mov    %esp,%ebp
80102049:	83 ec 38             	sub    $0x38,%esp
  int i, j;
  struct buf *bp;
  uint *a;
  struct dpartition* prt = &ip->prt->prt;
8010204c:	8b 45 08             	mov    0x8(%ebp),%eax
8010204f:	8b 40 0c             	mov    0xc(%eax),%eax
80102052:	83 c0 04             	add    $0x4,%eax
80102055:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(i = 0; i < NDIRECT; i++){
80102058:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010205f:	eb 4d                	jmp    801020ae <itrunc+0x68>
    if(ip->addrs[i]){
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102067:	83 c2 08             	add    $0x8,%edx
8010206a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	74 38                	je     801020aa <itrunc+0x64>
      bfree(ip->prt, ip->addrs[i] + prt->offset);
80102072:	8b 45 08             	mov    0x8(%ebp),%eax
80102075:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102078:	83 c2 08             	add    $0x8,%edx
8010207b:	8b 54 90 08          	mov    0x8(%eax,%edx,4),%edx
8010207f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102082:	8b 40 08             	mov    0x8(%eax),%eax
80102085:	01 c2                	add    %eax,%edx
80102087:	8b 45 08             	mov    0x8(%ebp),%eax
8010208a:	8b 40 0c             	mov    0xc(%eax),%eax
8010208d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102091:	89 04 24             	mov    %eax,(%esp)
80102094:	e8 04 f7 ff ff       	call   8010179d <bfree>
      ip->addrs[i] = 0;
80102099:	8b 45 08             	mov    0x8(%ebp),%eax
8010209c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010209f:	83 c2 08             	add    $0x8,%edx
801020a2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801020a9:	00 
  int i, j;
  struct buf *bp;
  uint *a;
  struct dpartition* prt = &ip->prt->prt;

  for(i = 0; i < NDIRECT; i++){
801020aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801020ae:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
801020b2:	7e ad                	jle    80102061 <itrunc+0x1b>
      bfree(ip->prt, ip->addrs[i] + prt->offset);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
801020b4:	8b 45 08             	mov    0x8(%ebp),%eax
801020b7:	8b 40 58             	mov    0x58(%eax),%eax
801020ba:	85 c0                	test   %eax,%eax
801020bc:	0f 84 b8 00 00 00    	je     8010217a <itrunc+0x134>
    bp = bread(ip->prt->dev, ip->addrs[NDIRECT] + prt->offset);
801020c2:	8b 45 08             	mov    0x8(%ebp),%eax
801020c5:	8b 50 58             	mov    0x58(%eax),%edx
801020c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020cb:	8b 40 08             	mov    0x8(%eax),%eax
801020ce:	01 c2                	add    %eax,%edx
801020d0:	8b 45 08             	mov    0x8(%ebp),%eax
801020d3:	8b 40 0c             	mov    0xc(%eax),%eax
801020d6:	8b 00                	mov    (%eax),%eax
801020d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801020dc:	89 04 24             	mov    %eax,(%esp)
801020df:	e8 c2 e0 ff ff       	call   801001a6 <bread>
801020e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    a = (uint*)bp->data;
801020e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801020ea:	83 c0 18             	add    $0x18,%eax
801020ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
801020f0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801020f7:	eb 44                	jmp    8010213d <itrunc+0xf7>
      if(a[j])
801020f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102103:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102106:	01 d0                	add    %edx,%eax
80102108:	8b 00                	mov    (%eax),%eax
8010210a:	85 c0                	test   %eax,%eax
8010210c:	74 2b                	je     80102139 <itrunc+0xf3>
        bfree(ip->prt, a[j] + prt->offset);
8010210e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102111:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102118:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010211b:	01 d0                	add    %edx,%eax
8010211d:	8b 10                	mov    (%eax),%edx
8010211f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102122:	8b 40 08             	mov    0x8(%eax),%eax
80102125:	01 c2                	add    %eax,%edx
80102127:	8b 45 08             	mov    0x8(%ebp),%eax
8010212a:	8b 40 0c             	mov    0xc(%eax),%eax
8010212d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102131:	89 04 24             	mov    %eax,(%esp)
80102134:	e8 64 f6 ff ff       	call   8010179d <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->prt->dev, ip->addrs[NDIRECT] + prt->offset);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80102139:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010213d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102140:	83 f8 7f             	cmp    $0x7f,%eax
80102143:	76 b4                	jbe    801020f9 <itrunc+0xb3>
      if(a[j])
        bfree(ip->prt, a[j] + prt->offset);
    }
    brelse(bp);
80102145:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102148:	89 04 24             	mov    %eax,(%esp)
8010214b:	e8 c7 e0 ff ff       	call   80100217 <brelse>
    bfree(ip->prt, ip->addrs[NDIRECT] + prt->offset);
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 50 58             	mov    0x58(%eax),%edx
80102156:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102159:	8b 40 08             	mov    0x8(%eax),%eax
8010215c:	01 c2                	add    %eax,%edx
8010215e:	8b 45 08             	mov    0x8(%ebp),%eax
80102161:	8b 40 0c             	mov    0xc(%eax),%eax
80102164:	89 54 24 04          	mov    %edx,0x4(%esp)
80102168:	89 04 24             	mov    %eax,(%esp)
8010216b:	e8 2d f6 ff ff       	call   8010179d <bfree>
    ip->addrs[NDIRECT] = 0;
80102170:	8b 45 08             	mov    0x8(%ebp),%eax
80102173:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  }

  ip->size = 0;
8010217a:	8b 45 08             	mov    0x8(%ebp),%eax
8010217d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
  iupdate(ip);
80102184:	8b 45 08             	mov    0x8(%ebp),%eax
80102187:	89 04 24             	mov    %eax,(%esp)
8010218a:	e8 a7 f8 ff ff       	call   80101a36 <iupdate>
}
8010218f:	c9                   	leave  
80102190:	c3                   	ret    

80102191 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102191:	55                   	push   %ebp
80102192:	89 e5                	mov    %esp,%ebp
  st->dev = ip->prt->dev;
80102194:	8b 45 08             	mov    0x8(%ebp),%eax
80102197:	8b 40 0c             	mov    0xc(%eax),%eax
8010219a:	8b 00                	mov    (%eax),%eax
8010219c:	89 c2                	mov    %eax,%edx
8010219e:	8b 45 0c             	mov    0xc(%ebp),%eax
801021a1:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
801021a4:	8b 45 08             	mov    0x8(%ebp),%eax
801021a7:	8b 10                	mov    (%eax),%edx
801021a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801021ac:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
801021af:	8b 45 08             	mov    0x8(%ebp),%eax
801021b2:	0f b7 50 1c          	movzwl 0x1c(%eax),%edx
801021b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801021b9:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801021bc:	8b 45 08             	mov    0x8(%ebp),%eax
801021bf:	0f b7 50 22          	movzwl 0x22(%eax),%edx
801021c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801021c6:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801021ca:	8b 45 08             	mov    0x8(%ebp),%eax
801021cd:	8b 50 24             	mov    0x24(%eax),%edx
801021d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801021d3:	89 50 10             	mov    %edx,0x10(%eax)
  st->prti = ip->prt - partitions;
801021d6:	8b 45 08             	mov    0x8(%ebp),%eax
801021d9:	8b 40 0c             	mov    0xc(%eax),%eax
801021dc:	89 c2                	mov    %eax,%edx
801021de:	b8 c0 3b 11 80       	mov    $0x80113bc0,%eax
801021e3:	29 c2                	sub    %eax,%edx
801021e5:	89 d0                	mov    %edx,%eax
801021e7:	c1 f8 02             	sar    $0x2,%eax
801021ea:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
801021f0:	89 c2                	mov    %eax,%edx
801021f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801021f5:	89 50 14             	mov    %edx,0x14(%eax)
}
801021f8:	5d                   	pop    %ebp
801021f9:	c3                   	ret    

801021fa <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801021fa:	55                   	push   %ebp
801021fb:	89 e5                	mov    %esp,%ebp
801021fd:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;
  struct dpartition* prt = &ip->prt->prt;
80102200:	8b 45 08             	mov    0x8(%ebp),%eax
80102203:	8b 40 0c             	mov    0xc(%eax),%eax
80102206:	83 c0 04             	add    $0x4,%eax
80102209:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(ip->type == T_DEV){
8010220c:	8b 45 08             	mov    0x8(%ebp),%eax
8010220f:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
80102213:	66 83 f8 03          	cmp    $0x3,%ax
80102217:	75 60                	jne    80102279 <readi+0x7f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102219:	8b 45 08             	mov    0x8(%ebp),%eax
8010221c:	0f b7 40 1e          	movzwl 0x1e(%eax),%eax
80102220:	66 85 c0             	test   %ax,%ax
80102223:	78 20                	js     80102245 <readi+0x4b>
80102225:	8b 45 08             	mov    0x8(%ebp),%eax
80102228:	0f b7 40 1e          	movzwl 0x1e(%eax),%eax
8010222c:	66 83 f8 09          	cmp    $0x9,%ax
80102230:	7f 13                	jg     80102245 <readi+0x4b>
80102232:	8b 45 08             	mov    0x8(%ebp),%eax
80102235:	0f b7 40 1e          	movzwl 0x1e(%eax),%eax
80102239:	98                   	cwtl   
8010223a:	8b 04 c5 c0 21 11 80 	mov    -0x7feede40(,%eax,8),%eax
80102241:	85 c0                	test   %eax,%eax
80102243:	75 0a                	jne    8010224f <readi+0x55>
      return -1;
80102245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010224a:	e9 24 01 00 00       	jmp    80102373 <readi+0x179>
    return devsw[ip->major].read(ip, dst, n);
8010224f:	8b 45 08             	mov    0x8(%ebp),%eax
80102252:	0f b7 40 1e          	movzwl 0x1e(%eax),%eax
80102256:	98                   	cwtl   
80102257:	8b 04 c5 c0 21 11 80 	mov    -0x7feede40(,%eax,8),%eax
8010225e:	8b 55 14             	mov    0x14(%ebp),%edx
80102261:	89 54 24 08          	mov    %edx,0x8(%esp)
80102265:	8b 55 0c             	mov    0xc(%ebp),%edx
80102268:	89 54 24 04          	mov    %edx,0x4(%esp)
8010226c:	8b 55 08             	mov    0x8(%ebp),%edx
8010226f:	89 14 24             	mov    %edx,(%esp)
80102272:	ff d0                	call   *%eax
80102274:	e9 fa 00 00 00       	jmp    80102373 <readi+0x179>
  }

  if(off > ip->size || off + n < off)
80102279:	8b 45 08             	mov    0x8(%ebp),%eax
8010227c:	8b 40 24             	mov    0x24(%eax),%eax
8010227f:	3b 45 10             	cmp    0x10(%ebp),%eax
80102282:	72 0d                	jb     80102291 <readi+0x97>
80102284:	8b 45 14             	mov    0x14(%ebp),%eax
80102287:	8b 55 10             	mov    0x10(%ebp),%edx
8010228a:	01 d0                	add    %edx,%eax
8010228c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010228f:	73 0a                	jae    8010229b <readi+0xa1>
    return -1;
80102291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102296:	e9 d8 00 00 00       	jmp    80102373 <readi+0x179>
  if(off + n > ip->size)
8010229b:	8b 45 14             	mov    0x14(%ebp),%eax
8010229e:	8b 55 10             	mov    0x10(%ebp),%edx
801022a1:	01 c2                	add    %eax,%edx
801022a3:	8b 45 08             	mov    0x8(%ebp),%eax
801022a6:	8b 40 24             	mov    0x24(%eax),%eax
801022a9:	39 c2                	cmp    %eax,%edx
801022ab:	76 0c                	jbe    801022b9 <readi+0xbf>
    n = ip->size - off;
801022ad:	8b 45 08             	mov    0x8(%ebp),%eax
801022b0:	8b 40 24             	mov    0x24(%eax),%eax
801022b3:	2b 45 10             	sub    0x10(%ebp),%eax
801022b6:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801022b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c0:	e9 9f 00 00 00       	jmp    80102364 <readi+0x16a>
    bp = bread(ip->prt->dev, bmap(ip, off/BSIZE) + prt->offset);
801022c5:	8b 45 10             	mov    0x10(%ebp),%eax
801022c8:	c1 e8 09             	shr    $0x9,%eax
801022cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801022cf:	8b 45 08             	mov    0x8(%ebp),%eax
801022d2:	89 04 24             	mov    %eax,(%esp)
801022d5:	e8 4e fc ff ff       	call   80101f28 <bmap>
801022da:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022dd:	8b 52 08             	mov    0x8(%edx),%edx
801022e0:	01 c2                	add    %eax,%edx
801022e2:	8b 45 08             	mov    0x8(%ebp),%eax
801022e5:	8b 40 0c             	mov    0xc(%eax),%eax
801022e8:	8b 00                	mov    (%eax),%eax
801022ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801022ee:	89 04 24             	mov    %eax,(%esp)
801022f1:	e8 b0 de ff ff       	call   801001a6 <bread>
801022f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022f9:	8b 45 10             	mov    0x10(%ebp),%eax
801022fc:	25 ff 01 00 00       	and    $0x1ff,%eax
80102301:	89 c2                	mov    %eax,%edx
80102303:	b8 00 02 00 00       	mov    $0x200,%eax
80102308:	29 d0                	sub    %edx,%eax
8010230a:	89 c2                	mov    %eax,%edx
8010230c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230f:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102312:	29 c1                	sub    %eax,%ecx
80102314:	89 c8                	mov    %ecx,%eax
80102316:	39 c2                	cmp    %eax,%edx
80102318:	0f 46 c2             	cmovbe %edx,%eax
8010231b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010231e:	8b 45 10             	mov    0x10(%ebp),%eax
80102321:	25 ff 01 00 00       	and    $0x1ff,%eax
80102326:	8d 50 10             	lea    0x10(%eax),%edx
80102329:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010232c:	01 d0                	add    %edx,%eax
8010232e:	8d 50 08             	lea    0x8(%eax),%edx
80102331:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102334:	89 44 24 08          	mov    %eax,0x8(%esp)
80102338:	89 54 24 04          	mov    %edx,0x4(%esp)
8010233c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010233f:	89 04 24             	mov    %eax,(%esp)
80102342:	e8 3a 36 00 00       	call   80105981 <memmove>
    brelse(bp);
80102347:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010234a:	89 04 24             	mov    %eax,(%esp)
8010234d:	e8 c5 de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102352:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102355:	01 45 f4             	add    %eax,-0xc(%ebp)
80102358:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010235b:	01 45 10             	add    %eax,0x10(%ebp)
8010235e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102361:	01 45 0c             	add    %eax,0xc(%ebp)
80102364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102367:	3b 45 14             	cmp    0x14(%ebp),%eax
8010236a:	0f 82 55 ff ff ff    	jb     801022c5 <readi+0xcb>
    bp = bread(ip->prt->dev, bmap(ip, off/BSIZE) + prt->offset);
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102370:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102373:	c9                   	leave  
80102374:	c3                   	ret    

80102375 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102375:	55                   	push   %ebp
80102376:	89 e5                	mov    %esp,%ebp
80102378:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;
  struct dpartition* prt = &ip->prt->prt;
8010237b:	8b 45 08             	mov    0x8(%ebp),%eax
8010237e:	8b 40 0c             	mov    0xc(%eax),%eax
80102381:	83 c0 04             	add    $0x4,%eax
80102384:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(ip->type == T_DEV){
80102387:	8b 45 08             	mov    0x8(%ebp),%eax
8010238a:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
8010238e:	66 83 f8 03          	cmp    $0x3,%ax
80102392:	75 60                	jne    801023f4 <writei+0x7f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102394:	8b 45 08             	mov    0x8(%ebp),%eax
80102397:	0f b7 40 1e          	movzwl 0x1e(%eax),%eax
8010239b:	66 85 c0             	test   %ax,%ax
8010239e:	78 20                	js     801023c0 <writei+0x4b>
801023a0:	8b 45 08             	mov    0x8(%ebp),%eax
801023a3:	0f b7 40 1e          	movzwl 0x1e(%eax),%eax
801023a7:	66 83 f8 09          	cmp    $0x9,%ax
801023ab:	7f 13                	jg     801023c0 <writei+0x4b>
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	0f b7 40 1e          	movzwl 0x1e(%eax),%eax
801023b4:	98                   	cwtl   
801023b5:	8b 04 c5 c4 21 11 80 	mov    -0x7feede3c(,%eax,8),%eax
801023bc:	85 c0                	test   %eax,%eax
801023be:	75 0a                	jne    801023ca <writei+0x55>
      return -1;
801023c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023c5:	e9 4f 01 00 00       	jmp    80102519 <writei+0x1a4>
    return devsw[ip->major].write(ip, src, n);
801023ca:	8b 45 08             	mov    0x8(%ebp),%eax
801023cd:	0f b7 40 1e          	movzwl 0x1e(%eax),%eax
801023d1:	98                   	cwtl   
801023d2:	8b 04 c5 c4 21 11 80 	mov    -0x7feede3c(,%eax,8),%eax
801023d9:	8b 55 14             	mov    0x14(%ebp),%edx
801023dc:	89 54 24 08          	mov    %edx,0x8(%esp)
801023e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
801023e7:	8b 55 08             	mov    0x8(%ebp),%edx
801023ea:	89 14 24             	mov    %edx,(%esp)
801023ed:	ff d0                	call   *%eax
801023ef:	e9 25 01 00 00       	jmp    80102519 <writei+0x1a4>
  }

  if(off > ip->size || off + n < off)
801023f4:	8b 45 08             	mov    0x8(%ebp),%eax
801023f7:	8b 40 24             	mov    0x24(%eax),%eax
801023fa:	3b 45 10             	cmp    0x10(%ebp),%eax
801023fd:	72 0d                	jb     8010240c <writei+0x97>
801023ff:	8b 45 14             	mov    0x14(%ebp),%eax
80102402:	8b 55 10             	mov    0x10(%ebp),%edx
80102405:	01 d0                	add    %edx,%eax
80102407:	3b 45 10             	cmp    0x10(%ebp),%eax
8010240a:	73 0a                	jae    80102416 <writei+0xa1>
    return -1;
8010240c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102411:	e9 03 01 00 00       	jmp    80102519 <writei+0x1a4>
  if(off + n > MAXFILE*BSIZE)
80102416:	8b 45 14             	mov    0x14(%ebp),%eax
80102419:	8b 55 10             	mov    0x10(%ebp),%edx
8010241c:	01 d0                	add    %edx,%eax
8010241e:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102423:	76 0a                	jbe    8010242f <writei+0xba>
    return -1;
80102425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010242a:	e9 ea 00 00 00       	jmp    80102519 <writei+0x1a4>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010242f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102436:	e9 aa 00 00 00       	jmp    801024e5 <writei+0x170>
    bp = bread(ip->prt->dev, bmap(ip, off/BSIZE) + prt->offset);
8010243b:	8b 45 10             	mov    0x10(%ebp),%eax
8010243e:	c1 e8 09             	shr    $0x9,%eax
80102441:	89 44 24 04          	mov    %eax,0x4(%esp)
80102445:	8b 45 08             	mov    0x8(%ebp),%eax
80102448:	89 04 24             	mov    %eax,(%esp)
8010244b:	e8 d8 fa ff ff       	call   80101f28 <bmap>
80102450:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102453:	8b 52 08             	mov    0x8(%edx),%edx
80102456:	01 c2                	add    %eax,%edx
80102458:	8b 45 08             	mov    0x8(%ebp),%eax
8010245b:	8b 40 0c             	mov    0xc(%eax),%eax
8010245e:	8b 00                	mov    (%eax),%eax
80102460:	89 54 24 04          	mov    %edx,0x4(%esp)
80102464:	89 04 24             	mov    %eax,(%esp)
80102467:	e8 3a dd ff ff       	call   801001a6 <bread>
8010246c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010246f:	8b 45 10             	mov    0x10(%ebp),%eax
80102472:	25 ff 01 00 00       	and    $0x1ff,%eax
80102477:	89 c2                	mov    %eax,%edx
80102479:	b8 00 02 00 00       	mov    $0x200,%eax
8010247e:	29 d0                	sub    %edx,%eax
80102480:	89 c2                	mov    %eax,%edx
80102482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102485:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102488:	29 c1                	sub    %eax,%ecx
8010248a:	89 c8                	mov    %ecx,%eax
8010248c:	39 c2                	cmp    %eax,%edx
8010248e:	0f 46 c2             	cmovbe %edx,%eax
80102491:	89 45 e8             	mov    %eax,-0x18(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102494:	8b 45 10             	mov    0x10(%ebp),%eax
80102497:	25 ff 01 00 00       	and    $0x1ff,%eax
8010249c:	8d 50 10             	lea    0x10(%eax),%edx
8010249f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801024a2:	01 d0                	add    %edx,%eax
801024a4:	8d 50 08             	lea    0x8(%eax),%edx
801024a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801024aa:	89 44 24 08          	mov    %eax,0x8(%esp)
801024ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801024b5:	89 14 24             	mov    %edx,(%esp)
801024b8:	e8 c4 34 00 00       	call   80105981 <memmove>
    log_write(bp);
801024bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801024c0:	89 04 24             	mov    %eax,(%esp)
801024c3:	e8 b8 19 00 00       	call   80103e80 <log_write>
    brelse(bp);
801024c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801024cb:	89 04 24             	mov    %eax,(%esp)
801024ce:	e8 44 dd ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801024d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801024d6:	01 45 f4             	add    %eax,-0xc(%ebp)
801024d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801024dc:	01 45 10             	add    %eax,0x10(%ebp)
801024df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801024e2:	01 45 0c             	add    %eax,0xc(%ebp)
801024e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e8:	3b 45 14             	cmp    0x14(%ebp),%eax
801024eb:	0f 82 4a ff ff ff    	jb     8010243b <writei+0xc6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801024f1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801024f5:	74 1f                	je     80102516 <writei+0x1a1>
801024f7:	8b 45 08             	mov    0x8(%ebp),%eax
801024fa:	8b 40 24             	mov    0x24(%eax),%eax
801024fd:	3b 45 10             	cmp    0x10(%ebp),%eax
80102500:	73 14                	jae    80102516 <writei+0x1a1>
    ip->size = off;
80102502:	8b 45 08             	mov    0x8(%ebp),%eax
80102505:	8b 55 10             	mov    0x10(%ebp),%edx
80102508:	89 50 24             	mov    %edx,0x24(%eax)
    iupdate(ip);
8010250b:	8b 45 08             	mov    0x8(%ebp),%eax
8010250e:	89 04 24             	mov    %eax,(%esp)
80102511:	e8 20 f5 ff ff       	call   80101a36 <iupdate>
  }
  return n;
80102516:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102519:	c9                   	leave  
8010251a:	c3                   	ret    

8010251b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010251b:	55                   	push   %ebp
8010251c:	89 e5                	mov    %esp,%ebp
8010251e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102521:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102528:	00 
80102529:	8b 45 0c             	mov    0xc(%ebp),%eax
8010252c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102530:	8b 45 08             	mov    0x8(%ebp),%eax
80102533:	89 04 24             	mov    %eax,(%esp)
80102536:	e8 e9 34 00 00       	call   80105a24 <strncmp>
}
8010253b:	c9                   	leave  
8010253c:	c3                   	ret    

8010253d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010253d:	55                   	push   %ebp
8010253e:	89 e5                	mov    %esp,%ebp
80102540:	83 ec 48             	sub    $0x48,%esp
  uint off, inum;
  int mnt_in;
  struct partition* mnt_prt;
  struct dirent de;
  int flag = is_inode_mounted(dp, &mnt_in, &mnt_prt);
80102543:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102546:	89 44 24 08          	mov    %eax,0x8(%esp)
8010254a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010254d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102551:	8b 45 08             	mov    0x8(%ebp),%eax
80102554:	89 04 24             	mov    %eax,(%esp)
80102557:	e8 b0 04 00 00       	call   80102a0c <is_inode_mounted>
8010255c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dp = flag ? iget(mnt_prt, mnt_in) : dp;
8010255f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102563:	74 16                	je     8010257b <dirlookup+0x3e>
80102565:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102568:	89 c2                	mov    %eax,%edx
8010256a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010256d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102571:	89 04 24             	mov    %eax,(%esp)
80102574:	e8 8f f5 ff ff       	call   80101b08 <iget>
80102579:	eb 03                	jmp    8010257e <dirlookup+0x41>
8010257b:	8b 45 08             	mov    0x8(%ebp),%eax
8010257e:	89 45 08             	mov    %eax,0x8(%ebp)
  if(dp->type != T_DIR) {
80102581:	8b 45 08             	mov    0x8(%ebp),%eax
80102584:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
80102588:	66 83 f8 01          	cmp    $0x1,%ax
8010258c:	74 0c                	je     8010259a <dirlookup+0x5d>
    panic("dirlookup not DIR");
8010258e:	c7 04 24 f2 8e 10 80 	movl   $0x80108ef2,(%esp)
80102595:	e8 a0 df ff ff       	call   8010053a <panic>
  }
  for(off = 0; off < dp->size; off += sizeof(de)){
8010259a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025a1:	e9 89 00 00 00       	jmp    8010262f <dirlookup+0xf2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801025a6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801025ad:	00 
801025ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025b1:	89 44 24 08          	mov    %eax,0x8(%esp)
801025b5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
801025b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801025bc:	8b 45 08             	mov    0x8(%ebp),%eax
801025bf:	89 04 24             	mov    %eax,(%esp)
801025c2:	e8 33 fc ff ff       	call   801021fa <readi>
801025c7:	83 f8 10             	cmp    $0x10,%eax
801025ca:	74 0c                	je     801025d8 <dirlookup+0x9b>
      panic("dirlink read");
801025cc:	c7 04 24 04 8f 10 80 	movl   $0x80108f04,(%esp)
801025d3:	e8 62 df ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801025d8:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
801025dc:	66 85 c0             	test   %ax,%ax
801025df:	75 02                	jne    801025e3 <dirlookup+0xa6>
      continue;
801025e1:	eb 48                	jmp    8010262b <dirlookup+0xee>
    if(namecmp(name, de.name) == 0){
801025e3:	8d 45 d4             	lea    -0x2c(%ebp),%eax
801025e6:	83 c0 02             	add    $0x2,%eax
801025e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801025ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801025f0:	89 04 24             	mov    %eax,(%esp)
801025f3:	e8 23 ff ff ff       	call   8010251b <namecmp>
801025f8:	85 c0                	test   %eax,%eax
801025fa:	75 2f                	jne    8010262b <dirlookup+0xee>
      // entry matches path element
      if(poff)
801025fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102600:	74 08                	je     8010260a <dirlookup+0xcd>
        *poff = off;
80102602:	8b 45 10             	mov    0x10(%ebp),%eax
80102605:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102608:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010260a:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
8010260e:	0f b7 c0             	movzwl %ax,%eax
80102611:	89 45 ec             	mov    %eax,-0x14(%ebp)
      return iget(dp->prt, inum);
80102614:	8b 45 08             	mov    0x8(%ebp),%eax
80102617:	8b 40 0c             	mov    0xc(%eax),%eax
8010261a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010261d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102621:	89 04 24             	mov    %eax,(%esp)
80102624:	e8 df f4 ff ff       	call   80101b08 <iget>
80102629:	eb 18                	jmp    80102643 <dirlookup+0x106>
  int flag = is_inode_mounted(dp, &mnt_in, &mnt_prt);
  dp = flag ? iget(mnt_prt, mnt_in) : dp;
  if(dp->type != T_DIR) {
    panic("dirlookup not DIR");
  }
  for(off = 0; off < dp->size; off += sizeof(de)){
8010262b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010262f:	8b 45 08             	mov    0x8(%ebp),%eax
80102632:	8b 40 24             	mov    0x24(%eax),%eax
80102635:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102638:	0f 87 68 ff ff ff    	ja     801025a6 <dirlookup+0x69>
        *poff = off;
      inum = de.inum;
      return iget(dp->prt, inum);
   }
  }
  return 0;
8010263e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102643:	c9                   	leave  
80102644:	c3                   	ret    

80102645 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102645:	55                   	push   %ebp
80102646:	89 e5                	mov    %esp,%ebp
80102648:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010264b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102652:	00 
80102653:	8b 45 0c             	mov    0xc(%ebp),%eax
80102656:	89 44 24 04          	mov    %eax,0x4(%esp)
8010265a:	8b 45 08             	mov    0x8(%ebp),%eax
8010265d:	89 04 24             	mov    %eax,(%esp)
80102660:	e8 d8 fe ff ff       	call   8010253d <dirlookup>
80102665:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102668:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010266c:	74 15                	je     80102683 <dirlink+0x3e>
    iput(ip);
8010266e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102671:	89 04 24             	mov    %eax,(%esp)
80102674:	e8 c0 f7 ff ff       	call   80101e39 <iput>
    return -1;
80102679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010267e:	e9 b7 00 00 00       	jmp    8010273a <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102683:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010268a:	eb 46                	jmp    801026d2 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010268c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010268f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102696:	00 
80102697:	89 44 24 08          	mov    %eax,0x8(%esp)
8010269b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010269e:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a2:	8b 45 08             	mov    0x8(%ebp),%eax
801026a5:	89 04 24             	mov    %eax,(%esp)
801026a8:	e8 4d fb ff ff       	call   801021fa <readi>
801026ad:	83 f8 10             	cmp    $0x10,%eax
801026b0:	74 0c                	je     801026be <dirlink+0x79>
      panic("dirlink read");
801026b2:	c7 04 24 04 8f 10 80 	movl   $0x80108f04,(%esp)
801026b9:	e8 7c de ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801026be:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801026c2:	66 85 c0             	test   %ax,%ax
801026c5:	75 02                	jne    801026c9 <dirlink+0x84>
      break;
801026c7:	eb 16                	jmp    801026df <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801026c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026cc:	83 c0 10             	add    $0x10,%eax
801026cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801026d5:	8b 45 08             	mov    0x8(%ebp),%eax
801026d8:	8b 40 24             	mov    0x24(%eax),%eax
801026db:	39 c2                	cmp    %eax,%edx
801026dd:	72 ad                	jb     8010268c <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801026df:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801026e6:	00 
801026e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801026ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
801026f1:	83 c0 02             	add    $0x2,%eax
801026f4:	89 04 24             	mov    %eax,(%esp)
801026f7:	e8 7e 33 00 00       	call   80105a7a <strncpy>
  de.inum = inum;
801026fc:	8b 45 10             	mov    0x10(%ebp),%eax
801026ff:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102706:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010270d:	00 
8010270e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102712:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102715:	89 44 24 04          	mov    %eax,0x4(%esp)
80102719:	8b 45 08             	mov    0x8(%ebp),%eax
8010271c:	89 04 24             	mov    %eax,(%esp)
8010271f:	e8 51 fc ff ff       	call   80102375 <writei>
80102724:	83 f8 10             	cmp    $0x10,%eax
80102727:	74 0c                	je     80102735 <dirlink+0xf0>
    panic("dirlink");
80102729:	c7 04 24 11 8f 10 80 	movl   $0x80108f11,(%esp)
80102730:	e8 05 de ff ff       	call   8010053a <panic>
  
  return 0;
80102735:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010273a:	c9                   	leave  
8010273b:	c3                   	ret    

8010273c <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010273c:	55                   	push   %ebp
8010273d:	89 e5                	mov    %esp,%ebp
8010273f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102742:	eb 04                	jmp    80102748 <skipelem+0xc>
    path++;
80102744:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102748:	8b 45 08             	mov    0x8(%ebp),%eax
8010274b:	0f b6 00             	movzbl (%eax),%eax
8010274e:	3c 2f                	cmp    $0x2f,%al
80102750:	74 f2                	je     80102744 <skipelem+0x8>
    path++;
  if(*path == 0)
80102752:	8b 45 08             	mov    0x8(%ebp),%eax
80102755:	0f b6 00             	movzbl (%eax),%eax
80102758:	84 c0                	test   %al,%al
8010275a:	75 0a                	jne    80102766 <skipelem+0x2a>
    return 0;
8010275c:	b8 00 00 00 00       	mov    $0x0,%eax
80102761:	e9 86 00 00 00       	jmp    801027ec <skipelem+0xb0>
  s = path;
80102766:	8b 45 08             	mov    0x8(%ebp),%eax
80102769:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010276c:	eb 04                	jmp    80102772 <skipelem+0x36>
    path++;
8010276e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102772:	8b 45 08             	mov    0x8(%ebp),%eax
80102775:	0f b6 00             	movzbl (%eax),%eax
80102778:	3c 2f                	cmp    $0x2f,%al
8010277a:	74 0a                	je     80102786 <skipelem+0x4a>
8010277c:	8b 45 08             	mov    0x8(%ebp),%eax
8010277f:	0f b6 00             	movzbl (%eax),%eax
80102782:	84 c0                	test   %al,%al
80102784:	75 e8                	jne    8010276e <skipelem+0x32>
    path++;
  len = path - s;
80102786:	8b 55 08             	mov    0x8(%ebp),%edx
80102789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278c:	29 c2                	sub    %eax,%edx
8010278e:	89 d0                	mov    %edx,%eax
80102790:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102793:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102797:	7e 1c                	jle    801027b5 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
80102799:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801027a0:	00 
801027a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801027ab:	89 04 24             	mov    %eax,(%esp)
801027ae:	e8 ce 31 00 00       	call   80105981 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801027b3:	eb 2a                	jmp    801027df <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801027b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b8:	89 44 24 08          	mov    %eax,0x8(%esp)
801027bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801027c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801027c6:	89 04 24             	mov    %eax,(%esp)
801027c9:	e8 b3 31 00 00       	call   80105981 <memmove>
    name[len] = 0;
801027ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801027d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801027d4:	01 d0                	add    %edx,%eax
801027d6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801027d9:	eb 04                	jmp    801027df <skipelem+0xa3>
    path++;
801027db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801027df:	8b 45 08             	mov    0x8(%ebp),%eax
801027e2:	0f b6 00             	movzbl (%eax),%eax
801027e5:	3c 2f                	cmp    $0x2f,%al
801027e7:	74 f2                	je     801027db <skipelem+0x9f>
    path++;
  return path;
801027e9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801027ec:	c9                   	leave  
801027ed:	c3                   	ret    

801027ee <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801027ee:	55                   	push   %ebp
801027ef:	89 e5                	mov    %esp,%ebp
801027f1:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next, *tmp;
//  int flag = 0; 
  if (is_mounted(path)) {
801027f4:	8b 45 08             	mov    0x8(%ebp),%eax
801027f7:	89 04 24             	mov    %eax,(%esp)
801027fa:	e8 bf 02 00 00       	call   80102abe <is_mounted>
801027ff:	85 c0                	test   %eax,%eax
80102801:	74 2a                	je     8010282d <namex+0x3f>
    ip = iget(find_mp(path)->prt, ROOTINO);
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	89 04 24             	mov    %eax,(%esp)
80102809:	e8 bd 01 00 00       	call   801029cb <find_mp>
8010280e:	8b 40 12             	mov    0x12(%eax),%eax
80102811:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102818:	00 
80102819:	89 04 24             	mov    %eax,(%esp)
8010281c:	e8 e7 f2 ff ff       	call   80101b08 <iget>
80102821:	89 45 f4             	mov    %eax,-0xc(%ebp)
    path = "/"; 
80102824:	c7 45 08 19 8f 10 80 	movl   $0x80108f19,0x8(%ebp)
8010282b:	eb 3d                	jmp    8010286a <namex+0x7c>
  } else if(*path == '/') {
8010282d:	8b 45 08             	mov    0x8(%ebp),%eax
80102830:	0f b6 00             	movzbl (%eax),%eax
80102833:	3c 2f                	cmp    $0x2f,%al
80102835:	75 1a                	jne    80102851 <namex+0x63>
    ip = iget(boot_part, ROOTINO);
80102837:	a1 10 3c 11 80       	mov    0x80113c10,%eax
8010283c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102843:	00 
80102844:	89 04 24             	mov    %eax,(%esp)
80102847:	e8 bc f2 ff ff       	call   80101b08 <iget>
8010284c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010284f:	eb 19                	jmp    8010286a <namex+0x7c>
  }
  else {
    ip = idup(proc->cwd);
80102851:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102857:	8b 40 68             	mov    0x68(%eax),%eax
8010285a:	89 04 24             	mov    %eax,(%esp)
8010285d:	e8 82 f3 ff ff       	call   80101be4 <idup>
80102862:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  while((path = skipelem(path, name)) != 0){
80102865:	e9 b4 00 00 00       	jmp    8010291e <namex+0x130>
8010286a:	e9 af 00 00 00       	jmp    8010291e <namex+0x130>
    ilock(ip);
8010286f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102872:	89 04 24             	mov    %eax,(%esp)
80102875:	e8 9c f3 ff ff       	call   80101c16 <ilock>
    if(ip->type != T_DIR){
8010287a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287d:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
80102881:	66 83 f8 01          	cmp    $0x1,%ax
80102885:	74 15                	je     8010289c <namex+0xae>
      iunlockput(ip);
80102887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010288a:	89 04 24             	mov    %eax,(%esp)
8010288d:	e8 78 f6 ff ff       	call   80101f0a <iunlockput>
      return 0;
80102892:	b8 00 00 00 00       	mov    $0x0,%eax
80102897:	e9 bc 00 00 00       	jmp    80102958 <namex+0x16a>
    }
    
    if(nameiparent && *path == '\0'){
8010289c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801028a0:	74 36                	je     801028d8 <namex+0xea>
801028a2:	8b 45 08             	mov    0x8(%ebp),%eax
801028a5:	0f b6 00             	movzbl (%eax),%eax
801028a8:	84 c0                	test   %al,%al
801028aa:	75 2c                	jne    801028d8 <namex+0xea>
      // Stop one level early.
      tmp = check_mounted(ip);
801028ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028af:	89 04 24             	mov    %eax,(%esp)
801028b2:	e8 68 03 00 00       	call   80102c1f <check_mounted>
801028b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      iunlock(ip);
801028ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bd:	89 04 24             	mov    %eax,(%esp)
801028c0:	e8 0f f5 ff ff       	call   80101dd4 <iunlock>
      return tmp == 0 ? ip : tmp;
801028c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801028c9:	75 05                	jne    801028d0 <namex+0xe2>
801028cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ce:	eb 03                	jmp    801028d3 <namex+0xe5>
801028d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028d3:	e9 80 00 00 00       	jmp    80102958 <namex+0x16a>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801028d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801028df:	00 
801028e0:	8b 45 10             	mov    0x10(%ebp),%eax
801028e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801028e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ea:	89 04 24             	mov    %eax,(%esp)
801028ed:	e8 4b fc ff ff       	call   8010253d <dirlookup>
801028f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801028f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801028f9:	75 12                	jne    8010290d <namex+0x11f>
      iunlockput(ip);
801028fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028fe:	89 04 24             	mov    %eax,(%esp)
80102901:	e8 04 f6 ff ff       	call   80101f0a <iunlockput>
      return 0;
80102906:	b8 00 00 00 00       	mov    $0x0,%eax
8010290b:	eb 4b                	jmp    80102958 <namex+0x16a>
    }
    iunlockput(ip);
8010290d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102910:	89 04 24             	mov    %eax,(%esp)
80102913:	e8 f2 f5 ff ff       	call   80101f0a <iunlockput>
    ip = next;
80102918:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010291b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ip = iget(boot_part, ROOTINO);
  }
  else {
    ip = idup(proc->cwd);
  }
  while((path = skipelem(path, name)) != 0){
8010291e:	8b 45 10             	mov    0x10(%ebp),%eax
80102921:	89 44 24 04          	mov    %eax,0x4(%esp)
80102925:	8b 45 08             	mov    0x8(%ebp),%eax
80102928:	89 04 24             	mov    %eax,(%esp)
8010292b:	e8 0c fe ff ff       	call   8010273c <skipelem>
80102930:	89 45 08             	mov    %eax,0x8(%ebp)
80102933:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102937:	0f 85 32 ff ff ff    	jne    8010286f <namex+0x81>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010293d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102941:	74 12                	je     80102955 <namex+0x167>
    iput(ip);
80102943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102946:	89 04 24             	mov    %eax,(%esp)
80102949:	e8 eb f4 ff ff       	call   80101e39 <iput>
    return 0;
8010294e:	b8 00 00 00 00       	mov    $0x0,%eax
80102953:	eb 03                	jmp    80102958 <namex+0x16a>
  }
  return ip;
80102955:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102958:	c9                   	leave  
80102959:	c3                   	ret    

8010295a <namei>:

struct inode*
namei(char *path)
{
8010295a:	55                   	push   %ebp
8010295b:	89 e5                	mov    %esp,%ebp
8010295d:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ];
  struct inode* ret;
  
  ret = namex(path, 0, name);
80102960:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102963:	89 44 24 08          	mov    %eax,0x8(%esp)
80102967:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010296e:	00 
8010296f:	8b 45 08             	mov    0x8(%ebp),%eax
80102972:	89 04 24             	mov    %eax,(%esp)
80102975:	e8 74 fe ff ff       	call   801027ee <namex>
8010297a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return ret;
8010297d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102980:	c9                   	leave  
80102981:	c3                   	ret    

80102982 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102982:	55                   	push   %ebp
80102983:	89 e5                	mov    %esp,%ebp
80102985:	83 ec 28             	sub    $0x28,%esp
  struct inode* ret;
  
  ret =  namex(path, 1, name);
80102988:	8b 45 0c             	mov    0xc(%ebp),%eax
8010298b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010298f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102996:	00 
80102997:	8b 45 08             	mov    0x8(%ebp),%eax
8010299a:	89 04 24             	mov    %eax,(%esp)
8010299d:	e8 4c fe ff ff       	call   801027ee <namex>
801029a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  return ret;
801029a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801029a8:	c9                   	leave  
801029a9:	c3                   	ret    

801029aa <get_part>:

// TODO() think this over..
static int cur_part;
int get_part() {
801029aa:	55                   	push   %ebp
801029ab:	89 e5                	mov    %esp,%ebp
  return cur_part;
801029ad:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
}
801029b2:	5d                   	pop    %ebp
801029b3:	c3                   	ret    

801029b4 <set_part>:

void set_part(int p) {
801029b4:	55                   	push   %ebp
801029b5:	89 e5                	mov    %esp,%ebp
  cur_part = p; 
801029b7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ba:	a3 f8 c5 10 80       	mov    %eax,0x8010c5f8
}
801029bf:	5d                   	pop    %ebp
801029c0:	c3                   	ret    

801029c1 <get_boot_block>:
struct partition* get_boot_block() {
801029c1:	55                   	push   %ebp
801029c2:	89 e5                	mov    %esp,%ebp
  return boot_part;
801029c4:	a1 10 3c 11 80       	mov    0x80113c10,%eax
}
801029c9:	5d                   	pop    %ebp
801029ca:	c3                   	ret    

801029cb <find_mp>:

static struct mount_point* find_mp(char* path) {
801029cb:	55                   	push   %ebp
801029cc:	89 e5                	mov    %esp,%ebp
801029ce:	83 ec 28             	sub    $0x28,%esp
  struct mount_point* it = mount_points.pnts;
801029d1:	c7 45 f4 20 22 11 80 	movl   $0x80112220,-0xc(%ebp)
  while(it < MOUNT_POINTS_SIZE +  mount_points.pnts) {
801029d8:	eb 22                	jmp    801029fc <find_mp+0x31>
    if(namecmp(path, it->path) == 0){
801029da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dd:	83 c0 04             	add    $0x4,%eax
801029e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e4:	8b 45 08             	mov    0x8(%ebp),%eax
801029e7:	89 04 24             	mov    %eax,(%esp)
801029ea:	e8 2c fb ff ff       	call   8010251b <namecmp>
801029ef:	85 c0                	test   %eax,%eax
801029f1:	75 05                	jne    801029f8 <find_mp+0x2d>
      return it;
801029f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f6:	eb 12                	jmp    80102a0a <find_mp+0x3f>
    }
    ++it;
801029f8:	83 45 f4 1e          	addl   $0x1e,-0xc(%ebp)
  return boot_part;
}

static struct mount_point* find_mp(char* path) {
  struct mount_point* it = mount_points.pnts;
  while(it < MOUNT_POINTS_SIZE +  mount_points.pnts) {
801029fc:	81 7d f4 90 39 11 80 	cmpl   $0x80113990,-0xc(%ebp)
80102a03:	72 d5                	jb     801029da <find_mp+0xf>
    if(namecmp(path, it->path) == 0){
      return it;
    }
    ++it;
  }
  return 0;
80102a05:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102a0a:	c9                   	leave  
80102a0b:	c3                   	ret    

80102a0c <is_inode_mounted>:

static int is_inode_mounted(struct inode* in,
    int* new_i, struct partition** new_p) {
80102a0c:	55                   	push   %ebp
80102a0d:	89 e5                	mov    %esp,%ebp
80102a0f:	83 ec 10             	sub    $0x10,%esp
  struct mount_point* it = mount_points.pnts;
80102a12:	c7 45 fc 20 22 11 80 	movl   $0x80112220,-0x4(%ebp)
  while(it < MOUNT_POINTS_SIZE +  mount_points.pnts) {
80102a19:	eb 40                	jmp    80102a5b <is_inode_mounted+0x4f>
    if(it->old_i == in->inum && it->old_prt == in->prt){
80102a1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a1e:	8b 40 16             	mov    0x16(%eax),%eax
80102a21:	89 c2                	mov    %eax,%edx
80102a23:	8b 45 08             	mov    0x8(%ebp),%eax
80102a26:	8b 00                	mov    (%eax),%eax
80102a28:	39 c2                	cmp    %eax,%edx
80102a2a:	75 2b                	jne    80102a57 <is_inode_mounted+0x4b>
80102a2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a2f:	8b 50 1a             	mov    0x1a(%eax),%edx
80102a32:	8b 45 08             	mov    0x8(%ebp),%eax
80102a35:	8b 40 0c             	mov    0xc(%eax),%eax
80102a38:	39 c2                	cmp    %eax,%edx
80102a3a:	75 1b                	jne    80102a57 <is_inode_mounted+0x4b>
      *new_i = ROOTINO;
80102a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a3f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      *new_p = it->prt;
80102a45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a48:	8b 50 12             	mov    0x12(%eax),%edx
80102a4b:	8b 45 10             	mov    0x10(%ebp),%eax
80102a4e:	89 10                	mov    %edx,(%eax)
      return 1;
80102a50:	b8 01 00 00 00       	mov    $0x1,%eax
80102a55:	eb 12                	jmp    80102a69 <is_inode_mounted+0x5d>
    }
    ++it;
80102a57:	83 45 fc 1e          	addl   $0x1e,-0x4(%ebp)
}

static int is_inode_mounted(struct inode* in,
    int* new_i, struct partition** new_p) {
  struct mount_point* it = mount_points.pnts;
  while(it < MOUNT_POINTS_SIZE +  mount_points.pnts) {
80102a5b:	81 7d fc 90 39 11 80 	cmpl   $0x80113990,-0x4(%ebp)
80102a62:	72 b7                	jb     80102a1b <is_inode_mounted+0xf>
      *new_p = it->prt;
      return 1;
    }
    ++it;
  }
  return 0;
80102a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102a69:	c9                   	leave  
80102a6a:	c3                   	ret    

80102a6b <mpalloc>:

static struct mount_point* mpalloc(struct mount_point* pnts) {
80102a6b:	55                   	push   %ebp
80102a6c:	89 e5                	mov    %esp,%ebp
80102a6e:	83 ec 1c             	sub    $0x1c,%esp
  struct mount_point* it = pnts;
80102a71:	8b 45 08             	mov    0x8(%ebp),%eax
80102a74:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while (it < pnts + MOUNT_POINTS_SIZE) {
80102a77:	eb 31                	jmp    80102aaa <mpalloc+0x3f>
    if (cas(&it->is_taken, 0, 1)){
80102a79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a7c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80102a83:	00 
80102a84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102a8b:	00 
80102a8c:	89 04 24             	mov    %eax,(%esp)
80102a8f:	e8 78 e8 ff ff       	call   8010130c <cas>
80102a94:	85 c0                	test   %eax,%eax
80102a96:	74 0e                	je     80102aa6 <mpalloc+0x3b>
      it->is_taken = 1;
80102a98:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a9b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      return it;
80102aa1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102aa4:	eb 16                	jmp    80102abc <mpalloc+0x51>
    }
    ++it;
80102aa6:	83 45 fc 1e          	addl   $0x1e,-0x4(%ebp)
  return 0;
}

static struct mount_point* mpalloc(struct mount_point* pnts) {
  struct mount_point* it = pnts;
  while (it < pnts + MOUNT_POINTS_SIZE) {
80102aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80102aad:	05 70 17 00 00       	add    $0x1770,%eax
80102ab2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
80102ab5:	77 c2                	ja     80102a79 <mpalloc+0xe>
      it->is_taken = 1;
      return it;
    }
    ++it;
  }
  return 0;
80102ab7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102abc:	c9                   	leave  
80102abd:	c3                   	ret    

80102abe <is_mounted>:

int is_mounted(char* p) {
80102abe:	55                   	push   %ebp
80102abf:	89 e5                	mov    %esp,%ebp
80102ac1:	83 ec 18             	sub    $0x18,%esp
  return find_mp(p) != 0;
80102ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac7:	89 04 24             	mov    %eax,(%esp)
80102aca:	e8 fc fe ff ff       	call   801029cb <find_mp>
80102acf:	85 c0                	test   %eax,%eax
80102ad1:	0f 95 c0             	setne  %al
80102ad4:	0f b6 c0             	movzbl %al,%eax
}
80102ad7:	c9                   	leave  
80102ad8:	c3                   	ret    

80102ad9 <mount>:
// How should we deal with allready mounted paths?
int mount(char* path, int i) {
80102ad9:	55                   	push   %ebp
80102ada:	89 e5                	mov    %esp,%ebp
80102adc:	56                   	push   %esi
80102add:	53                   	push   %ebx
80102ade:	83 ec 30             	sub    $0x30,%esp
  struct mount_point* pnt;
  struct inode* in = namei(path);
80102ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae4:	89 04 24             	mov    %eax,(%esp)
80102ae7:	e8 6e fe ff ff       	call   8010295a <namei>
80102aec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (in == 0) {
80102aef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102af3:	75 1d                	jne    80102b12 <mount+0x39>
    cprintf("cannot mount non existing path %s \n", path);
80102af5:	8b 45 08             	mov    0x8(%ebp),%eax
80102af8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102afc:	c7 04 24 1c 8f 10 80 	movl   $0x80108f1c,(%esp)
80102b03:	e8 98 d8 ff ff       	call   801003a0 <cprintf>
    return -1;
80102b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b0d:	e9 06 01 00 00       	jmp    80102c18 <mount+0x13f>
  }
  if (is_mounted(path)) {
80102b12:	8b 45 08             	mov    0x8(%ebp),%eax
80102b15:	89 04 24             	mov    %eax,(%esp)
80102b18:	e8 a1 ff ff ff       	call   80102abe <is_mounted>
80102b1d:	85 c0                	test   %eax,%eax
80102b1f:	74 1d                	je     80102b3e <mount+0x65>
    cprintf("trying to mount an allready mounted path - %s \n", path);
80102b21:	8b 45 08             	mov    0x8(%ebp),%eax
80102b24:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b28:	c7 04 24 40 8f 10 80 	movl   $0x80108f40,(%esp)
80102b2f:	e8 6c d8 ff ff       	call   801003a0 <cprintf>
    return -1;
80102b34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b39:	e9 da 00 00 00       	jmp    80102c18 <mount+0x13f>
  }
  pnt = mpalloc(mount_points.pnts); 
80102b3e:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b45:	e8 21 ff ff ff       	call   80102a6b <mpalloc>
80102b4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (pnt == 0) {
80102b4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102b51:	75 16                	jne    80102b69 <mount+0x90>
    cprintf("failed to alloc mp \n");
80102b53:	c7 04 24 70 8f 10 80 	movl   $0x80108f70,(%esp)
80102b5a:	e8 41 d8 ff ff       	call   801003a0 <cprintf>
    return -1;
80102b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b64:	e9 af 00 00 00       	jmp    80102c18 <mount+0x13f>
  }
  memmove(pnt->path, path, min(sizeof(pnt->path), strlen(path)));  
80102b69:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6c:	89 04 24             	mov    %eax,(%esp)
80102b6f:	e8 a8 2f 00 00       	call   80105b1c <strlen>
80102b74:	83 f8 0e             	cmp    $0xe,%eax
80102b77:	77 0d                	ja     80102b86 <mount+0xad>
80102b79:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7c:	89 04 24             	mov    %eax,(%esp)
80102b7f:	e8 98 2f 00 00       	call   80105b1c <strlen>
80102b84:	eb 05                	jmp    80102b8b <mount+0xb2>
80102b86:	b8 0e 00 00 00       	mov    $0xe,%eax
80102b8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102b8e:	83 c2 04             	add    $0x4,%edx
80102b91:	89 44 24 08          	mov    %eax,0x8(%esp)
80102b95:	8b 45 08             	mov    0x8(%ebp),%eax
80102b98:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b9c:	89 14 24             	mov    %edx,(%esp)
80102b9f:	e8 dd 2d 00 00       	call   80105981 <memmove>
  pnt->prt = &partitions[i];
80102ba4:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ba7:	89 d0                	mov    %edx,%eax
80102ba9:	c1 e0 02             	shl    $0x2,%eax
80102bac:	01 d0                	add    %edx,%eax
80102bae:	c1 e0 02             	shl    $0x2,%eax
80102bb1:	8d 90 c0 3b 11 80    	lea    -0x7feec440(%eax),%edx
80102bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bba:	89 50 12             	mov    %edx,0x12(%eax)
  pnt->old_i = in->inum;
80102bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc0:	8b 00                	mov    (%eax),%eax
80102bc2:	89 c2                	mov    %eax,%edx
80102bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bc7:	89 50 16             	mov    %edx,0x16(%eax)
  pnt->old_prt = in->prt;
80102bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bcd:	8b 50 0c             	mov    0xc(%eax),%edx
80102bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bd3:	89 50 1a             	mov    %edx,0x1a(%eax)
  cprintf("created mount point with %d %s old_inum:%d old_prt:%p newprt: %p\n",
80102bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bd9:	8b 58 12             	mov    0x12(%eax),%ebx
80102bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bdf:	8b 48 1a             	mov    0x1a(%eax),%ecx
80102be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102be5:	8b 50 16             	mov    0x16(%eax),%edx
      pnt->is_taken, pnt->path, pnt->old_i, pnt->old_prt, pnt->prt);
80102be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102beb:	8d 70 04             	lea    0x4(%eax),%esi
  }
  memmove(pnt->path, path, min(sizeof(pnt->path), strlen(path)));  
  pnt->prt = &partitions[i];
  pnt->old_i = in->inum;
  pnt->old_prt = in->prt;
  cprintf("created mount point with %d %s old_inum:%d old_prt:%p newprt: %p\n",
80102bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bf1:	8b 00                	mov    (%eax),%eax
80102bf3:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80102bf7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80102bfb:	89 54 24 0c          	mov    %edx,0xc(%esp)
80102bff:	89 74 24 08          	mov    %esi,0x8(%esp)
80102c03:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c07:	c7 04 24 88 8f 10 80 	movl   $0x80108f88,(%esp)
80102c0e:	e8 8d d7 ff ff       	call   801003a0 <cprintf>
      pnt->is_taken, pnt->path, pnt->old_i, pnt->old_prt, pnt->prt);
  return 0;
80102c13:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102c18:	83 c4 30             	add    $0x30,%esp
80102c1b:	5b                   	pop    %ebx
80102c1c:	5e                   	pop    %esi
80102c1d:	5d                   	pop    %ebp
80102c1e:	c3                   	ret    

80102c1f <check_mounted>:

static struct inode* check_mounted(struct inode* in) {
80102c1f:	55                   	push   %ebp
80102c20:	89 e5                	mov    %esp,%ebp
80102c22:	83 ec 28             	sub    $0x28,%esp
  struct partition* mnt_prt;
  int mnt_in;
  struct inode* tmp;
  int flag = is_inode_mounted(in, &mnt_in, &mnt_prt);
80102c25:	8d 45 ec             	lea    -0x14(%ebp),%eax
80102c28:	89 44 24 08          	mov    %eax,0x8(%esp)
80102c2c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80102c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c33:	8b 45 08             	mov    0x8(%ebp),%eax
80102c36:	89 04 24             	mov    %eax,(%esp)
80102c39:	e8 ce fd ff ff       	call   80102a0c <is_inode_mounted>
80102c3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  tmp = 0;
80102c41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (flag) {
80102c48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102c4c:	74 17                	je     80102c65 <check_mounted+0x46>
    tmp = iget(mnt_prt, mnt_in);
80102c4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102c51:	89 c2                	mov    %eax,%edx
80102c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102c56:	89 54 24 04          	mov    %edx,0x4(%esp)
80102c5a:	89 04 24             	mov    %eax,(%esp)
80102c5d:	e8 a6 ee ff ff       	call   80101b08 <iget>
80102c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return tmp;
80102c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c68:	c9                   	leave  
80102c69:	c3                   	ret    

80102c6a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c6a:	55                   	push   %ebp
80102c6b:	89 e5                	mov    %esp,%ebp
80102c6d:	83 ec 14             	sub    $0x14,%esp
80102c70:	8b 45 08             	mov    0x8(%ebp),%eax
80102c73:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c77:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c7b:	89 c2                	mov    %eax,%edx
80102c7d:	ec                   	in     (%dx),%al
80102c7e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c81:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c85:	c9                   	leave  
80102c86:	c3                   	ret    

80102c87 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102c87:	55                   	push   %ebp
80102c88:	89 e5                	mov    %esp,%ebp
80102c8a:	57                   	push   %edi
80102c8b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102c8c:	8b 55 08             	mov    0x8(%ebp),%edx
80102c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102c92:	8b 45 10             	mov    0x10(%ebp),%eax
80102c95:	89 cb                	mov    %ecx,%ebx
80102c97:	89 df                	mov    %ebx,%edi
80102c99:	89 c1                	mov    %eax,%ecx
80102c9b:	fc                   	cld    
80102c9c:	f3 6d                	rep insl (%dx),%es:(%edi)
80102c9e:	89 c8                	mov    %ecx,%eax
80102ca0:	89 fb                	mov    %edi,%ebx
80102ca2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102ca5:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102ca8:	5b                   	pop    %ebx
80102ca9:	5f                   	pop    %edi
80102caa:	5d                   	pop    %ebp
80102cab:	c3                   	ret    

80102cac <outb>:

static inline void
outb(ushort port, uchar data)
{
80102cac:	55                   	push   %ebp
80102cad:	89 e5                	mov    %esp,%ebp
80102caf:	83 ec 08             	sub    $0x8,%esp
80102cb2:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cb8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102cbc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cbf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102cc3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102cc7:	ee                   	out    %al,(%dx)
}
80102cc8:	c9                   	leave  
80102cc9:	c3                   	ret    

80102cca <outsl>:
               "cc", "memory");
  return result;
}
static inline void
outsl(int port, const void *addr, int cnt)
{
80102cca:	55                   	push   %ebp
80102ccb:	89 e5                	mov    %esp,%ebp
80102ccd:	56                   	push   %esi
80102cce:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102ccf:	8b 55 08             	mov    0x8(%ebp),%edx
80102cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102cd5:	8b 45 10             	mov    0x10(%ebp),%eax
80102cd8:	89 cb                	mov    %ecx,%ebx
80102cda:	89 de                	mov    %ebx,%esi
80102cdc:	89 c1                	mov    %eax,%ecx
80102cde:	fc                   	cld    
80102cdf:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102ce1:	89 c8                	mov    %ecx,%eax
80102ce3:	89 f3                	mov    %esi,%ebx
80102ce5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102ce8:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102ceb:	5b                   	pop    %ebx
80102cec:	5e                   	pop    %esi
80102ced:	5d                   	pop    %ebp
80102cee:	c3                   	ret    

80102cef <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102cef:	55                   	push   %ebp
80102cf0:	89 e5                	mov    %esp,%ebp
80102cf2:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102cf5:	90                   	nop
80102cf6:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102cfd:	e8 68 ff ff ff       	call   80102c6a <inb>
80102d02:	0f b6 c0             	movzbl %al,%eax
80102d05:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102d08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d0b:	25 c0 00 00 00       	and    $0xc0,%eax
80102d10:	83 f8 40             	cmp    $0x40,%eax
80102d13:	75 e1                	jne    80102cf6 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102d15:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102d19:	74 11                	je     80102d2c <idewait+0x3d>
80102d1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d1e:	83 e0 21             	and    $0x21,%eax
80102d21:	85 c0                	test   %eax,%eax
80102d23:	74 07                	je     80102d2c <idewait+0x3d>
    return -1;
80102d25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d2a:	eb 05                	jmp    80102d31 <idewait+0x42>
  return 0;
80102d2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102d31:	c9                   	leave  
80102d32:	c3                   	ret    

80102d33 <ideinit>:

void
ideinit(void)
{
80102d33:	55                   	push   %ebp
80102d34:	89 e5                	mov    %esp,%ebp
80102d36:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102d39:	c7 44 24 04 ca 8f 10 	movl   $0x80108fca,0x4(%esp)
80102d40:	80 
80102d41:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102d48:	e8 f0 28 00 00       	call   8010563d <initlock>
  picenable(IRQ_IDE);
80102d4d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102d54:	e8 bb 18 00 00       	call   80104614 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102d59:	a1 80 55 11 80       	mov    0x80115580,%eax
80102d5e:	83 e8 01             	sub    $0x1,%eax
80102d61:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d65:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102d6c:	e8 59 04 00 00       	call   801031ca <ioapicenable>
  idewait(0);
80102d71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102d78:	e8 72 ff ff ff       	call   80102cef <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102d7d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102d84:	00 
80102d85:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102d8c:	e8 1b ff ff ff       	call   80102cac <outb>
  for(i=0; i<1000; i++){
80102d91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102d98:	eb 20                	jmp    80102dba <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102d9a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102da1:	e8 c4 fe ff ff       	call   80102c6a <inb>
80102da6:	84 c0                	test   %al,%al
80102da8:	74 0c                	je     80102db6 <ideinit+0x83>
      havedisk1 = 1;
80102daa:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102db1:	00 00 00 
      break;
80102db4:	eb 0d                	jmp    80102dc3 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102db6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102dba:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102dc1:	7e d7                	jle    80102d9a <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102dc3:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102dca:	00 
80102dcb:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102dd2:	e8 d5 fe ff ff       	call   80102cac <outb>
}
80102dd7:	c9                   	leave  
80102dd8:	c3                   	ret    

80102dd9 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102dd9:	55                   	push   %ebp
80102dda:	89 e5                	mov    %esp,%ebp
80102ddc:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102ddf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102de3:	75 0c                	jne    80102df1 <idestart+0x18>
    panic("idestart");
80102de5:	c7 04 24 ce 8f 10 80 	movl   $0x80108fce,(%esp)
80102dec:	e8 49 d7 ff ff       	call   8010053a <panic>
  if(b->blockno >= FSSIZE + 375) {
80102df1:	8b 45 08             	mov    0x8(%ebp),%eax
80102df4:	8b 40 08             	mov    0x8(%eax),%eax
80102df7:	3d 5e 05 00 00       	cmp    $0x55e,%eax
80102dfc:	76 22                	jbe    80102e20 <idestart+0x47>
    cprintf("the bad block is %d \n", b->blockno);
80102dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80102e01:	8b 40 08             	mov    0x8(%eax),%eax
80102e04:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e08:	c7 04 24 d7 8f 10 80 	movl   $0x80108fd7,(%esp)
80102e0f:	e8 8c d5 ff ff       	call   801003a0 <cprintf>
    panic("incorrect blockno");
80102e14:	c7 04 24 ed 8f 10 80 	movl   $0x80108fed,(%esp)
80102e1b:	e8 1a d7 ff ff       	call   8010053a <panic>
  }
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102e20:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102e27:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2a:	8b 50 08             	mov    0x8(%eax),%edx
80102e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e30:	0f af c2             	imul   %edx,%eax
80102e33:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102e36:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102e3a:	7e 0c                	jle    80102e48 <idestart+0x6f>
80102e3c:	c7 04 24 ce 8f 10 80 	movl   $0x80108fce,(%esp)
80102e43:	e8 f2 d6 ff ff       	call   8010053a <panic>
  
  idewait(0);
80102e48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102e4f:	e8 9b fe ff ff       	call   80102cef <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102e54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e5b:	00 
80102e5c:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102e63:	e8 44 fe ff ff       	call   80102cac <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e6b:	0f b6 c0             	movzbl %al,%eax
80102e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e72:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102e79:	e8 2e fe ff ff       	call   80102cac <outb>
  outb(0x1f3, sector & 0xff);
80102e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e81:	0f b6 c0             	movzbl %al,%eax
80102e84:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e88:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102e8f:	e8 18 fe ff ff       	call   80102cac <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e97:	c1 f8 08             	sar    $0x8,%eax
80102e9a:	0f b6 c0             	movzbl %al,%eax
80102e9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ea1:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102ea8:	e8 ff fd ff ff       	call   80102cac <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eb0:	c1 f8 10             	sar    $0x10,%eax
80102eb3:	0f b6 c0             	movzbl %al,%eax
80102eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eba:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102ec1:	e8 e6 fd ff ff       	call   80102cac <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ec9:	8b 40 04             	mov    0x4(%eax),%eax
80102ecc:	83 e0 01             	and    $0x1,%eax
80102ecf:	c1 e0 04             	shl    $0x4,%eax
80102ed2:	89 c2                	mov    %eax,%edx
80102ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ed7:	c1 f8 18             	sar    $0x18,%eax
80102eda:	83 e0 0f             	and    $0xf,%eax
80102edd:	09 d0                	or     %edx,%eax
80102edf:	83 c8 e0             	or     $0xffffffe0,%eax
80102ee2:	0f b6 c0             	movzbl %al,%eax
80102ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ee9:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102ef0:	e8 b7 fd ff ff       	call   80102cac <outb>
  if(b->flags & B_DIRTY){
80102ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ef8:	8b 00                	mov    (%eax),%eax
80102efa:	83 e0 04             	and    $0x4,%eax
80102efd:	85 c0                	test   %eax,%eax
80102eff:	74 34                	je     80102f35 <idestart+0x15c>
    outb(0x1f7, IDE_CMD_WRITE);
80102f01:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102f08:	00 
80102f09:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102f10:	e8 97 fd ff ff       	call   80102cac <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102f15:	8b 45 08             	mov    0x8(%ebp),%eax
80102f18:	83 c0 18             	add    $0x18,%eax
80102f1b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102f22:	00 
80102f23:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f27:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102f2e:	e8 97 fd ff ff       	call   80102cca <outsl>
80102f33:	eb 14                	jmp    80102f49 <idestart+0x170>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102f35:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102f3c:	00 
80102f3d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102f44:	e8 63 fd ff ff       	call   80102cac <outb>
  }
}
80102f49:	c9                   	leave  
80102f4a:	c3                   	ret    

80102f4b <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102f4b:	55                   	push   %ebp
80102f4c:	89 e5                	mov    %esp,%ebp
80102f4e:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102f51:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102f58:	e8 01 27 00 00       	call   8010565e <acquire>
  if((b = idequeue) == 0){
80102f5d:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102f62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102f65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f69:	75 11                	jne    80102f7c <ideintr+0x31>
    release(&idelock);
80102f6b:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102f72:	e8 49 27 00 00       	call   801056c0 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102f77:	e9 90 00 00 00       	jmp    8010300c <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f7f:	8b 40 14             	mov    0x14(%eax),%eax
80102f82:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f8a:	8b 00                	mov    (%eax),%eax
80102f8c:	83 e0 04             	and    $0x4,%eax
80102f8f:	85 c0                	test   %eax,%eax
80102f91:	75 2e                	jne    80102fc1 <ideintr+0x76>
80102f93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102f9a:	e8 50 fd ff ff       	call   80102cef <idewait>
80102f9f:	85 c0                	test   %eax,%eax
80102fa1:	78 1e                	js     80102fc1 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fa6:	83 c0 18             	add    $0x18,%eax
80102fa9:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102fb0:	00 
80102fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fb5:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102fbc:	e8 c6 fc ff ff       	call   80102c87 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fc4:	8b 00                	mov    (%eax),%eax
80102fc6:	83 c8 02             	or     $0x2,%eax
80102fc9:	89 c2                	mov    %eax,%edx
80102fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fce:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd3:	8b 00                	mov    (%eax),%eax
80102fd5:	83 e0 fb             	and    $0xfffffffb,%eax
80102fd8:	89 c2                	mov    %eax,%edx
80102fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdd:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fe2:	89 04 24             	mov    %eax,(%esp)
80102fe5:	e8 83 24 00 00       	call   8010546d <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0) {
80102fea:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102fef:	85 c0                	test   %eax,%eax
80102ff1:	74 0d                	je     80103000 <ideintr+0xb5>
    idestart(idequeue);
80102ff3:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102ff8:	89 04 24             	mov    %eax,(%esp)
80102ffb:	e8 d9 fd ff ff       	call   80102dd9 <idestart>
  }

  release(&idelock);
80103000:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80103007:	e8 b4 26 00 00       	call   801056c0 <release>
}
8010300c:	c9                   	leave  
8010300d:	c3                   	ret    

8010300e <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010300e:	55                   	push   %ebp
8010300f:	89 e5                	mov    %esp,%ebp
80103011:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80103014:	8b 45 08             	mov    0x8(%ebp),%eax
80103017:	8b 00                	mov    (%eax),%eax
80103019:	83 e0 01             	and    $0x1,%eax
8010301c:	85 c0                	test   %eax,%eax
8010301e:	75 0c                	jne    8010302c <iderw+0x1e>
    panic("iderw: buf not busy");
80103020:	c7 04 24 ff 8f 10 80 	movl   $0x80108fff,(%esp)
80103027:	e8 0e d5 ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010302c:	8b 45 08             	mov    0x8(%ebp),%eax
8010302f:	8b 00                	mov    (%eax),%eax
80103031:	83 e0 06             	and    $0x6,%eax
80103034:	83 f8 02             	cmp    $0x2,%eax
80103037:	75 0c                	jne    80103045 <iderw+0x37>
    panic("iderw: nothing to do");
80103039:	c7 04 24 13 90 10 80 	movl   $0x80109013,(%esp)
80103040:	e8 f5 d4 ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
80103045:	8b 45 08             	mov    0x8(%ebp),%eax
80103048:	8b 40 04             	mov    0x4(%eax),%eax
8010304b:	85 c0                	test   %eax,%eax
8010304d:	74 15                	je     80103064 <iderw+0x56>
8010304f:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80103054:	85 c0                	test   %eax,%eax
80103056:	75 0c                	jne    80103064 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80103058:	c7 04 24 28 90 10 80 	movl   $0x80109028,(%esp)
8010305f:	e8 d6 d4 ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
80103064:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
8010306b:	e8 ee 25 00 00       	call   8010565e <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80103070:	8b 45 08             	mov    0x8(%ebp),%eax
80103073:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010307a:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80103081:	eb 0b                	jmp    8010308e <iderw+0x80>
80103083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103086:	8b 00                	mov    (%eax),%eax
80103088:	83 c0 14             	add    $0x14,%eax
8010308b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010308e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103091:	8b 00                	mov    (%eax),%eax
80103093:	85 c0                	test   %eax,%eax
80103095:	75 ec                	jne    80103083 <iderw+0x75>
    ;
  *pp = b;
80103097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010309a:	8b 55 08             	mov    0x8(%ebp),%edx
8010309d:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b) {
8010309f:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030a4:	3b 45 08             	cmp    0x8(%ebp),%eax
801030a7:	75 0d                	jne    801030b6 <iderw+0xa8>
    idestart(b);
801030a9:	8b 45 08             	mov    0x8(%ebp),%eax
801030ac:	89 04 24             	mov    %eax,(%esp)
801030af:	e8 25 fd ff ff       	call   80102dd9 <idestart>
  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801030b4:	eb 15                	jmp    801030cb <iderw+0xbd>
801030b6:	eb 13                	jmp    801030cb <iderw+0xbd>
    sleep(b, &idelock);
801030b8:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
801030bf:	80 
801030c0:	8b 45 08             	mov    0x8(%ebp),%eax
801030c3:	89 04 24             	mov    %eax,(%esp)
801030c6:	e8 c9 22 00 00       	call   80105394 <sleep>
  if(idequeue == b) {
    idestart(b);
  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801030cb:	8b 45 08             	mov    0x8(%ebp),%eax
801030ce:	8b 00                	mov    (%eax),%eax
801030d0:	83 e0 06             	and    $0x6,%eax
801030d3:	83 f8 02             	cmp    $0x2,%eax
801030d6:	75 e0                	jne    801030b8 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
801030d8:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801030df:	e8 dc 25 00 00       	call   801056c0 <release>
}
801030e4:	c9                   	leave  
801030e5:	c3                   	ret    

801030e6 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801030e6:	55                   	push   %ebp
801030e7:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801030e9:	a1 4c 4e 11 80       	mov    0x80114e4c,%eax
801030ee:	8b 55 08             	mov    0x8(%ebp),%edx
801030f1:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801030f3:	a1 4c 4e 11 80       	mov    0x80114e4c,%eax
801030f8:	8b 40 10             	mov    0x10(%eax),%eax
}
801030fb:	5d                   	pop    %ebp
801030fc:	c3                   	ret    

801030fd <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801030fd:	55                   	push   %ebp
801030fe:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103100:	a1 4c 4e 11 80       	mov    0x80114e4c,%eax
80103105:	8b 55 08             	mov    0x8(%ebp),%edx
80103108:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010310a:	a1 4c 4e 11 80       	mov    0x80114e4c,%eax
8010310f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103112:	89 50 10             	mov    %edx,0x10(%eax)
}
80103115:	5d                   	pop    %ebp
80103116:	c3                   	ret    

80103117 <ioapicinit>:

void
ioapicinit(void)
{
80103117:	55                   	push   %ebp
80103118:	89 e5                	mov    %esp,%ebp
8010311a:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
8010311d:	a1 84 4f 11 80       	mov    0x80114f84,%eax
80103122:	85 c0                	test   %eax,%eax
80103124:	75 05                	jne    8010312b <ioapicinit+0x14>
    return;
80103126:	e9 9d 00 00 00       	jmp    801031c8 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
8010312b:	c7 05 4c 4e 11 80 00 	movl   $0xfec00000,0x80114e4c
80103132:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80103135:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010313c:	e8 a5 ff ff ff       	call   801030e6 <ioapicread>
80103141:	c1 e8 10             	shr    $0x10,%eax
80103144:	25 ff 00 00 00       	and    $0xff,%eax
80103149:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010314c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103153:	e8 8e ff ff ff       	call   801030e6 <ioapicread>
80103158:	c1 e8 18             	shr    $0x18,%eax
8010315b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010315e:	0f b6 05 80 4f 11 80 	movzbl 0x80114f80,%eax
80103165:	0f b6 c0             	movzbl %al,%eax
80103168:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010316b:	74 0c                	je     80103179 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010316d:	c7 04 24 48 90 10 80 	movl   $0x80109048,(%esp)
80103174:	e8 27 d2 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103179:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103180:	eb 3e                	jmp    801031c0 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80103182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103185:	83 c0 20             	add    $0x20,%eax
80103188:	0d 00 00 01 00       	or     $0x10000,%eax
8010318d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103190:	83 c2 08             	add    $0x8,%edx
80103193:	01 d2                	add    %edx,%edx
80103195:	89 44 24 04          	mov    %eax,0x4(%esp)
80103199:	89 14 24             	mov    %edx,(%esp)
8010319c:	e8 5c ff ff ff       	call   801030fd <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801031a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a4:	83 c0 08             	add    $0x8,%eax
801031a7:	01 c0                	add    %eax,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031b3:	00 
801031b4:	89 04 24             	mov    %eax,(%esp)
801031b7:	e8 41 ff ff ff       	call   801030fd <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801031bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801031c6:	7e ba                	jle    80103182 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801031c8:	c9                   	leave  
801031c9:	c3                   	ret    

801031ca <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801031ca:	55                   	push   %ebp
801031cb:	89 e5                	mov    %esp,%ebp
801031cd:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
801031d0:	a1 84 4f 11 80       	mov    0x80114f84,%eax
801031d5:	85 c0                	test   %eax,%eax
801031d7:	75 02                	jne    801031db <ioapicenable+0x11>
    return;
801031d9:	eb 37                	jmp    80103212 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801031db:	8b 45 08             	mov    0x8(%ebp),%eax
801031de:	83 c0 20             	add    $0x20,%eax
801031e1:	8b 55 08             	mov    0x8(%ebp),%edx
801031e4:	83 c2 08             	add    $0x8,%edx
801031e7:	01 d2                	add    %edx,%edx
801031e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801031ed:	89 14 24             	mov    %edx,(%esp)
801031f0:	e8 08 ff ff ff       	call   801030fd <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801031f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801031f8:	c1 e0 18             	shl    $0x18,%eax
801031fb:	8b 55 08             	mov    0x8(%ebp),%edx
801031fe:	83 c2 08             	add    $0x8,%edx
80103201:	01 d2                	add    %edx,%edx
80103203:	83 c2 01             	add    $0x1,%edx
80103206:	89 44 24 04          	mov    %eax,0x4(%esp)
8010320a:	89 14 24             	mov    %edx,(%esp)
8010320d:	e8 eb fe ff ff       	call   801030fd <ioapicwrite>
}
80103212:	c9                   	leave  
80103213:	c3                   	ret    

80103214 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80103214:	55                   	push   %ebp
80103215:	89 e5                	mov    %esp,%ebp
80103217:	8b 45 08             	mov    0x8(%ebp),%eax
8010321a:	05 00 00 00 80       	add    $0x80000000,%eax
8010321f:	5d                   	pop    %ebp
80103220:	c3                   	ret    

80103221 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80103221:	55                   	push   %ebp
80103222:	89 e5                	mov    %esp,%ebp
80103224:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80103227:	c7 44 24 04 7a 90 10 	movl   $0x8010907a,0x4(%esp)
8010322e:	80 
8010322f:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80103236:	e8 02 24 00 00       	call   8010563d <initlock>
  kmem.use_lock = 0;
8010323b:	c7 05 94 4e 11 80 00 	movl   $0x0,0x80114e94
80103242:	00 00 00 
  freerange(vstart, vend);
80103245:	8b 45 0c             	mov    0xc(%ebp),%eax
80103248:	89 44 24 04          	mov    %eax,0x4(%esp)
8010324c:	8b 45 08             	mov    0x8(%ebp),%eax
8010324f:	89 04 24             	mov    %eax,(%esp)
80103252:	e8 26 00 00 00       	call   8010327d <freerange>
}
80103257:	c9                   	leave  
80103258:	c3                   	ret    

80103259 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80103259:	55                   	push   %ebp
8010325a:	89 e5                	mov    %esp,%ebp
8010325c:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
8010325f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103262:	89 44 24 04          	mov    %eax,0x4(%esp)
80103266:	8b 45 08             	mov    0x8(%ebp),%eax
80103269:	89 04 24             	mov    %eax,(%esp)
8010326c:	e8 0c 00 00 00       	call   8010327d <freerange>
  kmem.use_lock = 1;
80103271:	c7 05 94 4e 11 80 01 	movl   $0x1,0x80114e94
80103278:	00 00 00 
}
8010327b:	c9                   	leave  
8010327c:	c3                   	ret    

8010327d <freerange>:

void
freerange(void *vstart, void *vend)
{
8010327d:	55                   	push   %ebp
8010327e:	89 e5                	mov    %esp,%ebp
80103280:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80103283:	8b 45 08             	mov    0x8(%ebp),%eax
80103286:	05 ff 0f 00 00       	add    $0xfff,%eax
8010328b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103290:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103293:	eb 12                	jmp    801032a7 <freerange+0x2a>
    kfree(p);
80103295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103298:	89 04 24             	mov    %eax,(%esp)
8010329b:	e8 16 00 00 00       	call   801032b6 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801032a0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801032a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032aa:	05 00 10 00 00       	add    $0x1000,%eax
801032af:	3b 45 0c             	cmp    0xc(%ebp),%eax
801032b2:	76 e1                	jbe    80103295 <freerange+0x18>
    kfree(p);
}
801032b4:	c9                   	leave  
801032b5:	c3                   	ret    

801032b6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801032b6:	55                   	push   %ebp
801032b7:	89 e5                	mov    %esp,%ebp
801032b9:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801032bc:	8b 45 08             	mov    0x8(%ebp),%eax
801032bf:	25 ff 0f 00 00       	and    $0xfff,%eax
801032c4:	85 c0                	test   %eax,%eax
801032c6:	75 1b                	jne    801032e3 <kfree+0x2d>
801032c8:	81 7d 08 7c 7d 11 80 	cmpl   $0x80117d7c,0x8(%ebp)
801032cf:	72 12                	jb     801032e3 <kfree+0x2d>
801032d1:	8b 45 08             	mov    0x8(%ebp),%eax
801032d4:	89 04 24             	mov    %eax,(%esp)
801032d7:	e8 38 ff ff ff       	call   80103214 <v2p>
801032dc:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801032e1:	76 0c                	jbe    801032ef <kfree+0x39>
    panic("kfree");
801032e3:	c7 04 24 7f 90 10 80 	movl   $0x8010907f,(%esp)
801032ea:	e8 4b d2 ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801032ef:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801032f6:	00 
801032f7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801032fe:	00 
801032ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103302:	89 04 24             	mov    %eax,(%esp)
80103305:	e8 a8 25 00 00       	call   801058b2 <memset>

  if(kmem.use_lock)
8010330a:	a1 94 4e 11 80       	mov    0x80114e94,%eax
8010330f:	85 c0                	test   %eax,%eax
80103311:	74 0c                	je     8010331f <kfree+0x69>
    acquire(&kmem.lock);
80103313:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
8010331a:	e8 3f 23 00 00       	call   8010565e <acquire>
  r = (struct run*)v;
8010331f:	8b 45 08             	mov    0x8(%ebp),%eax
80103322:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80103325:	8b 15 98 4e 11 80    	mov    0x80114e98,%edx
8010332b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010332e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80103330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103333:	a3 98 4e 11 80       	mov    %eax,0x80114e98
  if(kmem.use_lock)
80103338:	a1 94 4e 11 80       	mov    0x80114e94,%eax
8010333d:	85 c0                	test   %eax,%eax
8010333f:	74 0c                	je     8010334d <kfree+0x97>
    release(&kmem.lock);
80103341:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80103348:	e8 73 23 00 00       	call   801056c0 <release>
}
8010334d:	c9                   	leave  
8010334e:	c3                   	ret    

8010334f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010334f:	55                   	push   %ebp
80103350:	89 e5                	mov    %esp,%ebp
80103352:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80103355:	a1 94 4e 11 80       	mov    0x80114e94,%eax
8010335a:	85 c0                	test   %eax,%eax
8010335c:	74 0c                	je     8010336a <kalloc+0x1b>
    acquire(&kmem.lock);
8010335e:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80103365:	e8 f4 22 00 00       	call   8010565e <acquire>
  r = kmem.freelist;
8010336a:	a1 98 4e 11 80       	mov    0x80114e98,%eax
8010336f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103372:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103376:	74 0a                	je     80103382 <kalloc+0x33>
    kmem.freelist = r->next;
80103378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010337b:	8b 00                	mov    (%eax),%eax
8010337d:	a3 98 4e 11 80       	mov    %eax,0x80114e98
  if(kmem.use_lock)
80103382:	a1 94 4e 11 80       	mov    0x80114e94,%eax
80103387:	85 c0                	test   %eax,%eax
80103389:	74 0c                	je     80103397 <kalloc+0x48>
    release(&kmem.lock);
8010338b:	c7 04 24 60 4e 11 80 	movl   $0x80114e60,(%esp)
80103392:	e8 29 23 00 00       	call   801056c0 <release>
  return (char*)r;
80103397:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010339a:	c9                   	leave  
8010339b:	c3                   	ret    

8010339c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010339c:	55                   	push   %ebp
8010339d:	89 e5                	mov    %esp,%ebp
8010339f:	83 ec 14             	sub    $0x14,%esp
801033a2:	8b 45 08             	mov    0x8(%ebp),%eax
801033a5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801033a9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801033ad:	89 c2                	mov    %eax,%edx
801033af:	ec                   	in     (%dx),%al
801033b0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801033b3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801033b7:	c9                   	leave  
801033b8:	c3                   	ret    

801033b9 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801033b9:	55                   	push   %ebp
801033ba:	89 e5                	mov    %esp,%ebp
801033bc:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801033bf:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801033c6:	e8 d1 ff ff ff       	call   8010339c <inb>
801033cb:	0f b6 c0             	movzbl %al,%eax
801033ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801033d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033d4:	83 e0 01             	and    $0x1,%eax
801033d7:	85 c0                	test   %eax,%eax
801033d9:	75 0a                	jne    801033e5 <kbdgetc+0x2c>
    return -1;
801033db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033e0:	e9 25 01 00 00       	jmp    8010350a <kbdgetc+0x151>
  data = inb(KBDATAP);
801033e5:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
801033ec:	e8 ab ff ff ff       	call   8010339c <inb>
801033f1:	0f b6 c0             	movzbl %al,%eax
801033f4:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801033f7:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801033fe:	75 17                	jne    80103417 <kbdgetc+0x5e>
    shift |= E0ESC;
80103400:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103405:	83 c8 40             	or     $0x40,%eax
80103408:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
8010340d:	b8 00 00 00 00       	mov    $0x0,%eax
80103412:	e9 f3 00 00 00       	jmp    8010350a <kbdgetc+0x151>
  } else if(data & 0x80){
80103417:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010341a:	25 80 00 00 00       	and    $0x80,%eax
8010341f:	85 c0                	test   %eax,%eax
80103421:	74 45                	je     80103468 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103423:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103428:	83 e0 40             	and    $0x40,%eax
8010342b:	85 c0                	test   %eax,%eax
8010342d:	75 08                	jne    80103437 <kbdgetc+0x7e>
8010342f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103432:	83 e0 7f             	and    $0x7f,%eax
80103435:	eb 03                	jmp    8010343a <kbdgetc+0x81>
80103437:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010343a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010343d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103440:	05 20 a0 10 80       	add    $0x8010a020,%eax
80103445:	0f b6 00             	movzbl (%eax),%eax
80103448:	83 c8 40             	or     $0x40,%eax
8010344b:	0f b6 c0             	movzbl %al,%eax
8010344e:	f7 d0                	not    %eax
80103450:	89 c2                	mov    %eax,%edx
80103452:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103457:	21 d0                	and    %edx,%eax
80103459:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
8010345e:	b8 00 00 00 00       	mov    $0x0,%eax
80103463:	e9 a2 00 00 00       	jmp    8010350a <kbdgetc+0x151>
  } else if(shift & E0ESC){
80103468:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010346d:	83 e0 40             	and    $0x40,%eax
80103470:	85 c0                	test   %eax,%eax
80103472:	74 14                	je     80103488 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103474:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010347b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103480:	83 e0 bf             	and    $0xffffffbf,%eax
80103483:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80103488:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010348b:	05 20 a0 10 80       	add    $0x8010a020,%eax
80103490:	0f b6 00             	movzbl (%eax),%eax
80103493:	0f b6 d0             	movzbl %al,%edx
80103496:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010349b:	09 d0                	or     %edx,%eax
8010349d:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
801034a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034a5:	05 20 a1 10 80       	add    $0x8010a120,%eax
801034aa:	0f b6 00             	movzbl (%eax),%eax
801034ad:	0f b6 d0             	movzbl %al,%edx
801034b0:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801034b5:	31 d0                	xor    %edx,%eax
801034b7:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
801034bc:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801034c1:	83 e0 03             	and    $0x3,%eax
801034c4:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
801034cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034ce:	01 d0                	add    %edx,%eax
801034d0:	0f b6 00             	movzbl (%eax),%eax
801034d3:	0f b6 c0             	movzbl %al,%eax
801034d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801034d9:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801034de:	83 e0 08             	and    $0x8,%eax
801034e1:	85 c0                	test   %eax,%eax
801034e3:	74 22                	je     80103507 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
801034e5:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801034e9:	76 0c                	jbe    801034f7 <kbdgetc+0x13e>
801034eb:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801034ef:	77 06                	ja     801034f7 <kbdgetc+0x13e>
      c += 'A' - 'a';
801034f1:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801034f5:	eb 10                	jmp    80103507 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
801034f7:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801034fb:	76 0a                	jbe    80103507 <kbdgetc+0x14e>
801034fd:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103501:	77 04                	ja     80103507 <kbdgetc+0x14e>
      c += 'a' - 'A';
80103503:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103507:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010350a:	c9                   	leave  
8010350b:	c3                   	ret    

8010350c <kbdintr>:

void
kbdintr(void)
{
8010350c:	55                   	push   %ebp
8010350d:	89 e5                	mov    %esp,%ebp
8010350f:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103512:	c7 04 24 b9 33 10 80 	movl   $0x801033b9,(%esp)
80103519:	e8 aa d2 ff ff       	call   801007c8 <consoleintr>
}
8010351e:	c9                   	leave  
8010351f:	c3                   	ret    

80103520 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	83 ec 14             	sub    $0x14,%esp
80103526:	8b 45 08             	mov    0x8(%ebp),%eax
80103529:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010352d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103531:	89 c2                	mov    %eax,%edx
80103533:	ec                   	in     (%dx),%al
80103534:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103537:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010353b:	c9                   	leave  
8010353c:	c3                   	ret    

8010353d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010353d:	55                   	push   %ebp
8010353e:	89 e5                	mov    %esp,%ebp
80103540:	83 ec 08             	sub    $0x8,%esp
80103543:	8b 55 08             	mov    0x8(%ebp),%edx
80103546:	8b 45 0c             	mov    0xc(%ebp),%eax
80103549:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010354d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103550:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103554:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103558:	ee                   	out    %al,(%dx)
}
80103559:	c9                   	leave  
8010355a:	c3                   	ret    

8010355b <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010355b:	55                   	push   %ebp
8010355c:	89 e5                	mov    %esp,%ebp
8010355e:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103561:	9c                   	pushf  
80103562:	58                   	pop    %eax
80103563:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103566:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103569:	c9                   	leave  
8010356a:	c3                   	ret    

8010356b <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010356b:	55                   	push   %ebp
8010356c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010356e:	a1 9c 4e 11 80       	mov    0x80114e9c,%eax
80103573:	8b 55 08             	mov    0x8(%ebp),%edx
80103576:	c1 e2 02             	shl    $0x2,%edx
80103579:	01 c2                	add    %eax,%edx
8010357b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103580:	a1 9c 4e 11 80       	mov    0x80114e9c,%eax
80103585:	83 c0 20             	add    $0x20,%eax
80103588:	8b 00                	mov    (%eax),%eax
}
8010358a:	5d                   	pop    %ebp
8010358b:	c3                   	ret    

8010358c <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
8010358c:	55                   	push   %ebp
8010358d:	89 e5                	mov    %esp,%ebp
8010358f:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103592:	a1 9c 4e 11 80       	mov    0x80114e9c,%eax
80103597:	85 c0                	test   %eax,%eax
80103599:	75 05                	jne    801035a0 <lapicinit+0x14>
    return;
8010359b:	e9 43 01 00 00       	jmp    801036e3 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801035a0:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
801035a7:	00 
801035a8:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801035af:	e8 b7 ff ff ff       	call   8010356b <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801035b4:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801035bb:	00 
801035bc:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
801035c3:	e8 a3 ff ff ff       	call   8010356b <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801035c8:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801035cf:	00 
801035d0:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801035d7:	e8 8f ff ff ff       	call   8010356b <lapicw>
  lapicw(TICR, 10000000); 
801035dc:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801035e3:	00 
801035e4:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801035eb:	e8 7b ff ff ff       	call   8010356b <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801035f0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801035f7:	00 
801035f8:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801035ff:	e8 67 ff ff ff       	call   8010356b <lapicw>
  lapicw(LINT1, MASKED);
80103604:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010360b:	00 
8010360c:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103613:	e8 53 ff ff ff       	call   8010356b <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103618:	a1 9c 4e 11 80       	mov    0x80114e9c,%eax
8010361d:	83 c0 30             	add    $0x30,%eax
80103620:	8b 00                	mov    (%eax),%eax
80103622:	c1 e8 10             	shr    $0x10,%eax
80103625:	0f b6 c0             	movzbl %al,%eax
80103628:	83 f8 03             	cmp    $0x3,%eax
8010362b:	76 14                	jbe    80103641 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
8010362d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103634:	00 
80103635:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
8010363c:	e8 2a ff ff ff       	call   8010356b <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103641:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103648:	00 
80103649:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103650:	e8 16 ff ff ff       	call   8010356b <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103655:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010365c:	00 
8010365d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103664:	e8 02 ff ff ff       	call   8010356b <lapicw>
  lapicw(ESR, 0);
80103669:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103670:	00 
80103671:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103678:	e8 ee fe ff ff       	call   8010356b <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010367d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103684:	00 
80103685:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010368c:	e8 da fe ff ff       	call   8010356b <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103691:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103698:	00 
80103699:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801036a0:	e8 c6 fe ff ff       	call   8010356b <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801036a5:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801036ac:	00 
801036ad:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801036b4:	e8 b2 fe ff ff       	call   8010356b <lapicw>
  while(lapic[ICRLO] & DELIVS)
801036b9:	90                   	nop
801036ba:	a1 9c 4e 11 80       	mov    0x80114e9c,%eax
801036bf:	05 00 03 00 00       	add    $0x300,%eax
801036c4:	8b 00                	mov    (%eax),%eax
801036c6:	25 00 10 00 00       	and    $0x1000,%eax
801036cb:	85 c0                	test   %eax,%eax
801036cd:	75 eb                	jne    801036ba <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801036cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801036d6:	00 
801036d7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801036de:	e8 88 fe ff ff       	call   8010356b <lapicw>
}
801036e3:	c9                   	leave  
801036e4:	c3                   	ret    

801036e5 <cpunum>:

int
cpunum(void)
{
801036e5:	55                   	push   %ebp
801036e6:	89 e5                	mov    %esp,%ebp
801036e8:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801036eb:	e8 6b fe ff ff       	call   8010355b <readeflags>
801036f0:	25 00 02 00 00       	and    $0x200,%eax
801036f5:	85 c0                	test   %eax,%eax
801036f7:	74 25                	je     8010371e <cpunum+0x39>
    static int n;
    if(n++ == 0)
801036f9:	a1 40 c6 10 80       	mov    0x8010c640,%eax
801036fe:	8d 50 01             	lea    0x1(%eax),%edx
80103701:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
80103707:	85 c0                	test   %eax,%eax
80103709:	75 13                	jne    8010371e <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
8010370b:	8b 45 04             	mov    0x4(%ebp),%eax
8010370e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103712:	c7 04 24 88 90 10 80 	movl   $0x80109088,(%esp)
80103719:	e8 82 cc ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
8010371e:	a1 9c 4e 11 80       	mov    0x80114e9c,%eax
80103723:	85 c0                	test   %eax,%eax
80103725:	74 0f                	je     80103736 <cpunum+0x51>
    return lapic[ID]>>24;
80103727:	a1 9c 4e 11 80       	mov    0x80114e9c,%eax
8010372c:	83 c0 20             	add    $0x20,%eax
8010372f:	8b 00                	mov    (%eax),%eax
80103731:	c1 e8 18             	shr    $0x18,%eax
80103734:	eb 05                	jmp    8010373b <cpunum+0x56>
  return 0;
80103736:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010373b:	c9                   	leave  
8010373c:	c3                   	ret    

8010373d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010373d:	55                   	push   %ebp
8010373e:	89 e5                	mov    %esp,%ebp
80103740:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103743:	a1 9c 4e 11 80       	mov    0x80114e9c,%eax
80103748:	85 c0                	test   %eax,%eax
8010374a:	74 14                	je     80103760 <lapiceoi+0x23>
    lapicw(EOI, 0);
8010374c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103753:	00 
80103754:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010375b:	e8 0b fe ff ff       	call   8010356b <lapicw>
}
80103760:	c9                   	leave  
80103761:	c3                   	ret    

80103762 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103762:	55                   	push   %ebp
80103763:	89 e5                	mov    %esp,%ebp
}
80103765:	5d                   	pop    %ebp
80103766:	c3                   	ret    

80103767 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103767:	55                   	push   %ebp
80103768:	89 e5                	mov    %esp,%ebp
8010376a:	83 ec 1c             	sub    $0x1c,%esp
8010376d:	8b 45 08             	mov    0x8(%ebp),%eax
80103770:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103773:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010377a:	00 
8010377b:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103782:	e8 b6 fd ff ff       	call   8010353d <outb>
  outb(CMOS_PORT+1, 0x0A);
80103787:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010378e:	00 
8010378f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103796:	e8 a2 fd ff ff       	call   8010353d <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010379b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801037a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801037a5:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801037aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801037ad:	8d 50 02             	lea    0x2(%eax),%edx
801037b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b3:	c1 e8 04             	shr    $0x4,%eax
801037b6:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801037b9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801037bd:	c1 e0 18             	shl    $0x18,%eax
801037c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801037c4:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801037cb:	e8 9b fd ff ff       	call   8010356b <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801037d0:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801037d7:	00 
801037d8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801037df:	e8 87 fd ff ff       	call   8010356b <lapicw>
  microdelay(200);
801037e4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801037eb:	e8 72 ff ff ff       	call   80103762 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801037f0:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801037f7:	00 
801037f8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801037ff:	e8 67 fd ff ff       	call   8010356b <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103804:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010380b:	e8 52 ff ff ff       	call   80103762 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103810:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103817:	eb 40                	jmp    80103859 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103819:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010381d:	c1 e0 18             	shl    $0x18,%eax
80103820:	89 44 24 04          	mov    %eax,0x4(%esp)
80103824:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010382b:	e8 3b fd ff ff       	call   8010356b <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103830:	8b 45 0c             	mov    0xc(%ebp),%eax
80103833:	c1 e8 0c             	shr    $0xc,%eax
80103836:	80 cc 06             	or     $0x6,%ah
80103839:	89 44 24 04          	mov    %eax,0x4(%esp)
8010383d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103844:	e8 22 fd ff ff       	call   8010356b <lapicw>
    microdelay(200);
80103849:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103850:	e8 0d ff ff ff       	call   80103762 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103855:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103859:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010385d:	7e ba                	jle    80103819 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010385f:	c9                   	leave  
80103860:	c3                   	ret    

80103861 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103861:	55                   	push   %ebp
80103862:	89 e5                	mov    %esp,%ebp
80103864:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103867:	8b 45 08             	mov    0x8(%ebp),%eax
8010386a:	0f b6 c0             	movzbl %al,%eax
8010386d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103871:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103878:	e8 c0 fc ff ff       	call   8010353d <outb>
  microdelay(200);
8010387d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103884:	e8 d9 fe ff ff       	call   80103762 <microdelay>

  return inb(CMOS_RETURN);
80103889:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103890:	e8 8b fc ff ff       	call   80103520 <inb>
80103895:	0f b6 c0             	movzbl %al,%eax
}
80103898:	c9                   	leave  
80103899:	c3                   	ret    

8010389a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010389a:	55                   	push   %ebp
8010389b:	89 e5                	mov    %esp,%ebp
8010389d:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801038a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801038a7:	e8 b5 ff ff ff       	call   80103861 <cmos_read>
801038ac:	8b 55 08             	mov    0x8(%ebp),%edx
801038af:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801038b1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801038b8:	e8 a4 ff ff ff       	call   80103861 <cmos_read>
801038bd:	8b 55 08             	mov    0x8(%ebp),%edx
801038c0:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801038c3:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801038ca:	e8 92 ff ff ff       	call   80103861 <cmos_read>
801038cf:	8b 55 08             	mov    0x8(%ebp),%edx
801038d2:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801038d5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801038dc:	e8 80 ff ff ff       	call   80103861 <cmos_read>
801038e1:	8b 55 08             	mov    0x8(%ebp),%edx
801038e4:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801038e7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801038ee:	e8 6e ff ff ff       	call   80103861 <cmos_read>
801038f3:	8b 55 08             	mov    0x8(%ebp),%edx
801038f6:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801038f9:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103900:	e8 5c ff ff ff       	call   80103861 <cmos_read>
80103905:	8b 55 08             	mov    0x8(%ebp),%edx
80103908:	89 42 14             	mov    %eax,0x14(%edx)
}
8010390b:	c9                   	leave  
8010390c:	c3                   	ret    

8010390d <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010390d:	55                   	push   %ebp
8010390e:	89 e5                	mov    %esp,%ebp
80103910:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103913:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010391a:	e8 42 ff ff ff       	call   80103861 <cmos_read>
8010391f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103925:	83 e0 04             	and    $0x4,%eax
80103928:	85 c0                	test   %eax,%eax
8010392a:	0f 94 c0             	sete   %al
8010392d:	0f b6 c0             	movzbl %al,%eax
80103930:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103933:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103936:	89 04 24             	mov    %eax,(%esp)
80103939:	e8 5c ff ff ff       	call   8010389a <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010393e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103945:	e8 17 ff ff ff       	call   80103861 <cmos_read>
8010394a:	25 80 00 00 00       	and    $0x80,%eax
8010394f:	85 c0                	test   %eax,%eax
80103951:	74 02                	je     80103955 <cmostime+0x48>
        continue;
80103953:	eb 36                	jmp    8010398b <cmostime+0x7e>
    fill_rtcdate(&t2);
80103955:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103958:	89 04 24             	mov    %eax,(%esp)
8010395b:	e8 3a ff ff ff       	call   8010389a <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103960:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103967:	00 
80103968:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010396b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010396f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103972:	89 04 24             	mov    %eax,(%esp)
80103975:	e8 af 1f 00 00       	call   80105929 <memcmp>
8010397a:	85 c0                	test   %eax,%eax
8010397c:	75 0d                	jne    8010398b <cmostime+0x7e>
      break;
8010397e:	90                   	nop
  }

  // convert
  if (bcd) {
8010397f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103983:	0f 84 ac 00 00 00    	je     80103a35 <cmostime+0x128>
80103989:	eb 02                	jmp    8010398d <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010398b:	eb a6                	jmp    80103933 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010398d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103990:	c1 e8 04             	shr    $0x4,%eax
80103993:	89 c2                	mov    %eax,%edx
80103995:	89 d0                	mov    %edx,%eax
80103997:	c1 e0 02             	shl    $0x2,%eax
8010399a:	01 d0                	add    %edx,%eax
8010399c:	01 c0                	add    %eax,%eax
8010399e:	8b 55 d8             	mov    -0x28(%ebp),%edx
801039a1:	83 e2 0f             	and    $0xf,%edx
801039a4:	01 d0                	add    %edx,%eax
801039a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801039a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801039ac:	c1 e8 04             	shr    $0x4,%eax
801039af:	89 c2                	mov    %eax,%edx
801039b1:	89 d0                	mov    %edx,%eax
801039b3:	c1 e0 02             	shl    $0x2,%eax
801039b6:	01 d0                	add    %edx,%eax
801039b8:	01 c0                	add    %eax,%eax
801039ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
801039bd:	83 e2 0f             	and    $0xf,%edx
801039c0:	01 d0                	add    %edx,%eax
801039c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801039c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801039c8:	c1 e8 04             	shr    $0x4,%eax
801039cb:	89 c2                	mov    %eax,%edx
801039cd:	89 d0                	mov    %edx,%eax
801039cf:	c1 e0 02             	shl    $0x2,%eax
801039d2:	01 d0                	add    %edx,%eax
801039d4:	01 c0                	add    %eax,%eax
801039d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801039d9:	83 e2 0f             	and    $0xf,%edx
801039dc:	01 d0                	add    %edx,%eax
801039de:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801039e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039e4:	c1 e8 04             	shr    $0x4,%eax
801039e7:	89 c2                	mov    %eax,%edx
801039e9:	89 d0                	mov    %edx,%eax
801039eb:	c1 e0 02             	shl    $0x2,%eax
801039ee:	01 d0                	add    %edx,%eax
801039f0:	01 c0                	add    %eax,%eax
801039f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801039f5:	83 e2 0f             	and    $0xf,%edx
801039f8:	01 d0                	add    %edx,%eax
801039fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801039fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a00:	c1 e8 04             	shr    $0x4,%eax
80103a03:	89 c2                	mov    %eax,%edx
80103a05:	89 d0                	mov    %edx,%eax
80103a07:	c1 e0 02             	shl    $0x2,%eax
80103a0a:	01 d0                	add    %edx,%eax
80103a0c:	01 c0                	add    %eax,%eax
80103a0e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103a11:	83 e2 0f             	and    $0xf,%edx
80103a14:	01 d0                	add    %edx,%eax
80103a16:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103a19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a1c:	c1 e8 04             	shr    $0x4,%eax
80103a1f:	89 c2                	mov    %eax,%edx
80103a21:	89 d0                	mov    %edx,%eax
80103a23:	c1 e0 02             	shl    $0x2,%eax
80103a26:	01 d0                	add    %edx,%eax
80103a28:	01 c0                	add    %eax,%eax
80103a2a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a2d:	83 e2 0f             	and    $0xf,%edx
80103a30:	01 d0                	add    %edx,%eax
80103a32:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103a35:	8b 45 08             	mov    0x8(%ebp),%eax
80103a38:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103a3b:	89 10                	mov    %edx,(%eax)
80103a3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103a40:	89 50 04             	mov    %edx,0x4(%eax)
80103a43:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103a46:	89 50 08             	mov    %edx,0x8(%eax)
80103a49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103a4c:	89 50 0c             	mov    %edx,0xc(%eax)
80103a4f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103a52:	89 50 10             	mov    %edx,0x10(%eax)
80103a55:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a58:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5e:	8b 40 14             	mov    0x14(%eax),%eax
80103a61:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103a67:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6a:	89 50 14             	mov    %edx,0x14(%eax)
}
80103a6d:	c9                   	leave  
80103a6e:	c3                   	ret    

80103a6f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(struct partition* prt)
{
80103a6f:	55                   	push   %ebp
80103a70:	89 e5                	mov    %esp,%ebp
80103a72:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103a75:	c7 44 24 04 b4 90 10 	movl   $0x801090b4,0x4(%esp)
80103a7c:	80 
80103a7d:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103a84:	e8 b4 1b 00 00       	call   8010563d <initlock>
  readsb(prt, &sb);
80103a89:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a90:	8b 45 08             	mov    0x8(%ebp),%eax
80103a93:	89 04 24             	mov    %eax,(%esp)
80103a96:	e8 96 d8 ff ff       	call   80101331 <readsb>
  log.start = sb.logstart;
80103a9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a9e:	a3 d4 4e 11 80       	mov    %eax,0x80114ed4
  log.size = sb.nlog;
80103aa3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103aa6:	a3 d8 4e 11 80       	mov    %eax,0x80114ed8
  log.dev = prt->dev;
80103aab:	8b 45 08             	mov    0x8(%ebp),%eax
80103aae:	8b 00                	mov    (%eax),%eax
80103ab0:	a3 e4 4e 11 80       	mov    %eax,0x80114ee4
  recover_from_log();
80103ab5:	e8 9a 01 00 00       	call   80103c54 <recover_from_log>
}
80103aba:	c9                   	leave  
80103abb:	c3                   	ret    

80103abc <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103abc:	55                   	push   %ebp
80103abd:	89 e5                	mov    %esp,%ebp
80103abf:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103ac2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ac9:	e9 8c 00 00 00       	jmp    80103b5a <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103ace:	8b 15 d4 4e 11 80    	mov    0x80114ed4,%edx
80103ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad7:	01 d0                	add    %edx,%eax
80103ad9:	83 c0 01             	add    $0x1,%eax
80103adc:	89 c2                	mov    %eax,%edx
80103ade:	a1 e4 4e 11 80       	mov    0x80114ee4,%eax
80103ae3:	89 54 24 04          	mov    %edx,0x4(%esp)
80103ae7:	89 04 24             	mov    %eax,(%esp)
80103aea:	e8 b7 c6 ff ff       	call   801001a6 <bread>
80103aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af5:	83 c0 10             	add    $0x10,%eax
80103af8:	8b 04 85 ac 4e 11 80 	mov    -0x7feeb154(,%eax,4),%eax
80103aff:	89 c2                	mov    %eax,%edx
80103b01:	a1 e4 4e 11 80       	mov    0x80114ee4,%eax
80103b06:	89 54 24 04          	mov    %edx,0x4(%esp)
80103b0a:	89 04 24             	mov    %eax,(%esp)
80103b0d:	e8 94 c6 ff ff       	call   801001a6 <bread>
80103b12:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b18:	8d 50 18             	lea    0x18(%eax),%edx
80103b1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b1e:	83 c0 18             	add    $0x18,%eax
80103b21:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103b28:	00 
80103b29:	89 54 24 04          	mov    %edx,0x4(%esp)
80103b2d:	89 04 24             	mov    %eax,(%esp)
80103b30:	e8 4c 1e 00 00       	call   80105981 <memmove>
    bwrite(dbuf);  // write dst to disk
80103b35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b38:	89 04 24             	mov    %eax,(%esp)
80103b3b:	e8 9d c6 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b43:	89 04 24             	mov    %eax,(%esp)
80103b46:	e8 cc c6 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103b4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b4e:	89 04 24             	mov    %eax,(%esp)
80103b51:	e8 c1 c6 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b5a:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103b5f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b62:	0f 8f 66 ff ff ff    	jg     80103ace <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103b68:	c9                   	leave  
80103b69:	c3                   	ret    

80103b6a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103b6a:	55                   	push   %ebp
80103b6b:	89 e5                	mov    %esp,%ebp
80103b6d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103b70:	a1 d4 4e 11 80       	mov    0x80114ed4,%eax
80103b75:	89 c2                	mov    %eax,%edx
80103b77:	a1 e4 4e 11 80       	mov    0x80114ee4,%eax
80103b7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103b80:	89 04 24             	mov    %eax,(%esp)
80103b83:	e8 1e c6 ff ff       	call   801001a6 <bread>
80103b88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8e:	83 c0 18             	add    $0x18,%eax
80103b91:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103b94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b97:	8b 00                	mov    (%eax),%eax
80103b99:	a3 e8 4e 11 80       	mov    %eax,0x80114ee8
  for (i = 0; i < log.lh.n; i++) {
80103b9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ba5:	eb 1b                	jmp    80103bc2 <read_head+0x58>
    log.lh.block[i] = lh->block[i];
80103ba7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103baa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bad:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103bb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bb4:	83 c2 10             	add    $0x10,%edx
80103bb7:	89 04 95 ac 4e 11 80 	mov    %eax,-0x7feeb154(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103bbe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bc2:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103bc7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103bca:	7f db                	jg     80103ba7 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcf:	89 04 24             	mov    %eax,(%esp)
80103bd2:	e8 40 c6 ff ff       	call   80100217 <brelse>
}
80103bd7:	c9                   	leave  
80103bd8:	c3                   	ret    

80103bd9 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103bd9:	55                   	push   %ebp
80103bda:	89 e5                	mov    %esp,%ebp
80103bdc:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103bdf:	a1 d4 4e 11 80       	mov    0x80114ed4,%eax
80103be4:	89 c2                	mov    %eax,%edx
80103be6:	a1 e4 4e 11 80       	mov    0x80114ee4,%eax
80103beb:	89 54 24 04          	mov    %edx,0x4(%esp)
80103bef:	89 04 24             	mov    %eax,(%esp)
80103bf2:	e8 af c5 ff ff       	call   801001a6 <bread>
80103bf7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfd:	83 c0 18             	add    $0x18,%eax
80103c00:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103c03:	8b 15 e8 4e 11 80    	mov    0x80114ee8,%edx
80103c09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c0c:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103c0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c15:	eb 1b                	jmp    80103c32 <write_head+0x59>
    hb->block[i] = log.lh.block[i];
80103c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1a:	83 c0 10             	add    $0x10,%eax
80103c1d:	8b 0c 85 ac 4e 11 80 	mov    -0x7feeb154(,%eax,4),%ecx
80103c24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c2a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103c2e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c32:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103c37:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c3a:	7f db                	jg     80103c17 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3f:	89 04 24             	mov    %eax,(%esp)
80103c42:	e8 96 c5 ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c4a:	89 04 24             	mov    %eax,(%esp)
80103c4d:	e8 c5 c5 ff ff       	call   80100217 <brelse>
}
80103c52:	c9                   	leave  
80103c53:	c3                   	ret    

80103c54 <recover_from_log>:

static void
recover_from_log(void)
{
80103c54:	55                   	push   %ebp
80103c55:	89 e5                	mov    %esp,%ebp
80103c57:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103c5a:	e8 0b ff ff ff       	call   80103b6a <read_head>
  install_trans(); // if committed, copy from log to disk
80103c5f:	e8 58 fe ff ff       	call   80103abc <install_trans>
  log.lh.n = 0;
80103c64:	c7 05 e8 4e 11 80 00 	movl   $0x0,0x80114ee8
80103c6b:	00 00 00 
  write_head(); // clear the log
80103c6e:	e8 66 ff ff ff       	call   80103bd9 <write_head>
}
80103c73:	c9                   	leave  
80103c74:	c3                   	ret    

80103c75 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103c75:	55                   	push   %ebp
80103c76:	89 e5                	mov    %esp,%ebp
80103c78:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103c7b:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103c82:	e8 d7 19 00 00       	call   8010565e <acquire>
  while(1){
    if(log.committing){
80103c87:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103c8c:	85 c0                	test   %eax,%eax
80103c8e:	74 16                	je     80103ca6 <begin_op+0x31>
      sleep(&log, &log.lock);
80103c90:	c7 44 24 04 a0 4e 11 	movl   $0x80114ea0,0x4(%esp)
80103c97:	80 
80103c98:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103c9f:	e8 f0 16 00 00       	call   80105394 <sleep>
80103ca4:	eb 4f                	jmp    80103cf5 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103ca6:	8b 0d e8 4e 11 80    	mov    0x80114ee8,%ecx
80103cac:	a1 dc 4e 11 80       	mov    0x80114edc,%eax
80103cb1:	8d 50 01             	lea    0x1(%eax),%edx
80103cb4:	89 d0                	mov    %edx,%eax
80103cb6:	c1 e0 02             	shl    $0x2,%eax
80103cb9:	01 d0                	add    %edx,%eax
80103cbb:	01 c0                	add    %eax,%eax
80103cbd:	01 c8                	add    %ecx,%eax
80103cbf:	83 f8 1e             	cmp    $0x1e,%eax
80103cc2:	7e 16                	jle    80103cda <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103cc4:	c7 44 24 04 a0 4e 11 	movl   $0x80114ea0,0x4(%esp)
80103ccb:	80 
80103ccc:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103cd3:	e8 bc 16 00 00       	call   80105394 <sleep>
80103cd8:	eb 1b                	jmp    80103cf5 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103cda:	a1 dc 4e 11 80       	mov    0x80114edc,%eax
80103cdf:	83 c0 01             	add    $0x1,%eax
80103ce2:	a3 dc 4e 11 80       	mov    %eax,0x80114edc
      release(&log.lock);
80103ce7:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103cee:	e8 cd 19 00 00       	call   801056c0 <release>
      break;
80103cf3:	eb 02                	jmp    80103cf7 <begin_op+0x82>
    }
  }
80103cf5:	eb 90                	jmp    80103c87 <begin_op+0x12>
}
80103cf7:	c9                   	leave  
80103cf8:	c3                   	ret    

80103cf9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103cf9:	55                   	push   %ebp
80103cfa:	89 e5                	mov    %esp,%ebp
80103cfc:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103cff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103d06:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103d0d:	e8 4c 19 00 00       	call   8010565e <acquire>
  log.outstanding -= 1;
80103d12:	a1 dc 4e 11 80       	mov    0x80114edc,%eax
80103d17:	83 e8 01             	sub    $0x1,%eax
80103d1a:	a3 dc 4e 11 80       	mov    %eax,0x80114edc
  if(log.committing)
80103d1f:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103d24:	85 c0                	test   %eax,%eax
80103d26:	74 0c                	je     80103d34 <end_op+0x3b>
    panic("log.committing");
80103d28:	c7 04 24 b8 90 10 80 	movl   $0x801090b8,(%esp)
80103d2f:	e8 06 c8 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
80103d34:	a1 dc 4e 11 80       	mov    0x80114edc,%eax
80103d39:	85 c0                	test   %eax,%eax
80103d3b:	75 13                	jne    80103d50 <end_op+0x57>
    do_commit = 1;
80103d3d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103d44:	c7 05 e0 4e 11 80 01 	movl   $0x1,0x80114ee0
80103d4b:	00 00 00 
80103d4e:	eb 0c                	jmp    80103d5c <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103d50:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103d57:	e8 11 17 00 00       	call   8010546d <wakeup>
  }
  release(&log.lock);
80103d5c:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103d63:	e8 58 19 00 00       	call   801056c0 <release>

  if(do_commit){
80103d68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d6c:	74 33                	je     80103da1 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103d6e:	e8 de 00 00 00       	call   80103e51 <commit>
    acquire(&log.lock);
80103d73:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103d7a:	e8 df 18 00 00       	call   8010565e <acquire>
    log.committing = 0;
80103d7f:	c7 05 e0 4e 11 80 00 	movl   $0x0,0x80114ee0
80103d86:	00 00 00 
    wakeup(&log);
80103d89:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103d90:	e8 d8 16 00 00       	call   8010546d <wakeup>
    release(&log.lock);
80103d95:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103d9c:	e8 1f 19 00 00       	call   801056c0 <release>
  }
}
80103da1:	c9                   	leave  
80103da2:	c3                   	ret    

80103da3 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103da3:	55                   	push   %ebp
80103da4:	89 e5                	mov    %esp,%ebp
80103da6:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103da9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103db0:	e9 8c 00 00 00       	jmp    80103e41 <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103db5:	8b 15 d4 4e 11 80    	mov    0x80114ed4,%edx
80103dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbe:	01 d0                	add    %edx,%eax
80103dc0:	83 c0 01             	add    $0x1,%eax
80103dc3:	89 c2                	mov    %eax,%edx
80103dc5:	a1 e4 4e 11 80       	mov    0x80114ee4,%eax
80103dca:	89 54 24 04          	mov    %edx,0x4(%esp)
80103dce:	89 04 24             	mov    %eax,(%esp)
80103dd1:	e8 d0 c3 ff ff       	call   801001a6 <bread>
80103dd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ddc:	83 c0 10             	add    $0x10,%eax
80103ddf:	8b 04 85 ac 4e 11 80 	mov    -0x7feeb154(,%eax,4),%eax
80103de6:	89 c2                	mov    %eax,%edx
80103de8:	a1 e4 4e 11 80       	mov    0x80114ee4,%eax
80103ded:	89 54 24 04          	mov    %edx,0x4(%esp)
80103df1:	89 04 24             	mov    %eax,(%esp)
80103df4:	e8 ad c3 ff ff       	call   801001a6 <bread>
80103df9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103dfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dff:	8d 50 18             	lea    0x18(%eax),%edx
80103e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e05:	83 c0 18             	add    $0x18,%eax
80103e08:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103e0f:	00 
80103e10:	89 54 24 04          	mov    %edx,0x4(%esp)
80103e14:	89 04 24             	mov    %eax,(%esp)
80103e17:	e8 65 1b 00 00       	call   80105981 <memmove>
    bwrite(to);  // write the log
80103e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e1f:	89 04 24             	mov    %eax,(%esp)
80103e22:	e8 b6 c3 ff ff       	call   801001dd <bwrite>
    brelse(from); 
80103e27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e2a:	89 04 24             	mov    %eax,(%esp)
80103e2d:	e8 e5 c3 ff ff       	call   80100217 <brelse>
    brelse(to);
80103e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e35:	89 04 24             	mov    %eax,(%esp)
80103e38:	e8 da c3 ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103e3d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e41:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103e46:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e49:	0f 8f 66 ff ff ff    	jg     80103db5 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103e4f:	c9                   	leave  
80103e50:	c3                   	ret    

80103e51 <commit>:

static void
commit()
{
80103e51:	55                   	push   %ebp
80103e52:	89 e5                	mov    %esp,%ebp
80103e54:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103e57:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103e5c:	85 c0                	test   %eax,%eax
80103e5e:	7e 1e                	jle    80103e7e <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103e60:	e8 3e ff ff ff       	call   80103da3 <write_log>
    write_head();    // Write header to disk -- the real commit
80103e65:	e8 6f fd ff ff       	call   80103bd9 <write_head>
    install_trans(); // Now install writes to home locations
80103e6a:	e8 4d fc ff ff       	call   80103abc <install_trans>
    log.lh.n = 0; 
80103e6f:	c7 05 e8 4e 11 80 00 	movl   $0x0,0x80114ee8
80103e76:	00 00 00 
    write_head();    // Erase the transaction from the log
80103e79:	e8 5b fd ff ff       	call   80103bd9 <write_head>
  }
}
80103e7e:	c9                   	leave  
80103e7f:	c3                   	ret    

80103e80 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103e80:	55                   	push   %ebp
80103e81:	89 e5                	mov    %esp,%ebp
80103e83:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103e86:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103e8b:	83 f8 1d             	cmp    $0x1d,%eax
80103e8e:	7f 12                	jg     80103ea2 <log_write+0x22>
80103e90:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103e95:	8b 15 d8 4e 11 80    	mov    0x80114ed8,%edx
80103e9b:	83 ea 01             	sub    $0x1,%edx
80103e9e:	39 d0                	cmp    %edx,%eax
80103ea0:	7c 0c                	jl     80103eae <log_write+0x2e>
    panic("too big a transaction");
80103ea2:	c7 04 24 c7 90 10 80 	movl   $0x801090c7,(%esp)
80103ea9:	e8 8c c6 ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103eae:	a1 dc 4e 11 80       	mov    0x80114edc,%eax
80103eb3:	85 c0                	test   %eax,%eax
80103eb5:	7f 0c                	jg     80103ec3 <log_write+0x43>
    panic("log_write outside of trans");
80103eb7:	c7 04 24 dd 90 10 80 	movl   $0x801090dd,(%esp)
80103ebe:	e8 77 c6 ff ff       	call   8010053a <panic>

  acquire(&log.lock);
80103ec3:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103eca:	e8 8f 17 00 00       	call   8010565e <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103ecf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ed6:	eb 1f                	jmp    80103ef7 <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103edb:	83 c0 10             	add    $0x10,%eax
80103ede:	8b 04 85 ac 4e 11 80 	mov    -0x7feeb154(,%eax,4),%eax
80103ee5:	89 c2                	mov    %eax,%edx
80103ee7:	8b 45 08             	mov    0x8(%ebp),%eax
80103eea:	8b 40 08             	mov    0x8(%eax),%eax
80103eed:	39 c2                	cmp    %eax,%edx
80103eef:	75 02                	jne    80103ef3 <log_write+0x73>
      break;
80103ef1:	eb 0e                	jmp    80103f01 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103ef3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ef7:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103efc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103eff:	7f d7                	jg     80103ed8 <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103f01:	8b 45 08             	mov    0x8(%ebp),%eax
80103f04:	8b 40 08             	mov    0x8(%eax),%eax
80103f07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f0a:	83 c2 10             	add    $0x10,%edx
80103f0d:	89 04 95 ac 4e 11 80 	mov    %eax,-0x7feeb154(,%edx,4)
  if (i == log.lh.n)
80103f14:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103f19:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103f1c:	75 0d                	jne    80103f2b <log_write+0xab>
    log.lh.n++;
80103f1e:	a1 e8 4e 11 80       	mov    0x80114ee8,%eax
80103f23:	83 c0 01             	add    $0x1,%eax
80103f26:	a3 e8 4e 11 80       	mov    %eax,0x80114ee8
  b->flags |= B_DIRTY; // prevent eviction
80103f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2e:	8b 00                	mov    (%eax),%eax
80103f30:	83 c8 04             	or     $0x4,%eax
80103f33:	89 c2                	mov    %eax,%edx
80103f35:	8b 45 08             	mov    0x8(%ebp),%eax
80103f38:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103f3a:	c7 04 24 a0 4e 11 80 	movl   $0x80114ea0,(%esp)
80103f41:	e8 7a 17 00 00       	call   801056c0 <release>
}
80103f46:	c9                   	leave  
80103f47:	c3                   	ret    

80103f48 <v2p>:
80103f48:	55                   	push   %ebp
80103f49:	89 e5                	mov    %esp,%ebp
80103f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4e:	05 00 00 00 80       	add    $0x80000000,%eax
80103f53:	5d                   	pop    %ebp
80103f54:	c3                   	ret    

80103f55 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103f55:	55                   	push   %ebp
80103f56:	89 e5                	mov    %esp,%ebp
80103f58:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5b:	05 00 00 00 80       	add    $0x80000000,%eax
80103f60:	5d                   	pop    %ebp
80103f61:	c3                   	ret    

80103f62 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103f62:	55                   	push   %ebp
80103f63:	89 e5                	mov    %esp,%ebp
80103f65:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103f68:	8b 55 08             	mov    0x8(%ebp),%edx
80103f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f71:	f0 87 02             	lock xchg %eax,(%edx)
80103f74:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103f77:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103f7a:	c9                   	leave  
80103f7b:	c3                   	ret    

80103f7c <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103f7c:	55                   	push   %ebp
80103f7d:	89 e5                	mov    %esp,%ebp
80103f7f:	83 e4 f0             	and    $0xfffffff0,%esp
80103f82:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103f85:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103f8c:	80 
80103f8d:	c7 04 24 7c 7d 11 80 	movl   $0x80117d7c,(%esp)
80103f94:	e8 88 f2 ff ff       	call   80103221 <kinit1>
  kvmalloc();      // kernel page table
80103f99:	e8 2f 45 00 00       	call   801084cd <kvmalloc>
  mpinit();        // collect info about this machine
80103f9e:	e8 41 04 00 00       	call   801043e4 <mpinit>
  lapicinit();
80103fa3:	e8 e4 f5 ff ff       	call   8010358c <lapicinit>
  seginit();       // set up segments
80103fa8:	e8 b3 3e 00 00       	call   80107e60 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103fad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103fb3:	0f b6 00             	movzbl (%eax),%eax
80103fb6:	0f b6 c0             	movzbl %al,%eax
80103fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fbd:	c7 04 24 f8 90 10 80 	movl   $0x801090f8,(%esp)
80103fc4:	e8 d7 c3 ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103fc9:	e8 74 06 00 00       	call   80104642 <picinit>
  ioapicinit();    // another interrupt controller
80103fce:	e8 44 f1 ff ff       	call   80103117 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103fd3:	e8 d8 ca ff ff       	call   80100ab0 <consoleinit>
  uartinit();      // serial port
80103fd8:	e8 d2 31 00 00       	call   801071af <uartinit>
  pinit();         // process table
80103fdd:	e8 6a 0b 00 00       	call   80104b4c <pinit>
  tvinit();        // trap vectors
80103fe2:	e8 7a 2d 00 00       	call   80106d61 <tvinit>
  binit();         // buffer cache
80103fe7:	e8 48 c0 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103fec:	e8 34 cf ff ff       	call   80100f25 <fileinit>
  ideinit();       // disk
80103ff1:	e8 3d ed ff ff       	call   80102d33 <ideinit>
  if(!ismp)
80103ff6:	a1 84 4f 11 80       	mov    0x80114f84,%eax
80103ffb:	85 c0                	test   %eax,%eax
80103ffd:	75 05                	jne    80104004 <main+0x88>
    timerinit();   // uniprocessor timer
80103fff:	e8 a8 2c 00 00       	call   80106cac <timerinit>
  startothers();   // start other processors
80104004:	e8 7f 00 00 00       	call   80104088 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80104009:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80104010:	8e 
80104011:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80104018:	e8 3c f2 ff ff       	call   80103259 <kinit2>
  userinit();      // first user process
8010401d:	e8 45 0c 00 00       	call   80104c67 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80104022:	e8 1a 00 00 00       	call   80104041 <mpmain>

80104027 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80104027:	55                   	push   %ebp
80104028:	89 e5                	mov    %esp,%ebp
8010402a:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010402d:	e8 b2 44 00 00       	call   801084e4 <switchkvm>
  seginit();
80104032:	e8 29 3e 00 00       	call   80107e60 <seginit>
  lapicinit();
80104037:	e8 50 f5 ff ff       	call   8010358c <lapicinit>
  mpmain();
8010403c:	e8 00 00 00 00       	call   80104041 <mpmain>

80104041 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80104041:	55                   	push   %ebp
80104042:	89 e5                	mov    %esp,%ebp
80104044:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80104047:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010404d:	0f b6 00             	movzbl (%eax),%eax
80104050:	0f b6 c0             	movzbl %al,%eax
80104053:	89 44 24 04          	mov    %eax,0x4(%esp)
80104057:	c7 04 24 0f 91 10 80 	movl   $0x8010910f,(%esp)
8010405e:	e8 3d c3 ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80104063:	e8 6d 2e 00 00       	call   80106ed5 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80104068:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010406e:	05 a8 00 00 00       	add    $0xa8,%eax
80104073:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010407a:	00 
8010407b:	89 04 24             	mov    %eax,(%esp)
8010407e:	e8 df fe ff ff       	call   80103f62 <xchg>
  scheduler();     // start running processes
80104083:	e8 50 11 00 00       	call   801051d8 <scheduler>

80104088 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80104088:	55                   	push   %ebp
80104089:	89 e5                	mov    %esp,%ebp
8010408b:	53                   	push   %ebx
8010408c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010408f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80104096:	e8 ba fe ff ff       	call   80103f55 <p2v>
8010409b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010409e:	b8 8a 00 00 00       	mov    $0x8a,%eax
801040a3:	89 44 24 08          	mov    %eax,0x8(%esp)
801040a7:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
801040ae:	80 
801040af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040b2:	89 04 24             	mov    %eax,(%esp)
801040b5:	e8 c7 18 00 00       	call   80105981 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801040ba:	c7 45 f4 a0 4f 11 80 	movl   $0x80114fa0,-0xc(%ebp)
801040c1:	e9 85 00 00 00       	jmp    8010414b <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
801040c6:	e8 1a f6 ff ff       	call   801036e5 <cpunum>
801040cb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801040d1:	05 a0 4f 11 80       	add    $0x80114fa0,%eax
801040d6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801040d9:	75 02                	jne    801040dd <startothers+0x55>
      continue;
801040db:	eb 67                	jmp    80104144 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801040dd:	e8 6d f2 ff ff       	call   8010334f <kalloc>
801040e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801040e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040e8:	83 e8 04             	sub    $0x4,%eax
801040eb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801040ee:	81 c2 00 10 00 00    	add    $0x1000,%edx
801040f4:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801040f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f9:	83 e8 08             	sub    $0x8,%eax
801040fc:	c7 00 27 40 10 80    	movl   $0x80104027,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80104102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104105:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104108:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
8010410f:	e8 34 fe ff ff       	call   80103f48 <v2p>
80104114:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80104116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104119:	89 04 24             	mov    %eax,(%esp)
8010411c:	e8 27 fe ff ff       	call   80103f48 <v2p>
80104121:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104124:	0f b6 12             	movzbl (%edx),%edx
80104127:	0f b6 d2             	movzbl %dl,%edx
8010412a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010412e:	89 14 24             	mov    %edx,(%esp)
80104131:	e8 31 f6 ff ff       	call   80103767 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80104136:	90                   	nop
80104137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104140:	85 c0                	test   %eax,%eax
80104142:	74 f3                	je     80104137 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80104144:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010414b:	a1 80 55 11 80       	mov    0x80115580,%eax
80104150:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104156:	05 a0 4f 11 80       	add    $0x80114fa0,%eax
8010415b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010415e:	0f 87 62 ff ff ff    	ja     801040c6 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80104164:	83 c4 24             	add    $0x24,%esp
80104167:	5b                   	pop    %ebx
80104168:	5d                   	pop    %ebp
80104169:	c3                   	ret    

8010416a <p2v>:
8010416a:	55                   	push   %ebp
8010416b:	89 e5                	mov    %esp,%ebp
8010416d:	8b 45 08             	mov    0x8(%ebp),%eax
80104170:	05 00 00 00 80       	add    $0x80000000,%eax
80104175:	5d                   	pop    %ebp
80104176:	c3                   	ret    

80104177 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80104177:	55                   	push   %ebp
80104178:	89 e5                	mov    %esp,%ebp
8010417a:	83 ec 14             	sub    $0x14,%esp
8010417d:	8b 45 08             	mov    0x8(%ebp),%eax
80104180:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80104184:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80104188:	89 c2                	mov    %eax,%edx
8010418a:	ec                   	in     (%dx),%al
8010418b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010418e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80104192:	c9                   	leave  
80104193:	c3                   	ret    

80104194 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104194:	55                   	push   %ebp
80104195:	89 e5                	mov    %esp,%ebp
80104197:	83 ec 08             	sub    $0x8,%esp
8010419a:	8b 55 08             	mov    0x8(%ebp),%edx
8010419d:	8b 45 0c             	mov    0xc(%ebp),%eax
801041a0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801041a4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801041a7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801041ab:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801041af:	ee                   	out    %al,(%dx)
}
801041b0:	c9                   	leave  
801041b1:	c3                   	ret    

801041b2 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801041b2:	55                   	push   %ebp
801041b3:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801041b5:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801041ba:	89 c2                	mov    %eax,%edx
801041bc:	b8 a0 4f 11 80       	mov    $0x80114fa0,%eax
801041c1:	29 c2                	sub    %eax,%edx
801041c3:	89 d0                	mov    %edx,%eax
801041c5:	c1 f8 02             	sar    $0x2,%eax
801041c8:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801041ce:	5d                   	pop    %ebp
801041cf:	c3                   	ret    

801041d0 <sum>:

static uchar
sum(uchar *addr, int len)
{
801041d0:	55                   	push   %ebp
801041d1:	89 e5                	mov    %esp,%ebp
801041d3:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801041d6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801041dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801041e4:	eb 15                	jmp    801041fb <sum+0x2b>
    sum += addr[i];
801041e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801041e9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ec:	01 d0                	add    %edx,%eax
801041ee:	0f b6 00             	movzbl (%eax),%eax
801041f1:	0f b6 c0             	movzbl %al,%eax
801041f4:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801041f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801041fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801041fe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104201:	7c e3                	jl     801041e6 <sum+0x16>
    sum += addr[i];
  return sum;
80104203:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104206:	c9                   	leave  
80104207:	c3                   	ret    

80104208 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104208:	55                   	push   %ebp
80104209:	89 e5                	mov    %esp,%ebp
8010420b:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
8010420e:	8b 45 08             	mov    0x8(%ebp),%eax
80104211:	89 04 24             	mov    %eax,(%esp)
80104214:	e8 51 ff ff ff       	call   8010416a <p2v>
80104219:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
8010421c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010421f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104222:	01 d0                	add    %edx,%eax
80104224:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010422a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010422d:	eb 3f                	jmp    8010426e <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010422f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104236:	00 
80104237:	c7 44 24 04 20 91 10 	movl   $0x80109120,0x4(%esp)
8010423e:	80 
8010423f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104242:	89 04 24             	mov    %eax,(%esp)
80104245:	e8 df 16 00 00       	call   80105929 <memcmp>
8010424a:	85 c0                	test   %eax,%eax
8010424c:	75 1c                	jne    8010426a <mpsearch1+0x62>
8010424e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80104255:	00 
80104256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104259:	89 04 24             	mov    %eax,(%esp)
8010425c:	e8 6f ff ff ff       	call   801041d0 <sum>
80104261:	84 c0                	test   %al,%al
80104263:	75 05                	jne    8010426a <mpsearch1+0x62>
      return (struct mp*)p;
80104265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104268:	eb 11                	jmp    8010427b <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
8010426a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010426e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104271:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104274:	72 b9                	jb     8010422f <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80104276:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010427b:	c9                   	leave  
8010427c:	c3                   	ret    

8010427d <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
8010427d:	55                   	push   %ebp
8010427e:	89 e5                	mov    %esp,%ebp
80104280:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80104283:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
8010428a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010428d:	83 c0 0f             	add    $0xf,%eax
80104290:	0f b6 00             	movzbl (%eax),%eax
80104293:	0f b6 c0             	movzbl %al,%eax
80104296:	c1 e0 08             	shl    $0x8,%eax
80104299:	89 c2                	mov    %eax,%edx
8010429b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429e:	83 c0 0e             	add    $0xe,%eax
801042a1:	0f b6 00             	movzbl (%eax),%eax
801042a4:	0f b6 c0             	movzbl %al,%eax
801042a7:	09 d0                	or     %edx,%eax
801042a9:	c1 e0 04             	shl    $0x4,%eax
801042ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
801042af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042b3:	74 21                	je     801042d6 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801042b5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801042bc:	00 
801042bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042c0:	89 04 24             	mov    %eax,(%esp)
801042c3:	e8 40 ff ff ff       	call   80104208 <mpsearch1>
801042c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801042cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801042cf:	74 50                	je     80104321 <mpsearch+0xa4>
      return mp;
801042d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042d4:	eb 5f                	jmp    80104335 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801042d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d9:	83 c0 14             	add    $0x14,%eax
801042dc:	0f b6 00             	movzbl (%eax),%eax
801042df:	0f b6 c0             	movzbl %al,%eax
801042e2:	c1 e0 08             	shl    $0x8,%eax
801042e5:	89 c2                	mov    %eax,%edx
801042e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ea:	83 c0 13             	add    $0x13,%eax
801042ed:	0f b6 00             	movzbl (%eax),%eax
801042f0:	0f b6 c0             	movzbl %al,%eax
801042f3:	09 d0                	or     %edx,%eax
801042f5:	c1 e0 0a             	shl    $0xa,%eax
801042f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
801042fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042fe:	2d 00 04 00 00       	sub    $0x400,%eax
80104303:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
8010430a:	00 
8010430b:	89 04 24             	mov    %eax,(%esp)
8010430e:	e8 f5 fe ff ff       	call   80104208 <mpsearch1>
80104313:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104316:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010431a:	74 05                	je     80104321 <mpsearch+0xa4>
      return mp;
8010431c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010431f:	eb 14                	jmp    80104335 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80104321:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80104328:	00 
80104329:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80104330:	e8 d3 fe ff ff       	call   80104208 <mpsearch1>
}
80104335:	c9                   	leave  
80104336:	c3                   	ret    

80104337 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80104337:	55                   	push   %ebp
80104338:	89 e5                	mov    %esp,%ebp
8010433a:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
8010433d:	e8 3b ff ff ff       	call   8010427d <mpsearch>
80104342:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104345:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104349:	74 0a                	je     80104355 <mpconfig+0x1e>
8010434b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434e:	8b 40 04             	mov    0x4(%eax),%eax
80104351:	85 c0                	test   %eax,%eax
80104353:	75 0a                	jne    8010435f <mpconfig+0x28>
    return 0;
80104355:	b8 00 00 00 00       	mov    $0x0,%eax
8010435a:	e9 83 00 00 00       	jmp    801043e2 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
8010435f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104362:	8b 40 04             	mov    0x4(%eax),%eax
80104365:	89 04 24             	mov    %eax,(%esp)
80104368:	e8 fd fd ff ff       	call   8010416a <p2v>
8010436d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80104370:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104377:	00 
80104378:	c7 44 24 04 25 91 10 	movl   $0x80109125,0x4(%esp)
8010437f:	80 
80104380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104383:	89 04 24             	mov    %eax,(%esp)
80104386:	e8 9e 15 00 00       	call   80105929 <memcmp>
8010438b:	85 c0                	test   %eax,%eax
8010438d:	74 07                	je     80104396 <mpconfig+0x5f>
    return 0;
8010438f:	b8 00 00 00 00       	mov    $0x0,%eax
80104394:	eb 4c                	jmp    801043e2 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80104396:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104399:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010439d:	3c 01                	cmp    $0x1,%al
8010439f:	74 12                	je     801043b3 <mpconfig+0x7c>
801043a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043a4:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801043a8:	3c 04                	cmp    $0x4,%al
801043aa:	74 07                	je     801043b3 <mpconfig+0x7c>
    return 0;
801043ac:	b8 00 00 00 00       	mov    $0x0,%eax
801043b1:	eb 2f                	jmp    801043e2 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
801043b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043b6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801043ba:	0f b7 c0             	movzwl %ax,%eax
801043bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801043c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043c4:	89 04 24             	mov    %eax,(%esp)
801043c7:	e8 04 fe ff ff       	call   801041d0 <sum>
801043cc:	84 c0                	test   %al,%al
801043ce:	74 07                	je     801043d7 <mpconfig+0xa0>
    return 0;
801043d0:	b8 00 00 00 00       	mov    $0x0,%eax
801043d5:	eb 0b                	jmp    801043e2 <mpconfig+0xab>
  *pmp = mp;
801043d7:	8b 45 08             	mov    0x8(%ebp),%eax
801043da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043dd:	89 10                	mov    %edx,(%eax)
  return conf;
801043df:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801043e2:	c9                   	leave  
801043e3:	c3                   	ret    

801043e4 <mpinit>:

void
mpinit(void)
{
801043e4:	55                   	push   %ebp
801043e5:	89 e5                	mov    %esp,%ebp
801043e7:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
801043ea:	c7 05 44 c6 10 80 a0 	movl   $0x80114fa0,0x8010c644
801043f1:	4f 11 80 
  if((conf = mpconfig(&mp)) == 0)
801043f4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801043f7:	89 04 24             	mov    %eax,(%esp)
801043fa:	e8 38 ff ff ff       	call   80104337 <mpconfig>
801043ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104402:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104406:	75 05                	jne    8010440d <mpinit+0x29>
    return;
80104408:	e9 9c 01 00 00       	jmp    801045a9 <mpinit+0x1c5>
  ismp = 1;
8010440d:	c7 05 84 4f 11 80 01 	movl   $0x1,0x80114f84
80104414:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010441a:	8b 40 24             	mov    0x24(%eax),%eax
8010441d:	a3 9c 4e 11 80       	mov    %eax,0x80114e9c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104422:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104425:	83 c0 2c             	add    $0x2c,%eax
80104428:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010442b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010442e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104432:	0f b7 d0             	movzwl %ax,%edx
80104435:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104438:	01 d0                	add    %edx,%eax
8010443a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010443d:	e9 f4 00 00 00       	jmp    80104536 <mpinit+0x152>
    switch(*p){
80104442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104445:	0f b6 00             	movzbl (%eax),%eax
80104448:	0f b6 c0             	movzbl %al,%eax
8010444b:	83 f8 04             	cmp    $0x4,%eax
8010444e:	0f 87 bf 00 00 00    	ja     80104513 <mpinit+0x12f>
80104454:	8b 04 85 68 91 10 80 	mov    -0x7fef6e98(,%eax,4),%eax
8010445b:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010445d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104460:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104463:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104466:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010446a:	0f b6 d0             	movzbl %al,%edx
8010446d:	a1 80 55 11 80       	mov    0x80115580,%eax
80104472:	39 c2                	cmp    %eax,%edx
80104474:	74 2d                	je     801044a3 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104476:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104479:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010447d:	0f b6 d0             	movzbl %al,%edx
80104480:	a1 80 55 11 80       	mov    0x80115580,%eax
80104485:	89 54 24 08          	mov    %edx,0x8(%esp)
80104489:	89 44 24 04          	mov    %eax,0x4(%esp)
8010448d:	c7 04 24 2a 91 10 80 	movl   $0x8010912a,(%esp)
80104494:	e8 07 bf ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80104499:	c7 05 84 4f 11 80 00 	movl   $0x0,0x80114f84
801044a0:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801044a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044a6:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801044aa:	0f b6 c0             	movzbl %al,%eax
801044ad:	83 e0 02             	and    $0x2,%eax
801044b0:	85 c0                	test   %eax,%eax
801044b2:	74 15                	je     801044c9 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
801044b4:	a1 80 55 11 80       	mov    0x80115580,%eax
801044b9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801044bf:	05 a0 4f 11 80       	add    $0x80114fa0,%eax
801044c4:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
801044c9:	8b 15 80 55 11 80    	mov    0x80115580,%edx
801044cf:	a1 80 55 11 80       	mov    0x80115580,%eax
801044d4:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
801044da:	81 c2 a0 4f 11 80    	add    $0x80114fa0,%edx
801044e0:	88 02                	mov    %al,(%edx)
      ncpu++;
801044e2:	a1 80 55 11 80       	mov    0x80115580,%eax
801044e7:	83 c0 01             	add    $0x1,%eax
801044ea:	a3 80 55 11 80       	mov    %eax,0x80115580
      p += sizeof(struct mpproc);
801044ef:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801044f3:	eb 41                	jmp    80104536 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801044f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801044fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801044fe:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104502:	a2 80 4f 11 80       	mov    %al,0x80114f80
      p += sizeof(struct mpioapic);
80104507:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010450b:	eb 29                	jmp    80104536 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010450d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104511:	eb 23                	jmp    80104536 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104516:	0f b6 00             	movzbl (%eax),%eax
80104519:	0f b6 c0             	movzbl %al,%eax
8010451c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104520:	c7 04 24 48 91 10 80 	movl   $0x80109148,(%esp)
80104527:	e8 74 be ff ff       	call   801003a0 <cprintf>
      ismp = 0;
8010452c:	c7 05 84 4f 11 80 00 	movl   $0x0,0x80114f84
80104533:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104539:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010453c:	0f 82 00 ff ff ff    	jb     80104442 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104542:	a1 84 4f 11 80       	mov    0x80114f84,%eax
80104547:	85 c0                	test   %eax,%eax
80104549:	75 1d                	jne    80104568 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
8010454b:	c7 05 80 55 11 80 01 	movl   $0x1,0x80115580
80104552:	00 00 00 
    lapic = 0;
80104555:	c7 05 9c 4e 11 80 00 	movl   $0x0,0x80114e9c
8010455c:	00 00 00 
    ioapicid = 0;
8010455f:	c6 05 80 4f 11 80 00 	movb   $0x0,0x80114f80
    return;
80104566:	eb 41                	jmp    801045a9 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80104568:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010456b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010456f:	84 c0                	test   %al,%al
80104571:	74 36                	je     801045a9 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104573:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
8010457a:	00 
8010457b:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80104582:	e8 0d fc ff ff       	call   80104194 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104587:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010458e:	e8 e4 fb ff ff       	call   80104177 <inb>
80104593:	83 c8 01             	or     $0x1,%eax
80104596:	0f b6 c0             	movzbl %al,%eax
80104599:	89 44 24 04          	mov    %eax,0x4(%esp)
8010459d:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
801045a4:	e8 eb fb ff ff       	call   80104194 <outb>
  }
}
801045a9:	c9                   	leave  
801045aa:	c3                   	ret    

801045ab <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045ab:	55                   	push   %ebp
801045ac:	89 e5                	mov    %esp,%ebp
801045ae:	83 ec 08             	sub    $0x8,%esp
801045b1:	8b 55 08             	mov    0x8(%ebp),%edx
801045b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801045b7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801045bb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801045be:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801045c2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801045c6:	ee                   	out    %al,(%dx)
}
801045c7:	c9                   	leave  
801045c8:	c3                   	ret    

801045c9 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
801045c9:	55                   	push   %ebp
801045ca:	89 e5                	mov    %esp,%ebp
801045cc:	83 ec 0c             	sub    $0xc,%esp
801045cf:	8b 45 08             	mov    0x8(%ebp),%eax
801045d2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
801045d6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801045da:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
801045e0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801045e4:	0f b6 c0             	movzbl %al,%eax
801045e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801045eb:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801045f2:	e8 b4 ff ff ff       	call   801045ab <outb>
  outb(IO_PIC2+1, mask >> 8);
801045f7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801045fb:	66 c1 e8 08          	shr    $0x8,%ax
801045ff:	0f b6 c0             	movzbl %al,%eax
80104602:	89 44 24 04          	mov    %eax,0x4(%esp)
80104606:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010460d:	e8 99 ff ff ff       	call   801045ab <outb>
}
80104612:	c9                   	leave  
80104613:	c3                   	ret    

80104614 <picenable>:

void
picenable(int irq)
{
80104614:	55                   	push   %ebp
80104615:	89 e5                	mov    %esp,%ebp
80104617:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
8010461a:	8b 45 08             	mov    0x8(%ebp),%eax
8010461d:	ba 01 00 00 00       	mov    $0x1,%edx
80104622:	89 c1                	mov    %eax,%ecx
80104624:	d3 e2                	shl    %cl,%edx
80104626:	89 d0                	mov    %edx,%eax
80104628:	f7 d0                	not    %eax
8010462a:	89 c2                	mov    %eax,%edx
8010462c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104633:	21 d0                	and    %edx,%eax
80104635:	0f b7 c0             	movzwl %ax,%eax
80104638:	89 04 24             	mov    %eax,(%esp)
8010463b:	e8 89 ff ff ff       	call   801045c9 <picsetmask>
}
80104640:	c9                   	leave  
80104641:	c3                   	ret    

80104642 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104642:	55                   	push   %ebp
80104643:	89 e5                	mov    %esp,%ebp
80104645:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104648:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
8010464f:	00 
80104650:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104657:	e8 4f ff ff ff       	call   801045ab <outb>
  outb(IO_PIC2+1, 0xFF);
8010465c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104663:	00 
80104664:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010466b:	e8 3b ff ff ff       	call   801045ab <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104670:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80104677:	00 
80104678:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010467f:	e8 27 ff ff ff       	call   801045ab <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104684:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
8010468b:	00 
8010468c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104693:	e8 13 ff ff ff       	call   801045ab <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104698:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
8010469f:	00 
801046a0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801046a7:	e8 ff fe ff ff       	call   801045ab <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
801046ac:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801046b3:	00 
801046b4:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801046bb:	e8 eb fe ff ff       	call   801045ab <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801046c0:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
801046c7:	00 
801046c8:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801046cf:	e8 d7 fe ff ff       	call   801045ab <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801046d4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
801046db:	00 
801046dc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801046e3:	e8 c3 fe ff ff       	call   801045ab <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801046e8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801046ef:	00 
801046f0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801046f7:	e8 af fe ff ff       	call   801045ab <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801046fc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80104703:	00 
80104704:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010470b:	e8 9b fe ff ff       	call   801045ab <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104710:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80104717:	00 
80104718:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010471f:	e8 87 fe ff ff       	call   801045ab <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104724:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010472b:	00 
8010472c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80104733:	e8 73 fe ff ff       	call   801045ab <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80104738:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
8010473f:	00 
80104740:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104747:	e8 5f fe ff ff       	call   801045ab <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
8010474c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80104753:	00 
80104754:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010475b:	e8 4b fe ff ff       	call   801045ab <outb>

  if(irqmask != 0xFFFF)
80104760:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104767:	66 83 f8 ff          	cmp    $0xffff,%ax
8010476b:	74 12                	je     8010477f <picinit+0x13d>
    picsetmask(irqmask);
8010476d:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104774:	0f b7 c0             	movzwl %ax,%eax
80104777:	89 04 24             	mov    %eax,(%esp)
8010477a:	e8 4a fe ff ff       	call   801045c9 <picsetmask>
}
8010477f:	c9                   	leave  
80104780:	c3                   	ret    

80104781 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104781:	55                   	push   %ebp
80104782:	89 e5                	mov    %esp,%ebp
80104784:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80104787:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010478e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104791:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104797:	8b 45 0c             	mov    0xc(%ebp),%eax
8010479a:	8b 10                	mov    (%eax),%edx
8010479c:	8b 45 08             	mov    0x8(%ebp),%eax
8010479f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801047a1:	e8 9b c7 ff ff       	call   80100f41 <filealloc>
801047a6:	8b 55 08             	mov    0x8(%ebp),%edx
801047a9:	89 02                	mov    %eax,(%edx)
801047ab:	8b 45 08             	mov    0x8(%ebp),%eax
801047ae:	8b 00                	mov    (%eax),%eax
801047b0:	85 c0                	test   %eax,%eax
801047b2:	0f 84 c8 00 00 00    	je     80104880 <pipealloc+0xff>
801047b8:	e8 84 c7 ff ff       	call   80100f41 <filealloc>
801047bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801047c0:	89 02                	mov    %eax,(%edx)
801047c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801047c5:	8b 00                	mov    (%eax),%eax
801047c7:	85 c0                	test   %eax,%eax
801047c9:	0f 84 b1 00 00 00    	je     80104880 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801047cf:	e8 7b eb ff ff       	call   8010334f <kalloc>
801047d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047db:	75 05                	jne    801047e2 <pipealloc+0x61>
    goto bad;
801047dd:	e9 9e 00 00 00       	jmp    80104880 <pipealloc+0xff>
  p->readopen = 1;
801047e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e5:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801047ec:	00 00 00 
  p->writeopen = 1;
801047ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f2:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801047f9:	00 00 00 
  p->nwrite = 0;
801047fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ff:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104806:	00 00 00 
  p->nread = 0;
80104809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480c:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104813:	00 00 00 
  initlock(&p->lock, "pipe");
80104816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104819:	c7 44 24 04 7c 91 10 	movl   $0x8010917c,0x4(%esp)
80104820:	80 
80104821:	89 04 24             	mov    %eax,(%esp)
80104824:	e8 14 0e 00 00       	call   8010563d <initlock>
  (*f0)->type = FD_PIPE;
80104829:	8b 45 08             	mov    0x8(%ebp),%eax
8010482c:	8b 00                	mov    (%eax),%eax
8010482e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104834:	8b 45 08             	mov    0x8(%ebp),%eax
80104837:	8b 00                	mov    (%eax),%eax
80104839:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010483d:	8b 45 08             	mov    0x8(%ebp),%eax
80104840:	8b 00                	mov    (%eax),%eax
80104842:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104846:	8b 45 08             	mov    0x8(%ebp),%eax
80104849:	8b 00                	mov    (%eax),%eax
8010484b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010484e:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104851:	8b 45 0c             	mov    0xc(%ebp),%eax
80104854:	8b 00                	mov    (%eax),%eax
80104856:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010485c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010485f:	8b 00                	mov    (%eax),%eax
80104861:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104865:	8b 45 0c             	mov    0xc(%ebp),%eax
80104868:	8b 00                	mov    (%eax),%eax
8010486a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010486e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104871:	8b 00                	mov    (%eax),%eax
80104873:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104876:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104879:	b8 00 00 00 00       	mov    $0x0,%eax
8010487e:	eb 42                	jmp    801048c2 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104880:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104884:	74 0b                	je     80104891 <pipealloc+0x110>
    kfree((char*)p);
80104886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104889:	89 04 24             	mov    %eax,(%esp)
8010488c:	e8 25 ea ff ff       	call   801032b6 <kfree>
  if(*f0)
80104891:	8b 45 08             	mov    0x8(%ebp),%eax
80104894:	8b 00                	mov    (%eax),%eax
80104896:	85 c0                	test   %eax,%eax
80104898:	74 0d                	je     801048a7 <pipealloc+0x126>
    fileclose(*f0);
8010489a:	8b 45 08             	mov    0x8(%ebp),%eax
8010489d:	8b 00                	mov    (%eax),%eax
8010489f:	89 04 24             	mov    %eax,(%esp)
801048a2:	e8 42 c7 ff ff       	call   80100fe9 <fileclose>
  if(*f1)
801048a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801048aa:	8b 00                	mov    (%eax),%eax
801048ac:	85 c0                	test   %eax,%eax
801048ae:	74 0d                	je     801048bd <pipealloc+0x13c>
    fileclose(*f1);
801048b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801048b3:	8b 00                	mov    (%eax),%eax
801048b5:	89 04 24             	mov    %eax,(%esp)
801048b8:	e8 2c c7 ff ff       	call   80100fe9 <fileclose>
  return -1;
801048bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801048c2:	c9                   	leave  
801048c3:	c3                   	ret    

801048c4 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801048c4:	55                   	push   %ebp
801048c5:	89 e5                	mov    %esp,%ebp
801048c7:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801048ca:	8b 45 08             	mov    0x8(%ebp),%eax
801048cd:	89 04 24             	mov    %eax,(%esp)
801048d0:	e8 89 0d 00 00       	call   8010565e <acquire>
  if(writable){
801048d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801048d9:	74 1f                	je     801048fa <pipeclose+0x36>
    p->writeopen = 0;
801048db:	8b 45 08             	mov    0x8(%ebp),%eax
801048de:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801048e5:	00 00 00 
    wakeup(&p->nread);
801048e8:	8b 45 08             	mov    0x8(%ebp),%eax
801048eb:	05 34 02 00 00       	add    $0x234,%eax
801048f0:	89 04 24             	mov    %eax,(%esp)
801048f3:	e8 75 0b 00 00       	call   8010546d <wakeup>
801048f8:	eb 1d                	jmp    80104917 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801048fa:	8b 45 08             	mov    0x8(%ebp),%eax
801048fd:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104904:	00 00 00 
    wakeup(&p->nwrite);
80104907:	8b 45 08             	mov    0x8(%ebp),%eax
8010490a:	05 38 02 00 00       	add    $0x238,%eax
8010490f:	89 04 24             	mov    %eax,(%esp)
80104912:	e8 56 0b 00 00       	call   8010546d <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104917:	8b 45 08             	mov    0x8(%ebp),%eax
8010491a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104920:	85 c0                	test   %eax,%eax
80104922:	75 25                	jne    80104949 <pipeclose+0x85>
80104924:	8b 45 08             	mov    0x8(%ebp),%eax
80104927:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010492d:	85 c0                	test   %eax,%eax
8010492f:	75 18                	jne    80104949 <pipeclose+0x85>
    release(&p->lock);
80104931:	8b 45 08             	mov    0x8(%ebp),%eax
80104934:	89 04 24             	mov    %eax,(%esp)
80104937:	e8 84 0d 00 00       	call   801056c0 <release>
    kfree((char*)p);
8010493c:	8b 45 08             	mov    0x8(%ebp),%eax
8010493f:	89 04 24             	mov    %eax,(%esp)
80104942:	e8 6f e9 ff ff       	call   801032b6 <kfree>
80104947:	eb 0b                	jmp    80104954 <pipeclose+0x90>
  } else
    release(&p->lock);
80104949:	8b 45 08             	mov    0x8(%ebp),%eax
8010494c:	89 04 24             	mov    %eax,(%esp)
8010494f:	e8 6c 0d 00 00       	call   801056c0 <release>
}
80104954:	c9                   	leave  
80104955:	c3                   	ret    

80104956 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104956:	55                   	push   %ebp
80104957:	89 e5                	mov    %esp,%ebp
80104959:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
8010495c:	8b 45 08             	mov    0x8(%ebp),%eax
8010495f:	89 04 24             	mov    %eax,(%esp)
80104962:	e8 f7 0c 00 00       	call   8010565e <acquire>
  for(i = 0; i < n; i++){
80104967:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010496e:	e9 a6 00 00 00       	jmp    80104a19 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104973:	eb 57                	jmp    801049cc <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80104975:	8b 45 08             	mov    0x8(%ebp),%eax
80104978:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010497e:	85 c0                	test   %eax,%eax
80104980:	74 0d                	je     8010498f <pipewrite+0x39>
80104982:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104988:	8b 40 24             	mov    0x24(%eax),%eax
8010498b:	85 c0                	test   %eax,%eax
8010498d:	74 15                	je     801049a4 <pipewrite+0x4e>
        release(&p->lock);
8010498f:	8b 45 08             	mov    0x8(%ebp),%eax
80104992:	89 04 24             	mov    %eax,(%esp)
80104995:	e8 26 0d 00 00       	call   801056c0 <release>
        return -1;
8010499a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010499f:	e9 9f 00 00 00       	jmp    80104a43 <pipewrite+0xed>
      }
      wakeup(&p->nread);
801049a4:	8b 45 08             	mov    0x8(%ebp),%eax
801049a7:	05 34 02 00 00       	add    $0x234,%eax
801049ac:	89 04 24             	mov    %eax,(%esp)
801049af:	e8 b9 0a 00 00       	call   8010546d <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801049b4:	8b 45 08             	mov    0x8(%ebp),%eax
801049b7:	8b 55 08             	mov    0x8(%ebp),%edx
801049ba:	81 c2 38 02 00 00    	add    $0x238,%edx
801049c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801049c4:	89 14 24             	mov    %edx,(%esp)
801049c7:	e8 c8 09 00 00       	call   80105394 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801049cc:	8b 45 08             	mov    0x8(%ebp),%eax
801049cf:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801049d5:	8b 45 08             	mov    0x8(%ebp),%eax
801049d8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801049de:	05 00 02 00 00       	add    $0x200,%eax
801049e3:	39 c2                	cmp    %eax,%edx
801049e5:	74 8e                	je     80104975 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801049e7:	8b 45 08             	mov    0x8(%ebp),%eax
801049ea:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801049f0:	8d 48 01             	lea    0x1(%eax),%ecx
801049f3:	8b 55 08             	mov    0x8(%ebp),%edx
801049f6:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801049fc:	25 ff 01 00 00       	and    $0x1ff,%eax
80104a01:	89 c1                	mov    %eax,%ecx
80104a03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a06:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a09:	01 d0                	add    %edx,%eax
80104a0b:	0f b6 10             	movzbl (%eax),%edx
80104a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a11:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104a15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1c:	3b 45 10             	cmp    0x10(%ebp),%eax
80104a1f:	0f 8c 4e ff ff ff    	jl     80104973 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104a25:	8b 45 08             	mov    0x8(%ebp),%eax
80104a28:	05 34 02 00 00       	add    $0x234,%eax
80104a2d:	89 04 24             	mov    %eax,(%esp)
80104a30:	e8 38 0a 00 00       	call   8010546d <wakeup>
  release(&p->lock);
80104a35:	8b 45 08             	mov    0x8(%ebp),%eax
80104a38:	89 04 24             	mov    %eax,(%esp)
80104a3b:	e8 80 0c 00 00       	call   801056c0 <release>
  return n;
80104a40:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104a43:	c9                   	leave  
80104a44:	c3                   	ret    

80104a45 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104a45:	55                   	push   %ebp
80104a46:	89 e5                	mov    %esp,%ebp
80104a48:	53                   	push   %ebx
80104a49:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4f:	89 04 24             	mov    %eax,(%esp)
80104a52:	e8 07 0c 00 00       	call   8010565e <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104a57:	eb 3a                	jmp    80104a93 <piperead+0x4e>
    if(proc->killed){
80104a59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a5f:	8b 40 24             	mov    0x24(%eax),%eax
80104a62:	85 c0                	test   %eax,%eax
80104a64:	74 15                	je     80104a7b <piperead+0x36>
      release(&p->lock);
80104a66:	8b 45 08             	mov    0x8(%ebp),%eax
80104a69:	89 04 24             	mov    %eax,(%esp)
80104a6c:	e8 4f 0c 00 00       	call   801056c0 <release>
      return -1;
80104a71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a76:	e9 b5 00 00 00       	jmp    80104b30 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7e:	8b 55 08             	mov    0x8(%ebp),%edx
80104a81:	81 c2 34 02 00 00    	add    $0x234,%edx
80104a87:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a8b:	89 14 24             	mov    %edx,(%esp)
80104a8e:	e8 01 09 00 00       	call   80105394 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104a93:	8b 45 08             	mov    0x8(%ebp),%eax
80104a96:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a9f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104aa5:	39 c2                	cmp    %eax,%edx
80104aa7:	75 0d                	jne    80104ab6 <piperead+0x71>
80104aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80104aac:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104ab2:	85 c0                	test   %eax,%eax
80104ab4:	75 a3                	jne    80104a59 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104ab6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104abd:	eb 4b                	jmp    80104b0a <piperead+0xc5>
    if(p->nread == p->nwrite)
80104abf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80104acb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ad1:	39 c2                	cmp    %eax,%edx
80104ad3:	75 02                	jne    80104ad7 <piperead+0x92>
      break;
80104ad5:	eb 3b                	jmp    80104b12 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104ad7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ada:	8b 45 0c             	mov    0xc(%ebp),%eax
80104add:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae3:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104ae9:	8d 48 01             	lea    0x1(%eax),%ecx
80104aec:	8b 55 08             	mov    0x8(%ebp),%edx
80104aef:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104af5:	25 ff 01 00 00       	and    $0x1ff,%eax
80104afa:	89 c2                	mov    %eax,%edx
80104afc:	8b 45 08             	mov    0x8(%ebp),%eax
80104aff:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104b04:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104b06:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0d:	3b 45 10             	cmp    0x10(%ebp),%eax
80104b10:	7c ad                	jl     80104abf <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104b12:	8b 45 08             	mov    0x8(%ebp),%eax
80104b15:	05 38 02 00 00       	add    $0x238,%eax
80104b1a:	89 04 24             	mov    %eax,(%esp)
80104b1d:	e8 4b 09 00 00       	call   8010546d <wakeup>
  release(&p->lock);
80104b22:	8b 45 08             	mov    0x8(%ebp),%eax
80104b25:	89 04 24             	mov    %eax,(%esp)
80104b28:	e8 93 0b 00 00       	call   801056c0 <release>
  return i;
80104b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b30:	83 c4 24             	add    $0x24,%esp
80104b33:	5b                   	pop    %ebx
80104b34:	5d                   	pop    %ebp
80104b35:	c3                   	ret    

80104b36 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104b36:	55                   	push   %ebp
80104b37:	89 e5                	mov    %esp,%ebp
80104b39:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b3c:	9c                   	pushf  
80104b3d:	58                   	pop    %eax
80104b3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b41:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b44:	c9                   	leave  
80104b45:	c3                   	ret    

80104b46 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104b46:	55                   	push   %ebp
80104b47:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b49:	fb                   	sti    
}
80104b4a:	5d                   	pop    %ebp
80104b4b:	c3                   	ret    

80104b4c <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104b4c:	55                   	push   %ebp
80104b4d:	89 e5                	mov    %esp,%ebp
80104b4f:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104b52:	c7 44 24 04 81 91 10 	movl   $0x80109181,0x4(%esp)
80104b59:	80 
80104b5a:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80104b61:	e8 d7 0a 00 00       	call   8010563d <initlock>
}
80104b66:	c9                   	leave  
80104b67:	c3                   	ret    

80104b68 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104b68:	55                   	push   %ebp
80104b69:	89 e5                	mov    %esp,%ebp
80104b6b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104b6e:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80104b75:	e8 e4 0a 00 00       	call   8010565e <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b7a:	c7 45 f4 d4 55 11 80 	movl   $0x801155d4,-0xc(%ebp)
80104b81:	eb 50                	jmp    80104bd3 <allocproc+0x6b>
    if(p->state == UNUSED)
80104b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b86:	8b 40 0c             	mov    0xc(%eax),%eax
80104b89:	85 c0                	test   %eax,%eax
80104b8b:	75 42                	jne    80104bcf <allocproc+0x67>
      goto found;
80104b8d:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b91:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104b98:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104b9d:	8d 50 01             	lea    0x1(%eax),%edx
80104ba0:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ba9:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104bac:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80104bb3:	e8 08 0b 00 00       	call   801056c0 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104bb8:	e8 92 e7 ff ff       	call   8010334f <kalloc>
80104bbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bc0:	89 42 08             	mov    %eax,0x8(%edx)
80104bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc6:	8b 40 08             	mov    0x8(%eax),%eax
80104bc9:	85 c0                	test   %eax,%eax
80104bcb:	75 33                	jne    80104c00 <allocproc+0x98>
80104bcd:	eb 20                	jmp    80104bef <allocproc+0x87>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bcf:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104bd3:	81 7d f4 d4 74 11 80 	cmpl   $0x801174d4,-0xc(%ebp)
80104bda:	72 a7                	jb     80104b83 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104bdc:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80104be3:	e8 d8 0a 00 00       	call   801056c0 <release>
  return 0;
80104be8:	b8 00 00 00 00       	mov    $0x0,%eax
80104bed:	eb 76                	jmp    80104c65 <allocproc+0xfd>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104bf9:	b8 00 00 00 00       	mov    $0x0,%eax
80104bfe:	eb 65                	jmp    80104c65 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
80104c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c03:	8b 40 08             	mov    0x8(%eax),%eax
80104c06:	05 00 10 00 00       	add    $0x1000,%eax
80104c0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104c0e:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c15:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c18:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104c1b:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104c1f:	ba 1c 6d 10 80       	mov    $0x80106d1c,%edx
80104c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c27:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104c29:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c30:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c33:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c39:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c3c:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104c43:	00 
80104c44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104c4b:	00 
80104c4c:	89 04 24             	mov    %eax,(%esp)
80104c4f:	e8 5e 0c 00 00       	call   801058b2 <memset>
  p->context->eip = (uint)forkret;
80104c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c57:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c5a:	ba 54 53 10 80       	mov    $0x80105354,%edx
80104c5f:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104c65:	c9                   	leave  
80104c66:	c3                   	ret    

80104c67 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104c67:	55                   	push   %ebp
80104c68:	89 e5                	mov    %esp,%ebp
80104c6a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104c6d:	e8 f6 fe ff ff       	call   80104b68 <allocproc>
80104c72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c78:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
80104c7d:	e8 8e 37 00 00       	call   80108410 <setupkvm>
80104c82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c85:	89 42 04             	mov    %eax,0x4(%edx)
80104c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8b:	8b 40 04             	mov    0x4(%eax),%eax
80104c8e:	85 c0                	test   %eax,%eax
80104c90:	75 0c                	jne    80104c9e <userinit+0x37>
    panic("userinit: out of memory?");
80104c92:	c7 04 24 88 91 10 80 	movl   $0x80109188,(%esp)
80104c99:	e8 9c b8 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104c9e:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca6:	8b 40 04             	mov    0x4(%eax),%eax
80104ca9:	89 54 24 08          	mov    %edx,0x8(%esp)
80104cad:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
80104cb4:	80 
80104cb5:	89 04 24             	mov    %eax,(%esp)
80104cb8:	e8 ab 39 00 00       	call   80108668 <inituvm>
  p->sz = PGSIZE;
80104cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc9:	8b 40 18             	mov    0x18(%eax),%eax
80104ccc:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104cd3:	00 
80104cd4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104cdb:	00 
80104cdc:	89 04 24             	mov    %eax,(%esp)
80104cdf:	e8 ce 0b 00 00       	call   801058b2 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce7:	8b 40 18             	mov    0x18(%eax),%eax
80104cea:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf3:	8b 40 18             	mov    0x18(%eax),%eax
80104cf6:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cff:	8b 40 18             	mov    0x18(%eax),%eax
80104d02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d05:	8b 52 18             	mov    0x18(%edx),%edx
80104d08:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104d0c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d13:	8b 40 18             	mov    0x18(%eax),%eax
80104d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d19:	8b 52 18             	mov    0x18(%edx),%edx
80104d1c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104d20:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d27:	8b 40 18             	mov    0x18(%eax),%eax
80104d2a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d34:	8b 40 18             	mov    0x18(%eax),%eax
80104d37:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d41:	8b 40 18             	mov    0x18(%eax),%eax
80104d44:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80104d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4e:	83 c0 6c             	add    $0x6c,%eax
80104d51:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104d58:	00 
80104d59:	c7 44 24 04 a1 91 10 	movl   $0x801091a1,0x4(%esp)
80104d60:	80 
80104d61:	89 04 24             	mov    %eax,(%esp)
80104d64:	e8 69 0d 00 00       	call   80105ad2 <safestrcpy>
  p->cwd = namei("/");
80104d69:	c7 04 24 aa 91 10 80 	movl   $0x801091aa,(%esp)
80104d70:	e8 e5 db ff ff       	call   8010295a <namei>
80104d75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d78:	89 42 68             	mov    %eax,0x68(%edx)
  p->state = RUNNABLE;
80104d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104d85:	c9                   	leave  
80104d86:	c3                   	ret    

80104d87 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104d87:	55                   	push   %ebp
80104d88:	89 e5                	mov    %esp,%ebp
80104d8a:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104d8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d93:	8b 00                	mov    (%eax),%eax
80104d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104d98:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104d9c:	7e 34                	jle    80104dd2 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104d9e:	8b 55 08             	mov    0x8(%ebp),%edx
80104da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da4:	01 c2                	add    %eax,%edx
80104da6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dac:	8b 40 04             	mov    0x4(%eax),%eax
80104daf:	89 54 24 08          	mov    %edx,0x8(%esp)
80104db3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104db6:	89 54 24 04          	mov    %edx,0x4(%esp)
80104dba:	89 04 24             	mov    %eax,(%esp)
80104dbd:	e8 1c 3a 00 00       	call   801087de <allocuvm>
80104dc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104dc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104dc9:	75 41                	jne    80104e0c <growproc+0x85>
      return -1;
80104dcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd0:	eb 58                	jmp    80104e2a <growproc+0xa3>
  } else if(n < 0){
80104dd2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104dd6:	79 34                	jns    80104e0c <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104dd8:	8b 55 08             	mov    0x8(%ebp),%edx
80104ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dde:	01 c2                	add    %eax,%edx
80104de0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de6:	8b 40 04             	mov    0x4(%eax),%eax
80104de9:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ded:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104df0:	89 54 24 04          	mov    %edx,0x4(%esp)
80104df4:	89 04 24             	mov    %eax,(%esp)
80104df7:	e8 bc 3a 00 00       	call   801088b8 <deallocuvm>
80104dfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104dff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e03:	75 07                	jne    80104e0c <growproc+0x85>
      return -1;
80104e05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e0a:	eb 1e                	jmp    80104e2a <growproc+0xa3>
  }
  proc->sz = sz;
80104e0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e15:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104e17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e1d:	89 04 24             	mov    %eax,(%esp)
80104e20:	e8 dc 36 00 00       	call   80108501 <switchuvm>
  return 0;
80104e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e2a:	c9                   	leave  
80104e2b:	c3                   	ret    

80104e2c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104e2c:	55                   	push   %ebp
80104e2d:	89 e5                	mov    %esp,%ebp
80104e2f:	57                   	push   %edi
80104e30:	56                   	push   %esi
80104e31:	53                   	push   %ebx
80104e32:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104e35:	e8 2e fd ff ff       	call   80104b68 <allocproc>
80104e3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104e3d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104e41:	75 0a                	jne    80104e4d <fork+0x21>
    return -1;
80104e43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e48:	e9 52 01 00 00       	jmp    80104f9f <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104e4d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e53:	8b 10                	mov    (%eax),%edx
80104e55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e5b:	8b 40 04             	mov    0x4(%eax),%eax
80104e5e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e62:	89 04 24             	mov    %eax,(%esp)
80104e65:	e8 ea 3b 00 00       	call   80108a54 <copyuvm>
80104e6a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104e6d:	89 42 04             	mov    %eax,0x4(%edx)
80104e70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e73:	8b 40 04             	mov    0x4(%eax),%eax
80104e76:	85 c0                	test   %eax,%eax
80104e78:	75 2c                	jne    80104ea6 <fork+0x7a>
    kfree(np->kstack);
80104e7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e7d:	8b 40 08             	mov    0x8(%eax),%eax
80104e80:	89 04 24             	mov    %eax,(%esp)
80104e83:	e8 2e e4 ff ff       	call   801032b6 <kfree>
    np->kstack = 0;
80104e88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e8b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104e92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e95:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104e9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ea1:	e9 f9 00 00 00       	jmp    80104f9f <fork+0x173>
  }
  np->sz = proc->sz;
80104ea6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eac:	8b 10                	mov    (%eax),%edx
80104eae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104eb1:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104eb3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104eba:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ebd:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104ec0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ec3:	8b 50 18             	mov    0x18(%eax),%edx
80104ec6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ecc:	8b 40 18             	mov    0x18(%eax),%eax
80104ecf:	89 c3                	mov    %eax,%ebx
80104ed1:	b8 13 00 00 00       	mov    $0x13,%eax
80104ed6:	89 d7                	mov    %edx,%edi
80104ed8:	89 de                	mov    %ebx,%esi
80104eda:	89 c1                	mov    %eax,%ecx
80104edc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104ede:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ee1:	8b 40 18             	mov    0x18(%eax),%eax
80104ee4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104eeb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104ef2:	eb 3d                	jmp    80104f31 <fork+0x105>
    if(proc->ofile[i])
80104ef4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104efa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104efd:	83 c2 08             	add    $0x8,%edx
80104f00:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f04:	85 c0                	test   %eax,%eax
80104f06:	74 25                	je     80104f2d <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104f08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f0e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104f11:	83 c2 08             	add    $0x8,%edx
80104f14:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f18:	89 04 24             	mov    %eax,(%esp)
80104f1b:	e8 81 c0 ff ff       	call   80100fa1 <filedup>
80104f20:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104f23:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104f26:	83 c1 08             	add    $0x8,%ecx
80104f29:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104f2d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104f31:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104f35:	7e bd                	jle    80104ef4 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104f37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f3d:	8b 40 68             	mov    0x68(%eax),%eax
80104f40:	89 04 24             	mov    %eax,(%esp)
80104f43:	e8 9c cc ff ff       	call   80101be4 <idup>
80104f48:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104f4b:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104f4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f54:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f5a:	83 c0 6c             	add    $0x6c,%eax
80104f5d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104f64:	00 
80104f65:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f69:	89 04 24             	mov    %eax,(%esp)
80104f6c:	e8 61 0b 00 00       	call   80105ad2 <safestrcpy>
 
  pid = np->pid;
80104f71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f74:	8b 40 10             	mov    0x10(%eax),%eax
80104f77:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104f7a:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80104f81:	e8 d8 06 00 00       	call   8010565e <acquire>
  np->state = RUNNABLE;
80104f86:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f89:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104f90:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80104f97:	e8 24 07 00 00       	call   801056c0 <release>
  
  return pid;
80104f9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104f9f:	83 c4 2c             	add    $0x2c,%esp
80104fa2:	5b                   	pop    %ebx
80104fa3:	5e                   	pop    %esi
80104fa4:	5f                   	pop    %edi
80104fa5:	5d                   	pop    %ebp
80104fa6:	c3                   	ret    

80104fa7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104fa7:	55                   	push   %ebp
80104fa8:	89 e5                	mov    %esp,%ebp
80104faa:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104fad:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fb4:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104fb9:	39 c2                	cmp    %eax,%edx
80104fbb:	75 0c                	jne    80104fc9 <exit+0x22>
    panic("init exiting");
80104fbd:	c7 04 24 ac 91 10 80 	movl   $0x801091ac,(%esp)
80104fc4:	e8 71 b5 ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104fc9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104fd0:	eb 44                	jmp    80105016 <exit+0x6f>
    if(proc->ofile[fd]){
80104fd2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fdb:	83 c2 08             	add    $0x8,%edx
80104fde:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fe2:	85 c0                	test   %eax,%eax
80104fe4:	74 2c                	je     80105012 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104fe6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fec:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fef:	83 c2 08             	add    $0x8,%edx
80104ff2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ff6:	89 04 24             	mov    %eax,(%esp)
80104ff9:	e8 eb bf ff ff       	call   80100fe9 <fileclose>
      proc->ofile[fd] = 0;
80104ffe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105004:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105007:	83 c2 08             	add    $0x8,%edx
8010500a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105011:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105012:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105016:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010501a:	7e b6                	jle    80104fd2 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010501c:	e8 54 ec ff ff       	call   80103c75 <begin_op>
  iput(proc->cwd);
80105021:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105027:	8b 40 68             	mov    0x68(%eax),%eax
8010502a:	89 04 24             	mov    %eax,(%esp)
8010502d:	e8 07 ce ff ff       	call   80101e39 <iput>
  end_op();
80105032:	e8 c2 ec ff ff       	call   80103cf9 <end_op>
  proc->cwd = 0;
80105037:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010503d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80105044:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
8010504b:	e8 0e 06 00 00       	call   8010565e <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80105050:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105056:	8b 40 14             	mov    0x14(%eax),%eax
80105059:	89 04 24             	mov    %eax,(%esp)
8010505c:	e8 ce 03 00 00       	call   8010542f <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105061:	c7 45 f4 d4 55 11 80 	movl   $0x801155d4,-0xc(%ebp)
80105068:	eb 38                	jmp    801050a2 <exit+0xfb>
    if(p->parent == proc){
8010506a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010506d:	8b 50 14             	mov    0x14(%eax),%edx
80105070:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105076:	39 c2                	cmp    %eax,%edx
80105078:	75 24                	jne    8010509e <exit+0xf7>
      p->parent = initproc;
8010507a:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
80105080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105083:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105089:	8b 40 0c             	mov    0xc(%eax),%eax
8010508c:	83 f8 05             	cmp    $0x5,%eax
8010508f:	75 0d                	jne    8010509e <exit+0xf7>
        wakeup1(initproc);
80105091:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105096:	89 04 24             	mov    %eax,(%esp)
80105099:	e8 91 03 00 00       	call   8010542f <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010509e:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801050a2:	81 7d f4 d4 74 11 80 	cmpl   $0x801174d4,-0xc(%ebp)
801050a9:	72 bf                	jb     8010506a <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801050ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b1:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801050b8:	e8 b3 01 00 00       	call   80105270 <sched>
  panic("zombie exit");
801050bd:	c7 04 24 b9 91 10 80 	movl   $0x801091b9,(%esp)
801050c4:	e8 71 b4 ff ff       	call   8010053a <panic>

801050c9 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801050c9:	55                   	push   %ebp
801050ca:	89 e5                	mov    %esp,%ebp
801050cc:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801050cf:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
801050d6:	e8 83 05 00 00       	call   8010565e <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801050db:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050e2:	c7 45 f4 d4 55 11 80 	movl   $0x801155d4,-0xc(%ebp)
801050e9:	e9 9a 00 00 00       	jmp    80105188 <wait+0xbf>
      if(p->parent != proc)
801050ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f1:	8b 50 14             	mov    0x14(%eax),%edx
801050f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050fa:	39 c2                	cmp    %eax,%edx
801050fc:	74 05                	je     80105103 <wait+0x3a>
        continue;
801050fe:	e9 81 00 00 00       	jmp    80105184 <wait+0xbb>
      havekids = 1;
80105103:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010510a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510d:	8b 40 0c             	mov    0xc(%eax),%eax
80105110:	83 f8 05             	cmp    $0x5,%eax
80105113:	75 6f                	jne    80105184 <wait+0xbb>
        // Found one.
        pid = p->pid;
80105115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105118:	8b 40 10             	mov    0x10(%eax),%eax
8010511b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010511e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105121:	8b 40 08             	mov    0x8(%eax),%eax
80105124:	89 04 24             	mov    %eax,(%esp)
80105127:	e8 8a e1 ff ff       	call   801032b6 <kfree>
        p->kstack = 0;
8010512c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105139:	8b 40 04             	mov    0x4(%eax),%eax
8010513c:	89 04 24             	mov    %eax,(%esp)
8010513f:	e8 30 38 00 00       	call   80108974 <freevm>
        p->state = UNUSED;
80105144:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105147:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010514e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105151:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80105158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010515b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105165:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105173:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
8010517a:	e8 41 05 00 00       	call   801056c0 <release>
        return pid;
8010517f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105182:	eb 52                	jmp    801051d6 <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105184:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105188:	81 7d f4 d4 74 11 80 	cmpl   $0x801174d4,-0xc(%ebp)
8010518f:	0f 82 59 ff ff ff    	jb     801050ee <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105195:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105199:	74 0d                	je     801051a8 <wait+0xdf>
8010519b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051a1:	8b 40 24             	mov    0x24(%eax),%eax
801051a4:	85 c0                	test   %eax,%eax
801051a6:	74 13                	je     801051bb <wait+0xf2>
      release(&ptable.lock);
801051a8:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
801051af:	e8 0c 05 00 00       	call   801056c0 <release>
      return -1;
801051b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051b9:	eb 1b                	jmp    801051d6 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801051bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051c1:	c7 44 24 04 a0 55 11 	movl   $0x801155a0,0x4(%esp)
801051c8:	80 
801051c9:	89 04 24             	mov    %eax,(%esp)
801051cc:	e8 c3 01 00 00       	call   80105394 <sleep>
  }
801051d1:	e9 05 ff ff ff       	jmp    801050db <wait+0x12>
}
801051d6:	c9                   	leave  
801051d7:	c3                   	ret    

801051d8 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801051d8:	55                   	push   %ebp
801051d9:	89 e5                	mov    %esp,%ebp
801051db:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801051de:	e8 63 f9 ff ff       	call   80104b46 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801051e3:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
801051ea:	e8 6f 04 00 00       	call   8010565e <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051ef:	c7 45 f4 d4 55 11 80 	movl   $0x801155d4,-0xc(%ebp)
801051f6:	eb 5e                	jmp    80105256 <scheduler+0x7e>
      if(p->state != RUNNABLE)
801051f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fb:	8b 40 0c             	mov    0xc(%eax),%eax
801051fe:	83 f8 03             	cmp    $0x3,%eax
80105201:	74 02                	je     80105205 <scheduler+0x2d>
        continue;
80105203:	eb 4d                	jmp    80105252 <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105208:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
8010520e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105211:	89 04 24             	mov    %eax,(%esp)
80105214:	e8 e8 32 00 00       	call   80108501 <switchuvm>
      p->state = RUNNING;
80105219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105223:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105229:	8b 40 1c             	mov    0x1c(%eax),%eax
8010522c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105233:	83 c2 04             	add    $0x4,%edx
80105236:	89 44 24 04          	mov    %eax,0x4(%esp)
8010523a:	89 14 24             	mov    %edx,(%esp)
8010523d:	e8 01 09 00 00       	call   80105b43 <swtch>
      switchkvm();
80105242:	e8 9d 32 00 00       	call   801084e4 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105247:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010524e:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105252:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105256:	81 7d f4 d4 74 11 80 	cmpl   $0x801174d4,-0xc(%ebp)
8010525d:	72 99                	jb     801051f8 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
8010525f:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80105266:	e8 55 04 00 00       	call   801056c0 <release>

  }
8010526b:	e9 6e ff ff ff       	jmp    801051de <scheduler+0x6>

80105270 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105270:	55                   	push   %ebp
80105271:	89 e5                	mov    %esp,%ebp
80105273:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80105276:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
8010527d:	e8 06 05 00 00       	call   80105788 <holding>
80105282:	85 c0                	test   %eax,%eax
80105284:	75 0c                	jne    80105292 <sched+0x22>
    panic("sched ptable.lock");
80105286:	c7 04 24 c5 91 10 80 	movl   $0x801091c5,(%esp)
8010528d:	e8 a8 b2 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80105292:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105298:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010529e:	83 f8 01             	cmp    $0x1,%eax
801052a1:	74 0c                	je     801052af <sched+0x3f>
    panic("sched locks");
801052a3:	c7 04 24 d7 91 10 80 	movl   $0x801091d7,(%esp)
801052aa:	e8 8b b2 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
801052af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052b5:	8b 40 0c             	mov    0xc(%eax),%eax
801052b8:	83 f8 04             	cmp    $0x4,%eax
801052bb:	75 0c                	jne    801052c9 <sched+0x59>
    panic("sched running");
801052bd:	c7 04 24 e3 91 10 80 	movl   $0x801091e3,(%esp)
801052c4:	e8 71 b2 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
801052c9:	e8 68 f8 ff ff       	call   80104b36 <readeflags>
801052ce:	25 00 02 00 00       	and    $0x200,%eax
801052d3:	85 c0                	test   %eax,%eax
801052d5:	74 0c                	je     801052e3 <sched+0x73>
    panic("sched interruptible");
801052d7:	c7 04 24 f1 91 10 80 	movl   $0x801091f1,(%esp)
801052de:	e8 57 b2 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
801052e3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052e9:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801052f2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052f8:	8b 40 04             	mov    0x4(%eax),%eax
801052fb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105302:	83 c2 1c             	add    $0x1c,%edx
80105305:	89 44 24 04          	mov    %eax,0x4(%esp)
80105309:	89 14 24             	mov    %edx,(%esp)
8010530c:	e8 32 08 00 00       	call   80105b43 <swtch>
  cpu->intena = intena;
80105311:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105317:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010531a:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105320:	c9                   	leave  
80105321:	c3                   	ret    

80105322 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105322:	55                   	push   %ebp
80105323:	89 e5                	mov    %esp,%ebp
80105325:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105328:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
8010532f:	e8 2a 03 00 00       	call   8010565e <acquire>
  proc->state = RUNNABLE;
80105334:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010533a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105341:	e8 2a ff ff ff       	call   80105270 <sched>
  release(&ptable.lock);
80105346:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
8010534d:	e8 6e 03 00 00       	call   801056c0 <release>
}
80105352:	c9                   	leave  
80105353:	c3                   	ret    

80105354 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105354:	55                   	push   %ebp
80105355:	89 e5                	mov    %esp,%ebp
80105357:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010535a:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80105361:	e8 5a 03 00 00       	call   801056c0 <release>

  if (first) {
80105366:	a1 08 c0 10 80       	mov    0x8010c008,%eax
8010536b:	85 c0                	test   %eax,%eax
8010536d:	74 23                	je     80105392 <forkret+0x3e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010536f:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105376:	00 00 00 
    iinit(ROOTDEV);
80105379:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105380:	e8 04 c5 ff ff       	call   80101889 <iinit>
    initlog(get_boot_block());
80105385:	e8 37 d6 ff ff       	call   801029c1 <get_boot_block>
8010538a:	89 04 24             	mov    %eax,(%esp)
8010538d:	e8 dd e6 ff ff       	call   80103a6f <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105392:	c9                   	leave  
80105393:	c3                   	ret    

80105394 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105394:	55                   	push   %ebp
80105395:	89 e5                	mov    %esp,%ebp
80105397:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
8010539a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053a0:	85 c0                	test   %eax,%eax
801053a2:	75 0c                	jne    801053b0 <sleep+0x1c>
    panic("sleep");
801053a4:	c7 04 24 05 92 10 80 	movl   $0x80109205,(%esp)
801053ab:	e8 8a b1 ff ff       	call   8010053a <panic>

  if(lk == 0)
801053b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801053b4:	75 0c                	jne    801053c2 <sleep+0x2e>
    panic("sleep without lk");
801053b6:	c7 04 24 0b 92 10 80 	movl   $0x8010920b,(%esp)
801053bd:	e8 78 b1 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801053c2:	81 7d 0c a0 55 11 80 	cmpl   $0x801155a0,0xc(%ebp)
801053c9:	74 17                	je     801053e2 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801053cb:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
801053d2:	e8 87 02 00 00       	call   8010565e <acquire>
    release(lk);
801053d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053da:	89 04 24             	mov    %eax,(%esp)
801053dd:	e8 de 02 00 00       	call   801056c0 <release>
  }

  // Go to sleep.
  proc->chan = chan;
801053e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053e8:	8b 55 08             	mov    0x8(%ebp),%edx
801053eb:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801053ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053f4:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801053fb:	e8 70 fe ff ff       	call   80105270 <sched>

  // Tidy up.
  proc->chan = 0;
80105400:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105406:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010540d:	81 7d 0c a0 55 11 80 	cmpl   $0x801155a0,0xc(%ebp)
80105414:	74 17                	je     8010542d <sleep+0x99>
    release(&ptable.lock);
80105416:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
8010541d:	e8 9e 02 00 00       	call   801056c0 <release>
    acquire(lk);
80105422:	8b 45 0c             	mov    0xc(%ebp),%eax
80105425:	89 04 24             	mov    %eax,(%esp)
80105428:	e8 31 02 00 00       	call   8010565e <acquire>
  }
}
8010542d:	c9                   	leave  
8010542e:	c3                   	ret    

8010542f <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010542f:	55                   	push   %ebp
80105430:	89 e5                	mov    %esp,%ebp
80105432:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105435:	c7 45 fc d4 55 11 80 	movl   $0x801155d4,-0x4(%ebp)
8010543c:	eb 24                	jmp    80105462 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
8010543e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105441:	8b 40 0c             	mov    0xc(%eax),%eax
80105444:	83 f8 02             	cmp    $0x2,%eax
80105447:	75 15                	jne    8010545e <wakeup1+0x2f>
80105449:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010544c:	8b 40 20             	mov    0x20(%eax),%eax
8010544f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105452:	75 0a                	jne    8010545e <wakeup1+0x2f>
      p->state = RUNNABLE;
80105454:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105457:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010545e:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80105462:	81 7d fc d4 74 11 80 	cmpl   $0x801174d4,-0x4(%ebp)
80105469:	72 d3                	jb     8010543e <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010546b:	c9                   	leave  
8010546c:	c3                   	ret    

8010546d <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010546d:	55                   	push   %ebp
8010546e:	89 e5                	mov    %esp,%ebp
80105470:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80105473:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
8010547a:	e8 df 01 00 00       	call   8010565e <acquire>
  wakeup1(chan);
8010547f:	8b 45 08             	mov    0x8(%ebp),%eax
80105482:	89 04 24             	mov    %eax,(%esp)
80105485:	e8 a5 ff ff ff       	call   8010542f <wakeup1>
  release(&ptable.lock);
8010548a:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80105491:	e8 2a 02 00 00       	call   801056c0 <release>
}
80105496:	c9                   	leave  
80105497:	c3                   	ret    

80105498 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105498:	55                   	push   %ebp
80105499:	89 e5                	mov    %esp,%ebp
8010549b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010549e:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
801054a5:	e8 b4 01 00 00       	call   8010565e <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054aa:	c7 45 f4 d4 55 11 80 	movl   $0x801155d4,-0xc(%ebp)
801054b1:	eb 41                	jmp    801054f4 <kill+0x5c>
    if(p->pid == pid){
801054b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b6:	8b 40 10             	mov    0x10(%eax),%eax
801054b9:	3b 45 08             	cmp    0x8(%ebp),%eax
801054bc:	75 32                	jne    801054f0 <kill+0x58>
      p->killed = 1;
801054be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801054c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054cb:	8b 40 0c             	mov    0xc(%eax),%eax
801054ce:	83 f8 02             	cmp    $0x2,%eax
801054d1:	75 0a                	jne    801054dd <kill+0x45>
        p->state = RUNNABLE;
801054d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801054dd:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
801054e4:	e8 d7 01 00 00       	call   801056c0 <release>
      return 0;
801054e9:	b8 00 00 00 00       	mov    $0x0,%eax
801054ee:	eb 1e                	jmp    8010550e <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054f0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801054f4:	81 7d f4 d4 74 11 80 	cmpl   $0x801174d4,-0xc(%ebp)
801054fb:	72 b6                	jb     801054b3 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801054fd:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80105504:	e8 b7 01 00 00       	call   801056c0 <release>
  return -1;
80105509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010550e:	c9                   	leave  
8010550f:	c3                   	ret    

80105510 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105510:	55                   	push   %ebp
80105511:	89 e5                	mov    %esp,%ebp
80105513:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105516:	c7 45 f0 d4 55 11 80 	movl   $0x801155d4,-0x10(%ebp)
8010551d:	e9 d6 00 00 00       	jmp    801055f8 <procdump+0xe8>
    if(p->state == UNUSED)
80105522:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105525:	8b 40 0c             	mov    0xc(%eax),%eax
80105528:	85 c0                	test   %eax,%eax
8010552a:	75 05                	jne    80105531 <procdump+0x21>
      continue;
8010552c:	e9 c3 00 00 00       	jmp    801055f4 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105534:	8b 40 0c             	mov    0xc(%eax),%eax
80105537:	83 f8 05             	cmp    $0x5,%eax
8010553a:	77 23                	ja     8010555f <procdump+0x4f>
8010553c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010553f:	8b 40 0c             	mov    0xc(%eax),%eax
80105542:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105549:	85 c0                	test   %eax,%eax
8010554b:	74 12                	je     8010555f <procdump+0x4f>
      state = states[p->state];
8010554d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105550:	8b 40 0c             	mov    0xc(%eax),%eax
80105553:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010555a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010555d:	eb 07                	jmp    80105566 <procdump+0x56>
    else
      state = "???";
8010555f:	c7 45 ec 1c 92 10 80 	movl   $0x8010921c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105569:	8d 50 6c             	lea    0x6c(%eax),%edx
8010556c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010556f:	8b 40 10             	mov    0x10(%eax),%eax
80105572:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105576:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105579:	89 54 24 08          	mov    %edx,0x8(%esp)
8010557d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105581:	c7 04 24 20 92 10 80 	movl   $0x80109220,(%esp)
80105588:	e8 13 ae ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
8010558d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105590:	8b 40 0c             	mov    0xc(%eax),%eax
80105593:	83 f8 02             	cmp    $0x2,%eax
80105596:	75 50                	jne    801055e8 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010559b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010559e:	8b 40 0c             	mov    0xc(%eax),%eax
801055a1:	83 c0 08             	add    $0x8,%eax
801055a4:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801055a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801055ab:	89 04 24             	mov    %eax,(%esp)
801055ae:	e8 5c 01 00 00       	call   8010570f <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801055b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801055ba:	eb 1b                	jmp    801055d7 <procdump+0xc7>
        cprintf(" %p", pc[i]);
801055bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bf:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801055c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801055c7:	c7 04 24 29 92 10 80 	movl   $0x80109229,(%esp)
801055ce:	e8 cd ad ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801055d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801055d7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801055db:	7f 0b                	jg     801055e8 <procdump+0xd8>
801055dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801055e4:	85 c0                	test   %eax,%eax
801055e6:	75 d4                	jne    801055bc <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801055e8:	c7 04 24 2d 92 10 80 	movl   $0x8010922d,(%esp)
801055ef:	e8 ac ad ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055f4:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
801055f8:	81 7d f0 d4 74 11 80 	cmpl   $0x801174d4,-0x10(%ebp)
801055ff:	0f 82 1d ff ff ff    	jb     80105522 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105605:	c9                   	leave  
80105606:	c3                   	ret    

80105607 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105607:	55                   	push   %ebp
80105608:	89 e5                	mov    %esp,%ebp
8010560a:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010560d:	9c                   	pushf  
8010560e:	58                   	pop    %eax
8010560f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105612:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105615:	c9                   	leave  
80105616:	c3                   	ret    

80105617 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105617:	55                   	push   %ebp
80105618:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010561a:	fa                   	cli    
}
8010561b:	5d                   	pop    %ebp
8010561c:	c3                   	ret    

8010561d <sti>:

static inline void
sti(void)
{
8010561d:	55                   	push   %ebp
8010561e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105620:	fb                   	sti    
}
80105621:	5d                   	pop    %ebp
80105622:	c3                   	ret    

80105623 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105623:	55                   	push   %ebp
80105624:	89 e5                	mov    %esp,%ebp
80105626:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105629:	8b 55 08             	mov    0x8(%ebp),%edx
8010562c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105632:	f0 87 02             	lock xchg %eax,(%edx)
80105635:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105638:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010563b:	c9                   	leave  
8010563c:	c3                   	ret    

8010563d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010563d:	55                   	push   %ebp
8010563e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105640:	8b 45 08             	mov    0x8(%ebp),%eax
80105643:	8b 55 0c             	mov    0xc(%ebp),%edx
80105646:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105649:	8b 45 08             	mov    0x8(%ebp),%eax
8010564c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105652:	8b 45 08             	mov    0x8(%ebp),%eax
80105655:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010565c:	5d                   	pop    %ebp
8010565d:	c3                   	ret    

8010565e <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010565e:	55                   	push   %ebp
8010565f:	89 e5                	mov    %esp,%ebp
80105661:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105664:	e8 49 01 00 00       	call   801057b2 <pushcli>
  if(holding(lk))
80105669:	8b 45 08             	mov    0x8(%ebp),%eax
8010566c:	89 04 24             	mov    %eax,(%esp)
8010566f:	e8 14 01 00 00       	call   80105788 <holding>
80105674:	85 c0                	test   %eax,%eax
80105676:	74 0c                	je     80105684 <acquire+0x26>
    panic("acquire");
80105678:	c7 04 24 59 92 10 80 	movl   $0x80109259,(%esp)
8010567f:	e8 b6 ae ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105684:	90                   	nop
80105685:	8b 45 08             	mov    0x8(%ebp),%eax
80105688:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010568f:	00 
80105690:	89 04 24             	mov    %eax,(%esp)
80105693:	e8 8b ff ff ff       	call   80105623 <xchg>
80105698:	85 c0                	test   %eax,%eax
8010569a:	75 e9                	jne    80105685 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010569c:	8b 45 08             	mov    0x8(%ebp),%eax
8010569f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801056a6:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801056a9:	8b 45 08             	mov    0x8(%ebp),%eax
801056ac:	83 c0 0c             	add    $0xc,%eax
801056af:	89 44 24 04          	mov    %eax,0x4(%esp)
801056b3:	8d 45 08             	lea    0x8(%ebp),%eax
801056b6:	89 04 24             	mov    %eax,(%esp)
801056b9:	e8 51 00 00 00       	call   8010570f <getcallerpcs>
}
801056be:	c9                   	leave  
801056bf:	c3                   	ret    

801056c0 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801056c0:	55                   	push   %ebp
801056c1:	89 e5                	mov    %esp,%ebp
801056c3:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801056c6:	8b 45 08             	mov    0x8(%ebp),%eax
801056c9:	89 04 24             	mov    %eax,(%esp)
801056cc:	e8 b7 00 00 00       	call   80105788 <holding>
801056d1:	85 c0                	test   %eax,%eax
801056d3:	75 0c                	jne    801056e1 <release+0x21>
    panic("release");
801056d5:	c7 04 24 61 92 10 80 	movl   $0x80109261,(%esp)
801056dc:	e8 59 ae ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
801056e1:	8b 45 08             	mov    0x8(%ebp),%eax
801056e4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801056eb:	8b 45 08             	mov    0x8(%ebp),%eax
801056ee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801056f5:	8b 45 08             	mov    0x8(%ebp),%eax
801056f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056ff:	00 
80105700:	89 04 24             	mov    %eax,(%esp)
80105703:	e8 1b ff ff ff       	call   80105623 <xchg>

  popcli();
80105708:	e8 e9 00 00 00       	call   801057f6 <popcli>
}
8010570d:	c9                   	leave  
8010570e:	c3                   	ret    

8010570f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010570f:	55                   	push   %ebp
80105710:	89 e5                	mov    %esp,%ebp
80105712:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105715:	8b 45 08             	mov    0x8(%ebp),%eax
80105718:	83 e8 08             	sub    $0x8,%eax
8010571b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010571e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105725:	eb 38                	jmp    8010575f <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105727:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010572b:	74 38                	je     80105765 <getcallerpcs+0x56>
8010572d:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105734:	76 2f                	jbe    80105765 <getcallerpcs+0x56>
80105736:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010573a:	74 29                	je     80105765 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010573c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010573f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105746:	8b 45 0c             	mov    0xc(%ebp),%eax
80105749:	01 c2                	add    %eax,%edx
8010574b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010574e:	8b 40 04             	mov    0x4(%eax),%eax
80105751:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105753:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105756:	8b 00                	mov    (%eax),%eax
80105758:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010575b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010575f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105763:	7e c2                	jle    80105727 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105765:	eb 19                	jmp    80105780 <getcallerpcs+0x71>
    pcs[i] = 0;
80105767:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010576a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105771:	8b 45 0c             	mov    0xc(%ebp),%eax
80105774:	01 d0                	add    %edx,%eax
80105776:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010577c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105780:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105784:	7e e1                	jle    80105767 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105786:	c9                   	leave  
80105787:	c3                   	ret    

80105788 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105788:	55                   	push   %ebp
80105789:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010578b:	8b 45 08             	mov    0x8(%ebp),%eax
8010578e:	8b 00                	mov    (%eax),%eax
80105790:	85 c0                	test   %eax,%eax
80105792:	74 17                	je     801057ab <holding+0x23>
80105794:	8b 45 08             	mov    0x8(%ebp),%eax
80105797:	8b 50 08             	mov    0x8(%eax),%edx
8010579a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057a0:	39 c2                	cmp    %eax,%edx
801057a2:	75 07                	jne    801057ab <holding+0x23>
801057a4:	b8 01 00 00 00       	mov    $0x1,%eax
801057a9:	eb 05                	jmp    801057b0 <holding+0x28>
801057ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057b0:	5d                   	pop    %ebp
801057b1:	c3                   	ret    

801057b2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801057b2:	55                   	push   %ebp
801057b3:	89 e5                	mov    %esp,%ebp
801057b5:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801057b8:	e8 4a fe ff ff       	call   80105607 <readeflags>
801057bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801057c0:	e8 52 fe ff ff       	call   80105617 <cli>
  if(cpu->ncli++ == 0)
801057c5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801057cc:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801057d2:	8d 48 01             	lea    0x1(%eax),%ecx
801057d5:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801057db:	85 c0                	test   %eax,%eax
801057dd:	75 15                	jne    801057f4 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801057df:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057e8:	81 e2 00 02 00 00    	and    $0x200,%edx
801057ee:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801057f4:	c9                   	leave  
801057f5:	c3                   	ret    

801057f6 <popcli>:

void
popcli(void)
{
801057f6:	55                   	push   %ebp
801057f7:	89 e5                	mov    %esp,%ebp
801057f9:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801057fc:	e8 06 fe ff ff       	call   80105607 <readeflags>
80105801:	25 00 02 00 00       	and    $0x200,%eax
80105806:	85 c0                	test   %eax,%eax
80105808:	74 0c                	je     80105816 <popcli+0x20>
    panic("popcli - interruptible");
8010580a:	c7 04 24 69 92 10 80 	movl   $0x80109269,(%esp)
80105811:	e8 24 ad ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105816:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010581c:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105822:	83 ea 01             	sub    $0x1,%edx
80105825:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010582b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105831:	85 c0                	test   %eax,%eax
80105833:	79 0c                	jns    80105841 <popcli+0x4b>
    panic("popcli");
80105835:	c7 04 24 80 92 10 80 	movl   $0x80109280,(%esp)
8010583c:	e8 f9 ac ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105841:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105847:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010584d:	85 c0                	test   %eax,%eax
8010584f:	75 15                	jne    80105866 <popcli+0x70>
80105851:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105857:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010585d:	85 c0                	test   %eax,%eax
8010585f:	74 05                	je     80105866 <popcli+0x70>
    sti();
80105861:	e8 b7 fd ff ff       	call   8010561d <sti>
}
80105866:	c9                   	leave  
80105867:	c3                   	ret    

80105868 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105868:	55                   	push   %ebp
80105869:	89 e5                	mov    %esp,%ebp
8010586b:	57                   	push   %edi
8010586c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010586d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105870:	8b 55 10             	mov    0x10(%ebp),%edx
80105873:	8b 45 0c             	mov    0xc(%ebp),%eax
80105876:	89 cb                	mov    %ecx,%ebx
80105878:	89 df                	mov    %ebx,%edi
8010587a:	89 d1                	mov    %edx,%ecx
8010587c:	fc                   	cld    
8010587d:	f3 aa                	rep stos %al,%es:(%edi)
8010587f:	89 ca                	mov    %ecx,%edx
80105881:	89 fb                	mov    %edi,%ebx
80105883:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105886:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105889:	5b                   	pop    %ebx
8010588a:	5f                   	pop    %edi
8010588b:	5d                   	pop    %ebp
8010588c:	c3                   	ret    

8010588d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010588d:	55                   	push   %ebp
8010588e:	89 e5                	mov    %esp,%ebp
80105890:	57                   	push   %edi
80105891:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105892:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105895:	8b 55 10             	mov    0x10(%ebp),%edx
80105898:	8b 45 0c             	mov    0xc(%ebp),%eax
8010589b:	89 cb                	mov    %ecx,%ebx
8010589d:	89 df                	mov    %ebx,%edi
8010589f:	89 d1                	mov    %edx,%ecx
801058a1:	fc                   	cld    
801058a2:	f3 ab                	rep stos %eax,%es:(%edi)
801058a4:	89 ca                	mov    %ecx,%edx
801058a6:	89 fb                	mov    %edi,%ebx
801058a8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801058ab:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801058ae:	5b                   	pop    %ebx
801058af:	5f                   	pop    %edi
801058b0:	5d                   	pop    %ebp
801058b1:	c3                   	ret    

801058b2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801058b2:	55                   	push   %ebp
801058b3:	89 e5                	mov    %esp,%ebp
801058b5:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801058b8:	8b 45 08             	mov    0x8(%ebp),%eax
801058bb:	83 e0 03             	and    $0x3,%eax
801058be:	85 c0                	test   %eax,%eax
801058c0:	75 49                	jne    8010590b <memset+0x59>
801058c2:	8b 45 10             	mov    0x10(%ebp),%eax
801058c5:	83 e0 03             	and    $0x3,%eax
801058c8:	85 c0                	test   %eax,%eax
801058ca:	75 3f                	jne    8010590b <memset+0x59>
    c &= 0xFF;
801058cc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801058d3:	8b 45 10             	mov    0x10(%ebp),%eax
801058d6:	c1 e8 02             	shr    $0x2,%eax
801058d9:	89 c2                	mov    %eax,%edx
801058db:	8b 45 0c             	mov    0xc(%ebp),%eax
801058de:	c1 e0 18             	shl    $0x18,%eax
801058e1:	89 c1                	mov    %eax,%ecx
801058e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801058e6:	c1 e0 10             	shl    $0x10,%eax
801058e9:	09 c1                	or     %eax,%ecx
801058eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ee:	c1 e0 08             	shl    $0x8,%eax
801058f1:	09 c8                	or     %ecx,%eax
801058f3:	0b 45 0c             	or     0xc(%ebp),%eax
801058f6:	89 54 24 08          	mov    %edx,0x8(%esp)
801058fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801058fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105901:	89 04 24             	mov    %eax,(%esp)
80105904:	e8 84 ff ff ff       	call   8010588d <stosl>
80105909:	eb 19                	jmp    80105924 <memset+0x72>
  } else
    stosb(dst, c, n);
8010590b:	8b 45 10             	mov    0x10(%ebp),%eax
8010590e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105912:	8b 45 0c             	mov    0xc(%ebp),%eax
80105915:	89 44 24 04          	mov    %eax,0x4(%esp)
80105919:	8b 45 08             	mov    0x8(%ebp),%eax
8010591c:	89 04 24             	mov    %eax,(%esp)
8010591f:	e8 44 ff ff ff       	call   80105868 <stosb>
  return dst;
80105924:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105927:	c9                   	leave  
80105928:	c3                   	ret    

80105929 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105929:	55                   	push   %ebp
8010592a:	89 e5                	mov    %esp,%ebp
8010592c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010592f:	8b 45 08             	mov    0x8(%ebp),%eax
80105932:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105935:	8b 45 0c             	mov    0xc(%ebp),%eax
80105938:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010593b:	eb 30                	jmp    8010596d <memcmp+0x44>
    if(*s1 != *s2)
8010593d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105940:	0f b6 10             	movzbl (%eax),%edx
80105943:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105946:	0f b6 00             	movzbl (%eax),%eax
80105949:	38 c2                	cmp    %al,%dl
8010594b:	74 18                	je     80105965 <memcmp+0x3c>
      return *s1 - *s2;
8010594d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105950:	0f b6 00             	movzbl (%eax),%eax
80105953:	0f b6 d0             	movzbl %al,%edx
80105956:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105959:	0f b6 00             	movzbl (%eax),%eax
8010595c:	0f b6 c0             	movzbl %al,%eax
8010595f:	29 c2                	sub    %eax,%edx
80105961:	89 d0                	mov    %edx,%eax
80105963:	eb 1a                	jmp    8010597f <memcmp+0x56>
    s1++, s2++;
80105965:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105969:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010596d:	8b 45 10             	mov    0x10(%ebp),%eax
80105970:	8d 50 ff             	lea    -0x1(%eax),%edx
80105973:	89 55 10             	mov    %edx,0x10(%ebp)
80105976:	85 c0                	test   %eax,%eax
80105978:	75 c3                	jne    8010593d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010597a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010597f:	c9                   	leave  
80105980:	c3                   	ret    

80105981 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105981:	55                   	push   %ebp
80105982:	89 e5                	mov    %esp,%ebp
80105984:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105987:	8b 45 0c             	mov    0xc(%ebp),%eax
8010598a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010598d:	8b 45 08             	mov    0x8(%ebp),%eax
80105990:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105993:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105996:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105999:	73 3d                	jae    801059d8 <memmove+0x57>
8010599b:	8b 45 10             	mov    0x10(%ebp),%eax
8010599e:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059a1:	01 d0                	add    %edx,%eax
801059a3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801059a6:	76 30                	jbe    801059d8 <memmove+0x57>
    s += n;
801059a8:	8b 45 10             	mov    0x10(%ebp),%eax
801059ab:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801059ae:	8b 45 10             	mov    0x10(%ebp),%eax
801059b1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801059b4:	eb 13                	jmp    801059c9 <memmove+0x48>
      *--d = *--s;
801059b6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801059ba:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801059be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059c1:	0f b6 10             	movzbl (%eax),%edx
801059c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801059c7:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801059c9:	8b 45 10             	mov    0x10(%ebp),%eax
801059cc:	8d 50 ff             	lea    -0x1(%eax),%edx
801059cf:	89 55 10             	mov    %edx,0x10(%ebp)
801059d2:	85 c0                	test   %eax,%eax
801059d4:	75 e0                	jne    801059b6 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801059d6:	eb 26                	jmp    801059fe <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801059d8:	eb 17                	jmp    801059f1 <memmove+0x70>
      *d++ = *s++;
801059da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801059dd:	8d 50 01             	lea    0x1(%eax),%edx
801059e0:	89 55 f8             	mov    %edx,-0x8(%ebp)
801059e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059e6:	8d 4a 01             	lea    0x1(%edx),%ecx
801059e9:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801059ec:	0f b6 12             	movzbl (%edx),%edx
801059ef:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801059f1:	8b 45 10             	mov    0x10(%ebp),%eax
801059f4:	8d 50 ff             	lea    -0x1(%eax),%edx
801059f7:	89 55 10             	mov    %edx,0x10(%ebp)
801059fa:	85 c0                	test   %eax,%eax
801059fc:	75 dc                	jne    801059da <memmove+0x59>
      *d++ = *s++;

  return dst;
801059fe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105a01:	c9                   	leave  
80105a02:	c3                   	ret    

80105a03 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105a03:	55                   	push   %ebp
80105a04:	89 e5                	mov    %esp,%ebp
80105a06:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105a09:	8b 45 10             	mov    0x10(%ebp),%eax
80105a0c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a10:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a13:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a17:	8b 45 08             	mov    0x8(%ebp),%eax
80105a1a:	89 04 24             	mov    %eax,(%esp)
80105a1d:	e8 5f ff ff ff       	call   80105981 <memmove>
}
80105a22:	c9                   	leave  
80105a23:	c3                   	ret    

80105a24 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105a24:	55                   	push   %ebp
80105a25:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105a27:	eb 0c                	jmp    80105a35 <strncmp+0x11>
    n--, p++, q++;
80105a29:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105a2d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105a31:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105a35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a39:	74 1a                	je     80105a55 <strncmp+0x31>
80105a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80105a3e:	0f b6 00             	movzbl (%eax),%eax
80105a41:	84 c0                	test   %al,%al
80105a43:	74 10                	je     80105a55 <strncmp+0x31>
80105a45:	8b 45 08             	mov    0x8(%ebp),%eax
80105a48:	0f b6 10             	movzbl (%eax),%edx
80105a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a4e:	0f b6 00             	movzbl (%eax),%eax
80105a51:	38 c2                	cmp    %al,%dl
80105a53:	74 d4                	je     80105a29 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105a55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a59:	75 07                	jne    80105a62 <strncmp+0x3e>
    return 0;
80105a5b:	b8 00 00 00 00       	mov    $0x0,%eax
80105a60:	eb 16                	jmp    80105a78 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105a62:	8b 45 08             	mov    0x8(%ebp),%eax
80105a65:	0f b6 00             	movzbl (%eax),%eax
80105a68:	0f b6 d0             	movzbl %al,%edx
80105a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a6e:	0f b6 00             	movzbl (%eax),%eax
80105a71:	0f b6 c0             	movzbl %al,%eax
80105a74:	29 c2                	sub    %eax,%edx
80105a76:	89 d0                	mov    %edx,%eax
}
80105a78:	5d                   	pop    %ebp
80105a79:	c3                   	ret    

80105a7a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105a7a:	55                   	push   %ebp
80105a7b:	89 e5                	mov    %esp,%ebp
80105a7d:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105a80:	8b 45 08             	mov    0x8(%ebp),%eax
80105a83:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105a86:	90                   	nop
80105a87:	8b 45 10             	mov    0x10(%ebp),%eax
80105a8a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a8d:	89 55 10             	mov    %edx,0x10(%ebp)
80105a90:	85 c0                	test   %eax,%eax
80105a92:	7e 1e                	jle    80105ab2 <strncpy+0x38>
80105a94:	8b 45 08             	mov    0x8(%ebp),%eax
80105a97:	8d 50 01             	lea    0x1(%eax),%edx
80105a9a:	89 55 08             	mov    %edx,0x8(%ebp)
80105a9d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105aa0:	8d 4a 01             	lea    0x1(%edx),%ecx
80105aa3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105aa6:	0f b6 12             	movzbl (%edx),%edx
80105aa9:	88 10                	mov    %dl,(%eax)
80105aab:	0f b6 00             	movzbl (%eax),%eax
80105aae:	84 c0                	test   %al,%al
80105ab0:	75 d5                	jne    80105a87 <strncpy+0xd>
    ;
  while(n-- > 0)
80105ab2:	eb 0c                	jmp    80105ac0 <strncpy+0x46>
    *s++ = 0;
80105ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab7:	8d 50 01             	lea    0x1(%eax),%edx
80105aba:	89 55 08             	mov    %edx,0x8(%ebp)
80105abd:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105ac0:	8b 45 10             	mov    0x10(%ebp),%eax
80105ac3:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ac6:	89 55 10             	mov    %edx,0x10(%ebp)
80105ac9:	85 c0                	test   %eax,%eax
80105acb:	7f e7                	jg     80105ab4 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105acd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ad0:	c9                   	leave  
80105ad1:	c3                   	ret    

80105ad2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105ad2:	55                   	push   %ebp
80105ad3:	89 e5                	mov    %esp,%ebp
80105ad5:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80105adb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105ade:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ae2:	7f 05                	jg     80105ae9 <safestrcpy+0x17>
    return os;
80105ae4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ae7:	eb 31                	jmp    80105b1a <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105ae9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105aed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105af1:	7e 1e                	jle    80105b11 <safestrcpy+0x3f>
80105af3:	8b 45 08             	mov    0x8(%ebp),%eax
80105af6:	8d 50 01             	lea    0x1(%eax),%edx
80105af9:	89 55 08             	mov    %edx,0x8(%ebp)
80105afc:	8b 55 0c             	mov    0xc(%ebp),%edx
80105aff:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b02:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105b05:	0f b6 12             	movzbl (%edx),%edx
80105b08:	88 10                	mov    %dl,(%eax)
80105b0a:	0f b6 00             	movzbl (%eax),%eax
80105b0d:	84 c0                	test   %al,%al
80105b0f:	75 d8                	jne    80105ae9 <safestrcpy+0x17>
    ;
  *s = 0;
80105b11:	8b 45 08             	mov    0x8(%ebp),%eax
80105b14:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105b17:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b1a:	c9                   	leave  
80105b1b:	c3                   	ret    

80105b1c <strlen>:

int
strlen(const char *s)
{
80105b1c:	55                   	push   %ebp
80105b1d:	89 e5                	mov    %esp,%ebp
80105b1f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105b22:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105b29:	eb 04                	jmp    80105b2f <strlen+0x13>
80105b2b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105b2f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b32:	8b 45 08             	mov    0x8(%ebp),%eax
80105b35:	01 d0                	add    %edx,%eax
80105b37:	0f b6 00             	movzbl (%eax),%eax
80105b3a:	84 c0                	test   %al,%al
80105b3c:	75 ed                	jne    80105b2b <strlen+0xf>
    ;
  return n;
80105b3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b41:	c9                   	leave  
80105b42:	c3                   	ret    

80105b43 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105b43:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105b47:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105b4b:	55                   	push   %ebp
  pushl %ebx
80105b4c:	53                   	push   %ebx
  pushl %esi
80105b4d:	56                   	push   %esi
  pushl %edi
80105b4e:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105b4f:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105b51:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105b53:	5f                   	pop    %edi
  popl %esi
80105b54:	5e                   	pop    %esi
  popl %ebx
80105b55:	5b                   	pop    %ebx
  popl %ebp
80105b56:	5d                   	pop    %ebp
  ret
80105b57:	c3                   	ret    

80105b58 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105b58:	55                   	push   %ebp
80105b59:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105b5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b61:	8b 00                	mov    (%eax),%eax
80105b63:	3b 45 08             	cmp    0x8(%ebp),%eax
80105b66:	76 12                	jbe    80105b7a <fetchint+0x22>
80105b68:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6b:	8d 50 04             	lea    0x4(%eax),%edx
80105b6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b74:	8b 00                	mov    (%eax),%eax
80105b76:	39 c2                	cmp    %eax,%edx
80105b78:	76 07                	jbe    80105b81 <fetchint+0x29>
    return -1;
80105b7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7f:	eb 0f                	jmp    80105b90 <fetchint+0x38>
  *ip = *(int*)(addr);
80105b81:	8b 45 08             	mov    0x8(%ebp),%eax
80105b84:	8b 10                	mov    (%eax),%edx
80105b86:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b89:	89 10                	mov    %edx,(%eax)
  return 0;
80105b8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b90:	5d                   	pop    %ebp
80105b91:	c3                   	ret    

80105b92 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105b92:	55                   	push   %ebp
80105b93:	89 e5                	mov    %esp,%ebp
80105b95:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105b98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b9e:	8b 00                	mov    (%eax),%eax
80105ba0:	3b 45 08             	cmp    0x8(%ebp),%eax
80105ba3:	77 07                	ja     80105bac <fetchstr+0x1a>
    return -1;
80105ba5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105baa:	eb 46                	jmp    80105bf2 <fetchstr+0x60>
  *pp = (char*)addr;
80105bac:	8b 55 08             	mov    0x8(%ebp),%edx
80105baf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bb2:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105bb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bba:	8b 00                	mov    (%eax),%eax
80105bbc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bc2:	8b 00                	mov    (%eax),%eax
80105bc4:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105bc7:	eb 1c                	jmp    80105be5 <fetchstr+0x53>
    if(*s == 0)
80105bc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105bcc:	0f b6 00             	movzbl (%eax),%eax
80105bcf:	84 c0                	test   %al,%al
80105bd1:	75 0e                	jne    80105be1 <fetchstr+0x4f>
      return s - *pp;
80105bd3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bd9:	8b 00                	mov    (%eax),%eax
80105bdb:	29 c2                	sub    %eax,%edx
80105bdd:	89 d0                	mov    %edx,%eax
80105bdf:	eb 11                	jmp    80105bf2 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105be1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105be5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105be8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105beb:	72 dc                	jb     80105bc9 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105bed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bf2:	c9                   	leave  
80105bf3:	c3                   	ret    

80105bf4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105bf4:	55                   	push   %ebp
80105bf5:	89 e5                	mov    %esp,%ebp
80105bf7:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105bfa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c00:	8b 40 18             	mov    0x18(%eax),%eax
80105c03:	8b 50 44             	mov    0x44(%eax),%edx
80105c06:	8b 45 08             	mov    0x8(%ebp),%eax
80105c09:	c1 e0 02             	shl    $0x2,%eax
80105c0c:	01 d0                	add    %edx,%eax
80105c0e:	8d 50 04             	lea    0x4(%eax),%edx
80105c11:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c14:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c18:	89 14 24             	mov    %edx,(%esp)
80105c1b:	e8 38 ff ff ff       	call   80105b58 <fetchint>
}
80105c20:	c9                   	leave  
80105c21:	c3                   	ret    

80105c22 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105c22:	55                   	push   %ebp
80105c23:	89 e5                	mov    %esp,%ebp
80105c25:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105c28:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105c2b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c32:	89 04 24             	mov    %eax,(%esp)
80105c35:	e8 ba ff ff ff       	call   80105bf4 <argint>
80105c3a:	85 c0                	test   %eax,%eax
80105c3c:	79 07                	jns    80105c45 <argptr+0x23>
    return -1;
80105c3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c43:	eb 3d                	jmp    80105c82 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105c45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c48:	89 c2                	mov    %eax,%edx
80105c4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c50:	8b 00                	mov    (%eax),%eax
80105c52:	39 c2                	cmp    %eax,%edx
80105c54:	73 16                	jae    80105c6c <argptr+0x4a>
80105c56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c59:	89 c2                	mov    %eax,%edx
80105c5b:	8b 45 10             	mov    0x10(%ebp),%eax
80105c5e:	01 c2                	add    %eax,%edx
80105c60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c66:	8b 00                	mov    (%eax),%eax
80105c68:	39 c2                	cmp    %eax,%edx
80105c6a:	76 07                	jbe    80105c73 <argptr+0x51>
    return -1;
80105c6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c71:	eb 0f                	jmp    80105c82 <argptr+0x60>
  *pp = (char*)i;
80105c73:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c76:	89 c2                	mov    %eax,%edx
80105c78:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c7b:	89 10                	mov    %edx,(%eax)
  return 0;
80105c7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c82:	c9                   	leave  
80105c83:	c3                   	ret    

80105c84 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105c84:	55                   	push   %ebp
80105c85:	89 e5                	mov    %esp,%ebp
80105c87:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105c8a:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c91:	8b 45 08             	mov    0x8(%ebp),%eax
80105c94:	89 04 24             	mov    %eax,(%esp)
80105c97:	e8 58 ff ff ff       	call   80105bf4 <argint>
80105c9c:	85 c0                	test   %eax,%eax
80105c9e:	79 07                	jns    80105ca7 <argstr+0x23>
    return -1;
80105ca0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca5:	eb 12                	jmp    80105cb9 <argstr+0x35>
  return fetchstr(addr, pp);
80105ca7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105caa:	8b 55 0c             	mov    0xc(%ebp),%edx
80105cad:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cb1:	89 04 24             	mov    %eax,(%esp)
80105cb4:	e8 d9 fe ff ff       	call   80105b92 <fetchstr>
}
80105cb9:	c9                   	leave  
80105cba:	c3                   	ret    

80105cbb <syscall>:
[SYS_mount]   sys_mount,
};

void
syscall(void)
{
80105cbb:	55                   	push   %ebp
80105cbc:	89 e5                	mov    %esp,%ebp
80105cbe:	53                   	push   %ebx
80105cbf:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105cc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105cc8:	8b 40 18             	mov    0x18(%eax),%eax
80105ccb:	8b 40 1c             	mov    0x1c(%eax),%eax
80105cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105cd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cd5:	7e 30                	jle    80105d07 <syscall+0x4c>
80105cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cda:	83 f8 16             	cmp    $0x16,%eax
80105cdd:	77 28                	ja     80105d07 <syscall+0x4c>
80105cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce2:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105ce9:	85 c0                	test   %eax,%eax
80105ceb:	74 1a                	je     80105d07 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105ced:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105cf3:	8b 58 18             	mov    0x18(%eax),%ebx
80105cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf9:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105d00:	ff d0                	call   *%eax
80105d02:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105d05:	eb 3d                	jmp    80105d44 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105d07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d0d:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105d10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105d16:	8b 40 10             	mov    0x10(%eax),%eax
80105d19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105d20:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d24:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d28:	c7 04 24 87 92 10 80 	movl   $0x80109287,(%esp)
80105d2f:	e8 6c a6 ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105d34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d3a:	8b 40 18             	mov    0x18(%eax),%eax
80105d3d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105d44:	83 c4 24             	add    $0x24,%esp
80105d47:	5b                   	pop    %ebx
80105d48:	5d                   	pop    %ebp
80105d49:	c3                   	ret    

80105d4a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105d4a:	55                   	push   %ebp
80105d4b:	89 e5                	mov    %esp,%ebp
80105d4d:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105d50:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d53:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d57:	8b 45 08             	mov    0x8(%ebp),%eax
80105d5a:	89 04 24             	mov    %eax,(%esp)
80105d5d:	e8 92 fe ff ff       	call   80105bf4 <argint>
80105d62:	85 c0                	test   %eax,%eax
80105d64:	79 07                	jns    80105d6d <argfd+0x23>
    return -1;
80105d66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6b:	eb 50                	jmp    80105dbd <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d70:	85 c0                	test   %eax,%eax
80105d72:	78 21                	js     80105d95 <argfd+0x4b>
80105d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d77:	83 f8 0f             	cmp    $0xf,%eax
80105d7a:	7f 19                	jg     80105d95 <argfd+0x4b>
80105d7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d82:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d85:	83 c2 08             	add    $0x8,%edx
80105d88:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105d8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d93:	75 07                	jne    80105d9c <argfd+0x52>
    return -1;
80105d95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9a:	eb 21                	jmp    80105dbd <argfd+0x73>
  if(pfd)
80105d9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105da0:	74 08                	je     80105daa <argfd+0x60>
    *pfd = fd;
80105da2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105da5:	8b 45 0c             	mov    0xc(%ebp),%eax
80105da8:	89 10                	mov    %edx,(%eax)
  if(pf)
80105daa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105dae:	74 08                	je     80105db8 <argfd+0x6e>
    *pf = f;
80105db0:	8b 45 10             	mov    0x10(%ebp),%eax
80105db3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105db6:	89 10                	mov    %edx,(%eax)
  return 0;
80105db8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dbd:	c9                   	leave  
80105dbe:	c3                   	ret    

80105dbf <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105dbf:	55                   	push   %ebp
80105dc0:	89 e5                	mov    %esp,%ebp
80105dc2:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105dc5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105dcc:	eb 30                	jmp    80105dfe <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105dce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dd4:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105dd7:	83 c2 08             	add    $0x8,%edx
80105dda:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105dde:	85 c0                	test   %eax,%eax
80105de0:	75 18                	jne    80105dfa <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105de2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105de8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105deb:	8d 4a 08             	lea    0x8(%edx),%ecx
80105dee:	8b 55 08             	mov    0x8(%ebp),%edx
80105df1:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105df5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105df8:	eb 0f                	jmp    80105e09 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105dfa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105dfe:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105e02:	7e ca                	jle    80105dce <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105e04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e09:	c9                   	leave  
80105e0a:	c3                   	ret    

80105e0b <sys_dup>:

int
sys_dup(void)
{
80105e0b:	55                   	push   %ebp
80105e0c:	89 e5                	mov    %esp,%ebp
80105e0e:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105e11:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e14:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e1f:	00 
80105e20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e27:	e8 1e ff ff ff       	call   80105d4a <argfd>
80105e2c:	85 c0                	test   %eax,%eax
80105e2e:	79 07                	jns    80105e37 <sys_dup+0x2c>
    return -1;
80105e30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e35:	eb 29                	jmp    80105e60 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3a:	89 04 24             	mov    %eax,(%esp)
80105e3d:	e8 7d ff ff ff       	call   80105dbf <fdalloc>
80105e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e49:	79 07                	jns    80105e52 <sys_dup+0x47>
    return -1;
80105e4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e50:	eb 0e                	jmp    80105e60 <sys_dup+0x55>
  filedup(f);
80105e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e55:	89 04 24             	mov    %eax,(%esp)
80105e58:	e8 44 b1 ff ff       	call   80100fa1 <filedup>
  return fd;
80105e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e60:	c9                   	leave  
80105e61:	c3                   	ret    

80105e62 <sys_read>:

int
sys_read(void)
{
80105e62:	55                   	push   %ebp
80105e63:	89 e5                	mov    %esp,%ebp
80105e65:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105e68:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e6b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e76:	00 
80105e77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e7e:	e8 c7 fe ff ff       	call   80105d4a <argfd>
80105e83:	85 c0                	test   %eax,%eax
80105e85:	78 35                	js     80105ebc <sys_read+0x5a>
80105e87:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e8e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105e95:	e8 5a fd ff ff       	call   80105bf4 <argint>
80105e9a:	85 c0                	test   %eax,%eax
80105e9c:	78 1e                	js     80105ebc <sys_read+0x5a>
80105e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ea5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105eb3:	e8 6a fd ff ff       	call   80105c22 <argptr>
80105eb8:	85 c0                	test   %eax,%eax
80105eba:	79 07                	jns    80105ec3 <sys_read+0x61>
    return -1;
80105ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec1:	eb 19                	jmp    80105edc <sys_read+0x7a>
  return fileread(f, p, n);
80105ec3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ec6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ed0:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ed4:	89 04 24             	mov    %eax,(%esp)
80105ed7:	e8 32 b2 ff ff       	call   8010110e <fileread>
}
80105edc:	c9                   	leave  
80105edd:	c3                   	ret    

80105ede <sys_write>:

int
sys_write(void)
{
80105ede:	55                   	push   %ebp
80105edf:	89 e5                	mov    %esp,%ebp
80105ee1:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105ee4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ee7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105eeb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ef2:	00 
80105ef3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105efa:	e8 4b fe ff ff       	call   80105d4a <argfd>
80105eff:	85 c0                	test   %eax,%eax
80105f01:	78 35                	js     80105f38 <sys_write+0x5a>
80105f03:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f06:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f0a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105f11:	e8 de fc ff ff       	call   80105bf4 <argint>
80105f16:	85 c0                	test   %eax,%eax
80105f18:	78 1e                	js     80105f38 <sys_write+0x5a>
80105f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f21:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f24:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f2f:	e8 ee fc ff ff       	call   80105c22 <argptr>
80105f34:	85 c0                	test   %eax,%eax
80105f36:	79 07                	jns    80105f3f <sys_write+0x61>
    return -1;
80105f38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f3d:	eb 19                	jmp    80105f58 <sys_write+0x7a>
  return filewrite(f, p, n);
80105f3f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105f42:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105f4c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f50:	89 04 24             	mov    %eax,(%esp)
80105f53:	e8 72 b2 ff ff       	call   801011ca <filewrite>
}
80105f58:	c9                   	leave  
80105f59:	c3                   	ret    

80105f5a <sys_close>:

int
sys_close(void)
{
80105f5a:	55                   	push   %ebp
80105f5b:	89 e5                	mov    %esp,%ebp
80105f5d:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105f60:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f63:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f75:	e8 d0 fd ff ff       	call   80105d4a <argfd>
80105f7a:	85 c0                	test   %eax,%eax
80105f7c:	79 07                	jns    80105f85 <sys_close+0x2b>
    return -1;
80105f7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f83:	eb 24                	jmp    80105fa9 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105f85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f8e:	83 c2 08             	add    $0x8,%edx
80105f91:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f98:	00 
  fileclose(f);
80105f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9c:	89 04 24             	mov    %eax,(%esp)
80105f9f:	e8 45 b0 ff ff       	call   80100fe9 <fileclose>
  return 0;
80105fa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fa9:	c9                   	leave  
80105faa:	c3                   	ret    

80105fab <sys_fstat>:

int
sys_fstat(void)
{
80105fab:	55                   	push   %ebp
80105fac:	89 e5                	mov    %esp,%ebp
80105fae:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fb4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105fbf:	00 
80105fc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fc7:	e8 7e fd ff ff       	call   80105d4a <argfd>
80105fcc:	85 c0                	test   %eax,%eax
80105fce:	78 1f                	js     80105fef <sys_fstat+0x44>
80105fd0:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80105fd7:	00 
80105fd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fdf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105fe6:	e8 37 fc ff ff       	call   80105c22 <argptr>
80105feb:	85 c0                	test   %eax,%eax
80105fed:	79 07                	jns    80105ff6 <sys_fstat+0x4b>
    return -1;
80105fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff4:	eb 12                	jmp    80106008 <sys_fstat+0x5d>
  return filestat(f, st);
80105ff6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffc:	89 54 24 04          	mov    %edx,0x4(%esp)
80106000:	89 04 24             	mov    %eax,(%esp)
80106003:	e8 b7 b0 ff ff       	call   801010bf <filestat>
}
80106008:	c9                   	leave  
80106009:	c3                   	ret    

8010600a <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010600a:	55                   	push   %ebp
8010600b:	89 e5                	mov    %esp,%ebp
8010600d:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106010:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106013:	89 44 24 04          	mov    %eax,0x4(%esp)
80106017:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010601e:	e8 61 fc ff ff       	call   80105c84 <argstr>
80106023:	85 c0                	test   %eax,%eax
80106025:	78 17                	js     8010603e <sys_link+0x34>
80106027:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010602a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010602e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106035:	e8 4a fc ff ff       	call   80105c84 <argstr>
8010603a:	85 c0                	test   %eax,%eax
8010603c:	79 0a                	jns    80106048 <sys_link+0x3e>
    return -1;
8010603e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106043:	e9 43 01 00 00       	jmp    8010618b <sys_link+0x181>

  begin_op();
80106048:	e8 28 dc ff ff       	call   80103c75 <begin_op>
  if((ip = namei(old)) == 0){
8010604d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106050:	89 04 24             	mov    %eax,(%esp)
80106053:	e8 02 c9 ff ff       	call   8010295a <namei>
80106058:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010605b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010605f:	75 0f                	jne    80106070 <sys_link+0x66>
    end_op();
80106061:	e8 93 dc ff ff       	call   80103cf9 <end_op>
    return -1;
80106066:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606b:	e9 1b 01 00 00       	jmp    8010618b <sys_link+0x181>
  }

  ilock(ip);
80106070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106073:	89 04 24             	mov    %eax,(%esp)
80106076:	e8 9b bb ff ff       	call   80101c16 <ilock>
  if(ip->type == T_DIR){
8010607b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607e:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
80106082:	66 83 f8 01          	cmp    $0x1,%ax
80106086:	75 1a                	jne    801060a2 <sys_link+0x98>
    iunlockput(ip);
80106088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608b:	89 04 24             	mov    %eax,(%esp)
8010608e:	e8 77 be ff ff       	call   80101f0a <iunlockput>
    end_op();
80106093:	e8 61 dc ff ff       	call   80103cf9 <end_op>
    return -1;
80106098:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609d:	e9 e9 00 00 00       	jmp    8010618b <sys_link+0x181>
  }

  ip->nlink++;
801060a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a5:	0f b7 40 22          	movzwl 0x22(%eax),%eax
801060a9:	8d 50 01             	lea    0x1(%eax),%edx
801060ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060af:	66 89 50 22          	mov    %dx,0x22(%eax)
  iupdate(ip);
801060b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b6:	89 04 24             	mov    %eax,(%esp)
801060b9:	e8 78 b9 ff ff       	call   80101a36 <iupdate>
  iunlock(ip);
801060be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c1:	89 04 24             	mov    %eax,(%esp)
801060c4:	e8 0b bd ff ff       	call   80101dd4 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801060c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801060cc:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801060cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801060d3:	89 04 24             	mov    %eax,(%esp)
801060d6:	e8 a7 c8 ff ff       	call   80102982 <nameiparent>
801060db:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060e2:	75 02                	jne    801060e6 <sys_link+0xdc>
    goto bad;
801060e4:	eb 69                	jmp    8010614f <sys_link+0x145>
  ilock(dp);
801060e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e9:	89 04 24             	mov    %eax,(%esp)
801060ec:	e8 25 bb ff ff       	call   80101c16 <ilock>
  if(dp->prt != ip->prt || dirlink(dp, name, ip->inum) < 0){
801060f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f4:	8b 50 0c             	mov    0xc(%eax),%edx
801060f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fa:	8b 40 0c             	mov    0xc(%eax),%eax
801060fd:	39 c2                	cmp    %eax,%edx
801060ff:	75 1f                	jne    80106120 <sys_link+0x116>
80106101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106104:	8b 00                	mov    (%eax),%eax
80106106:	89 44 24 08          	mov    %eax,0x8(%esp)
8010610a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010610d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106111:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106114:	89 04 24             	mov    %eax,(%esp)
80106117:	e8 29 c5 ff ff       	call   80102645 <dirlink>
8010611c:	85 c0                	test   %eax,%eax
8010611e:	79 0d                	jns    8010612d <sys_link+0x123>
    iunlockput(dp);
80106120:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106123:	89 04 24             	mov    %eax,(%esp)
80106126:	e8 df bd ff ff       	call   80101f0a <iunlockput>
    goto bad;
8010612b:	eb 22                	jmp    8010614f <sys_link+0x145>
  }
  iunlockput(dp);
8010612d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106130:	89 04 24             	mov    %eax,(%esp)
80106133:	e8 d2 bd ff ff       	call   80101f0a <iunlockput>
  iput(ip);
80106138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613b:	89 04 24             	mov    %eax,(%esp)
8010613e:	e8 f6 bc ff ff       	call   80101e39 <iput>

  end_op();
80106143:	e8 b1 db ff ff       	call   80103cf9 <end_op>

  return 0;
80106148:	b8 00 00 00 00       	mov    $0x0,%eax
8010614d:	eb 3c                	jmp    8010618b <sys_link+0x181>

bad:
  ilock(ip);
8010614f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106152:	89 04 24             	mov    %eax,(%esp)
80106155:	e8 bc ba ff ff       	call   80101c16 <ilock>
  ip->nlink--;
8010615a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010615d:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80106161:	8d 50 ff             	lea    -0x1(%eax),%edx
80106164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106167:	66 89 50 22          	mov    %dx,0x22(%eax)
  iupdate(ip);
8010616b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616e:	89 04 24             	mov    %eax,(%esp)
80106171:	e8 c0 b8 ff ff       	call   80101a36 <iupdate>
  iunlockput(ip);
80106176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106179:	89 04 24             	mov    %eax,(%esp)
8010617c:	e8 89 bd ff ff       	call   80101f0a <iunlockput>
  end_op();
80106181:	e8 73 db ff ff       	call   80103cf9 <end_op>
  return -1;
80106186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010618b:	c9                   	leave  
8010618c:	c3                   	ret    

8010618d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010618d:	55                   	push   %ebp
8010618e:	89 e5                	mov    %esp,%ebp
80106190:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106193:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010619a:	eb 4b                	jmp    801061e7 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010619c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801061a6:	00 
801061a7:	89 44 24 08          	mov    %eax,0x8(%esp)
801061ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801061b2:	8b 45 08             	mov    0x8(%ebp),%eax
801061b5:	89 04 24             	mov    %eax,(%esp)
801061b8:	e8 3d c0 ff ff       	call   801021fa <readi>
801061bd:	83 f8 10             	cmp    $0x10,%eax
801061c0:	74 0c                	je     801061ce <isdirempty+0x41>
      panic("isdirempty: readi");
801061c2:	c7 04 24 a3 92 10 80 	movl   $0x801092a3,(%esp)
801061c9:	e8 6c a3 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
801061ce:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801061d2:	66 85 c0             	test   %ax,%ax
801061d5:	74 07                	je     801061de <isdirempty+0x51>
      return 0;
801061d7:	b8 00 00 00 00       	mov    $0x0,%eax
801061dc:	eb 1b                	jmp    801061f9 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801061de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e1:	83 c0 10             	add    $0x10,%eax
801061e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061ea:	8b 45 08             	mov    0x8(%ebp),%eax
801061ed:	8b 40 24             	mov    0x24(%eax),%eax
801061f0:	39 c2                	cmp    %eax,%edx
801061f2:	72 a8                	jb     8010619c <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801061f4:	b8 01 00 00 00       	mov    $0x1,%eax
}
801061f9:	c9                   	leave  
801061fa:	c3                   	ret    

801061fb <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801061fb:	55                   	push   %ebp
801061fc:	89 e5                	mov    %esp,%ebp
801061fe:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;
  if(argstr(0, &path) < 0) {
80106201:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106204:	89 44 24 04          	mov    %eax,0x4(%esp)
80106208:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010620f:	e8 70 fa ff ff       	call   80105c84 <argstr>
80106214:	85 c0                	test   %eax,%eax
80106216:	79 0a                	jns    80106222 <sys_unlink+0x27>
    return -1;
80106218:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621d:	e9 af 01 00 00       	jmp    801063d1 <sys_unlink+0x1d6>
  }

  begin_op();
80106222:	e8 4e da ff ff       	call   80103c75 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106227:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010622a:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010622d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106231:	89 04 24             	mov    %eax,(%esp)
80106234:	e8 49 c7 ff ff       	call   80102982 <nameiparent>
80106239:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010623c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106240:	75 0f                	jne    80106251 <sys_unlink+0x56>
    end_op();
80106242:	e8 b2 da ff ff       	call   80103cf9 <end_op>
    return -1;
80106247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624c:	e9 80 01 00 00       	jmp    801063d1 <sys_unlink+0x1d6>
  }
  ilock(dp);
80106251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106254:	89 04 24             	mov    %eax,(%esp)
80106257:	e8 ba b9 ff ff       	call   80101c16 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010625c:	c7 44 24 04 b5 92 10 	movl   $0x801092b5,0x4(%esp)
80106263:	80 
80106264:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106267:	89 04 24             	mov    %eax,(%esp)
8010626a:	e8 ac c2 ff ff       	call   8010251b <namecmp>
8010626f:	85 c0                	test   %eax,%eax
80106271:	0f 84 45 01 00 00    	je     801063bc <sys_unlink+0x1c1>
80106277:	c7 44 24 04 b7 92 10 	movl   $0x801092b7,0x4(%esp)
8010627e:	80 
8010627f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106282:	89 04 24             	mov    %eax,(%esp)
80106285:	e8 91 c2 ff ff       	call   8010251b <namecmp>
8010628a:	85 c0                	test   %eax,%eax
8010628c:	0f 84 2a 01 00 00    	je     801063bc <sys_unlink+0x1c1>
    goto bad;
  if((ip = dirlookup(dp, name, &off)) == 0) {
80106292:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106295:	89 44 24 08          	mov    %eax,0x8(%esp)
80106299:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010629c:	89 44 24 04          	mov    %eax,0x4(%esp)
801062a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a3:	89 04 24             	mov    %eax,(%esp)
801062a6:	e8 92 c2 ff ff       	call   8010253d <dirlookup>
801062ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062b2:	75 05                	jne    801062b9 <sys_unlink+0xbe>
    goto bad;
801062b4:	e9 03 01 00 00       	jmp    801063bc <sys_unlink+0x1c1>
  }
  ilock(ip);
801062b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bc:	89 04 24             	mov    %eax,(%esp)
801062bf:	e8 52 b9 ff ff       	call   80101c16 <ilock>
  if(ip->nlink < 1)
801062c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c7:	0f b7 40 22          	movzwl 0x22(%eax),%eax
801062cb:	66 85 c0             	test   %ax,%ax
801062ce:	7f 0c                	jg     801062dc <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801062d0:	c7 04 24 ba 92 10 80 	movl   $0x801092ba,(%esp)
801062d7:	e8 5e a2 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801062dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062df:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
801062e3:	66 83 f8 01          	cmp    $0x1,%ax
801062e7:	75 1f                	jne    80106308 <sys_unlink+0x10d>
801062e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ec:	89 04 24             	mov    %eax,(%esp)
801062ef:	e8 99 fe ff ff       	call   8010618d <isdirempty>
801062f4:	85 c0                	test   %eax,%eax
801062f6:	75 10                	jne    80106308 <sys_unlink+0x10d>
    iunlockput(ip);
801062f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fb:	89 04 24             	mov    %eax,(%esp)
801062fe:	e8 07 bc ff ff       	call   80101f0a <iunlockput>
    goto bad;
80106303:	e9 b4 00 00 00       	jmp    801063bc <sys_unlink+0x1c1>
  }
  memset(&de, 0, sizeof(de));
80106308:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010630f:	00 
80106310:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106317:	00 
80106318:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010631b:	89 04 24             	mov    %eax,(%esp)
8010631e:	e8 8f f5 ff ff       	call   801058b2 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106323:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106326:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010632d:	00 
8010632e:	89 44 24 08          	mov    %eax,0x8(%esp)
80106332:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106335:	89 44 24 04          	mov    %eax,0x4(%esp)
80106339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633c:	89 04 24             	mov    %eax,(%esp)
8010633f:	e8 31 c0 ff ff       	call   80102375 <writei>
80106344:	83 f8 10             	cmp    $0x10,%eax
80106347:	74 0c                	je     80106355 <sys_unlink+0x15a>
    panic("unlink: writei");
80106349:	c7 04 24 cc 92 10 80 	movl   $0x801092cc,(%esp)
80106350:	e8 e5 a1 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80106355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106358:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
8010635c:	66 83 f8 01          	cmp    $0x1,%ax
80106360:	75 1c                	jne    8010637e <sys_unlink+0x183>
    dp->nlink--;
80106362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106365:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80106369:	8d 50 ff             	lea    -0x1(%eax),%edx
8010636c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636f:	66 89 50 22          	mov    %dx,0x22(%eax)
    iupdate(dp);
80106373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106376:	89 04 24             	mov    %eax,(%esp)
80106379:	e8 b8 b6 ff ff       	call   80101a36 <iupdate>
  }
  iunlockput(dp);
8010637e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106381:	89 04 24             	mov    %eax,(%esp)
80106384:	e8 81 bb ff ff       	call   80101f0a <iunlockput>
  ip->nlink--;
80106389:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638c:	0f b7 40 22          	movzwl 0x22(%eax),%eax
80106390:	8d 50 ff             	lea    -0x1(%eax),%edx
80106393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106396:	66 89 50 22          	mov    %dx,0x22(%eax)
  iupdate(ip);
8010639a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639d:	89 04 24             	mov    %eax,(%esp)
801063a0:	e8 91 b6 ff ff       	call   80101a36 <iupdate>
  iunlockput(ip);
801063a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a8:	89 04 24             	mov    %eax,(%esp)
801063ab:	e8 5a bb ff ff       	call   80101f0a <iunlockput>

  end_op();
801063b0:	e8 44 d9 ff ff       	call   80103cf9 <end_op>
  return 0;
801063b5:	b8 00 00 00 00       	mov    $0x0,%eax
801063ba:	eb 15                	jmp    801063d1 <sys_unlink+0x1d6>

bad:
  
  iunlockput(dp);
801063bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bf:	89 04 24             	mov    %eax,(%esp)
801063c2:	e8 43 bb ff ff       	call   80101f0a <iunlockput>
  end_op();
801063c7:	e8 2d d9 ff ff       	call   80103cf9 <end_op>
  return -1;
801063cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801063d1:	c9                   	leave  
801063d2:	c3                   	ret    

801063d3 <create>:



static struct inode*
create(char *path, short type, short major, short minor)
{
801063d3:	55                   	push   %ebp
801063d4:	89 e5                	mov    %esp,%ebp
801063d6:	83 ec 48             	sub    $0x48,%esp
801063d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801063dc:	8b 55 10             	mov    0x10(%ebp),%edx
801063df:	8b 45 14             	mov    0x14(%ebp),%eax
801063e2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801063e6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801063ea:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801063ee:	8d 45 de             	lea    -0x22(%ebp),%eax
801063f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f5:	8b 45 08             	mov    0x8(%ebp),%eax
801063f8:	89 04 24             	mov    %eax,(%esp)
801063fb:	e8 82 c5 ff ff       	call   80102982 <nameiparent>
80106400:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106403:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106407:	75 0a                	jne    80106413 <create+0x40>
    return 0;
80106409:	b8 00 00 00 00       	mov    $0x0,%eax
8010640e:	e9 84 01 00 00       	jmp    80106597 <create+0x1c4>
  ilock(dp);
80106413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106416:	89 04 24             	mov    %eax,(%esp)
80106419:	e8 f8 b7 ff ff       	call   80101c16 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010641e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106421:	89 44 24 08          	mov    %eax,0x8(%esp)
80106425:	8d 45 de             	lea    -0x22(%ebp),%eax
80106428:	89 44 24 04          	mov    %eax,0x4(%esp)
8010642c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642f:	89 04 24             	mov    %eax,(%esp)
80106432:	e8 06 c1 ff ff       	call   8010253d <dirlookup>
80106437:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010643a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010643e:	74 47                	je     80106487 <create+0xb4>
    iunlockput(dp);
80106440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106443:	89 04 24             	mov    %eax,(%esp)
80106446:	e8 bf ba ff ff       	call   80101f0a <iunlockput>
    ilock(ip);
8010644b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010644e:	89 04 24             	mov    %eax,(%esp)
80106451:	e8 c0 b7 ff ff       	call   80101c16 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80106456:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010645b:	75 15                	jne    80106472 <create+0x9f>
8010645d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106460:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
80106464:	66 83 f8 02          	cmp    $0x2,%ax
80106468:	75 08                	jne    80106472 <create+0x9f>
      return ip;
8010646a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010646d:	e9 25 01 00 00       	jmp    80106597 <create+0x1c4>
    iunlockput(ip);
80106472:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106475:	89 04 24             	mov    %eax,(%esp)
80106478:	e8 8d ba ff ff       	call   80101f0a <iunlockput>
    return 0;
8010647d:	b8 00 00 00 00       	mov    $0x0,%eax
80106482:	e9 10 01 00 00       	jmp    80106597 <create+0x1c4>
  }
  if((ip = ialloc(dp->prt, type)) == 0)
80106487:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010648b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010648e:	8b 40 0c             	mov    0xc(%eax),%eax
80106491:	89 54 24 04          	mov    %edx,0x4(%esp)
80106495:	89 04 24             	mov    %eax,(%esp)
80106498:	e8 ae b4 ff ff       	call   8010194b <ialloc>
8010649d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064a4:	75 0c                	jne    801064b2 <create+0xdf>
    panic("create: ialloc");
801064a6:	c7 04 24 db 92 10 80 	movl   $0x801092db,(%esp)
801064ad:	e8 88 a0 ff ff       	call   8010053a <panic>
  if(proc && proc->pid > 2) {
801064b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064b8:	85 c0                	test   %eax,%eax
    //print_in(ip);
  }
  ilock(ip);
801064ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064bd:	89 04 24             	mov    %eax,(%esp)
801064c0:	e8 51 b7 ff ff       	call   80101c16 <ilock>
  ip->major = major;
801064c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c8:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801064cc:	66 89 50 1e          	mov    %dx,0x1e(%eax)
  ip->minor = minor;
801064d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d3:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801064d7:	66 89 50 20          	mov    %dx,0x20(%eax)
  ip->nlink = 1;
801064db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064de:	66 c7 40 22 01 00    	movw   $0x1,0x22(%eax)
  iupdate(ip);
801064e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064e7:	89 04 24             	mov    %eax,(%esp)
801064ea:	e8 47 b5 ff ff       	call   80101a36 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801064ef:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801064f4:	75 68                	jne    8010655e <create+0x18b>
    dp->nlink++;  // for ".."
801064f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f9:	0f b7 40 22          	movzwl 0x22(%eax),%eax
801064fd:	8d 50 01             	lea    0x1(%eax),%edx
80106500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106503:	66 89 50 22          	mov    %dx,0x22(%eax)
    iupdate(dp);
80106507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650a:	89 04 24             	mov    %eax,(%esp)
8010650d:	e8 24 b5 ff ff       	call   80101a36 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106512:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106515:	8b 00                	mov    (%eax),%eax
80106517:	89 44 24 08          	mov    %eax,0x8(%esp)
8010651b:	c7 44 24 04 b5 92 10 	movl   $0x801092b5,0x4(%esp)
80106522:	80 
80106523:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106526:	89 04 24             	mov    %eax,(%esp)
80106529:	e8 17 c1 ff ff       	call   80102645 <dirlink>
8010652e:	85 c0                	test   %eax,%eax
80106530:	78 20                	js     80106552 <create+0x17f>
80106532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106535:	8b 00                	mov    (%eax),%eax
80106537:	89 44 24 08          	mov    %eax,0x8(%esp)
8010653b:	c7 44 24 04 b7 92 10 	movl   $0x801092b7,0x4(%esp)
80106542:	80 
80106543:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106546:	89 04 24             	mov    %eax,(%esp)
80106549:	e8 f7 c0 ff ff       	call   80102645 <dirlink>
8010654e:	85 c0                	test   %eax,%eax
80106550:	79 0c                	jns    8010655e <create+0x18b>
      panic("create dots");
80106552:	c7 04 24 ea 92 10 80 	movl   $0x801092ea,(%esp)
80106559:	e8 dc 9f ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010655e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106561:	8b 00                	mov    (%eax),%eax
80106563:	89 44 24 08          	mov    %eax,0x8(%esp)
80106567:	8d 45 de             	lea    -0x22(%ebp),%eax
8010656a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010656e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106571:	89 04 24             	mov    %eax,(%esp)
80106574:	e8 cc c0 ff ff       	call   80102645 <dirlink>
80106579:	85 c0                	test   %eax,%eax
8010657b:	79 0c                	jns    80106589 <create+0x1b6>
    panic("create: dirlink");
8010657d:	c7 04 24 f6 92 10 80 	movl   $0x801092f6,(%esp)
80106584:	e8 b1 9f ff ff       	call   8010053a <panic>

  iunlockput(dp);
80106589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658c:	89 04 24             	mov    %eax,(%esp)
8010658f:	e8 76 b9 ff ff       	call   80101f0a <iunlockput>

  return ip;
80106594:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106597:	c9                   	leave  
80106598:	c3                   	ret    

80106599 <sys_mount>:

int
sys_mount(void) {
80106599:	55                   	push   %ebp
8010659a:	89 e5                	mov    %esp,%ebp
8010659c:	83 ec 28             	sub    $0x28,%esp
  char* path;
  int prt;
  if(argstr(0, &path) < 0 || argint(1, &prt) < 0)
8010659f:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065ad:	e8 d2 f6 ff ff       	call   80105c84 <argstr>
801065b2:	85 c0                	test   %eax,%eax
801065b4:	78 17                	js     801065cd <sys_mount+0x34>
801065b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065c4:	e8 2b f6 ff ff       	call   80105bf4 <argint>
801065c9:	85 c0                	test   %eax,%eax
801065cb:	79 07                	jns    801065d4 <sys_mount+0x3b>
    return -1;
801065cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d2:	eb 12                	jmp    801065e6 <sys_mount+0x4d>
  return mount(path, prt);
801065d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065da:	89 54 24 04          	mov    %edx,0x4(%esp)
801065de:	89 04 24             	mov    %eax,(%esp)
801065e1:	e8 f3 c4 ff ff       	call   80102ad9 <mount>
}
801065e6:	c9                   	leave  
801065e7:	c3                   	ret    

801065e8 <sys_open>:

int
sys_open(void)
{
801065e8:	55                   	push   %ebp
801065e9:	89 e5                	mov    %esp,%ebp
801065eb:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801065ee:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801065f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065fc:	e8 83 f6 ff ff       	call   80105c84 <argstr>
80106601:	85 c0                	test   %eax,%eax
80106603:	78 17                	js     8010661c <sys_open+0x34>
80106605:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106608:	89 44 24 04          	mov    %eax,0x4(%esp)
8010660c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106613:	e8 dc f5 ff ff       	call   80105bf4 <argint>
80106618:	85 c0                	test   %eax,%eax
8010661a:	79 0a                	jns    80106626 <sys_open+0x3e>
    return -1;
8010661c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106621:	e9 5c 01 00 00       	jmp    80106782 <sys_open+0x19a>
  begin_op();
80106626:	e8 4a d6 ff ff       	call   80103c75 <begin_op>
  
  if(omode & O_CREATE){
8010662b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010662e:	25 00 02 00 00       	and    $0x200,%eax
80106633:	85 c0                	test   %eax,%eax
80106635:	74 3b                	je     80106672 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106637:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010663a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106641:	00 
80106642:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106649:	00 
8010664a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106651:	00 
80106652:	89 04 24             	mov    %eax,(%esp)
80106655:	e8 79 fd ff ff       	call   801063d3 <create>
8010665a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010665d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106661:	75 6b                	jne    801066ce <sys_open+0xe6>
      end_op();
80106663:	e8 91 d6 ff ff       	call   80103cf9 <end_op>
      return -1;
80106668:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666d:	e9 10 01 00 00       	jmp    80106782 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80106672:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106675:	89 04 24             	mov    %eax,(%esp)
80106678:	e8 dd c2 ff ff       	call   8010295a <namei>
8010667d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106680:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106684:	75 0f                	jne    80106695 <sys_open+0xad>
      end_op();
80106686:	e8 6e d6 ff ff       	call   80103cf9 <end_op>
      return -1;
8010668b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106690:	e9 ed 00 00 00       	jmp    80106782 <sys_open+0x19a>
    }
    ilock(ip);
80106695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106698:	89 04 24             	mov    %eax,(%esp)
8010669b:	e8 76 b5 ff ff       	call   80101c16 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801066a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a3:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
801066a7:	66 83 f8 01          	cmp    $0x1,%ax
801066ab:	75 21                	jne    801066ce <sys_open+0xe6>
801066ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066b0:	85 c0                	test   %eax,%eax
801066b2:	74 1a                	je     801066ce <sys_open+0xe6>
      iunlockput(ip);
801066b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b7:	89 04 24             	mov    %eax,(%esp)
801066ba:	e8 4b b8 ff ff       	call   80101f0a <iunlockput>
      end_op();
801066bf:	e8 35 d6 ff ff       	call   80103cf9 <end_op>
      return -1;
801066c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c9:	e9 b4 00 00 00       	jmp    80106782 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801066ce:	e8 6e a8 ff ff       	call   80100f41 <filealloc>
801066d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066da:	74 14                	je     801066f0 <sys_open+0x108>
801066dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066df:	89 04 24             	mov    %eax,(%esp)
801066e2:	e8 d8 f6 ff ff       	call   80105dbf <fdalloc>
801066e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801066ea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801066ee:	79 28                	jns    80106718 <sys_open+0x130>
    if(f)
801066f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066f4:	74 0b                	je     80106701 <sys_open+0x119>
      fileclose(f);
801066f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066f9:	89 04 24             	mov    %eax,(%esp)
801066fc:	e8 e8 a8 ff ff       	call   80100fe9 <fileclose>
    iunlockput(ip);
80106701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106704:	89 04 24             	mov    %eax,(%esp)
80106707:	e8 fe b7 ff ff       	call   80101f0a <iunlockput>
    end_op();
8010670c:	e8 e8 d5 ff ff       	call   80103cf9 <end_op>
    return -1;
80106711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106716:	eb 6a                	jmp    80106782 <sys_open+0x19a>
  }
  iunlock(ip);
80106718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010671b:	89 04 24             	mov    %eax,(%esp)
8010671e:	e8 b1 b6 ff ff       	call   80101dd4 <iunlock>
  end_op();
80106723:	e8 d1 d5 ff ff       	call   80103cf9 <end_op>

  f->type = FD_INODE;
80106728:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010672b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106731:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106734:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106737:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010673a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010673d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106747:	83 e0 01             	and    $0x1,%eax
8010674a:	85 c0                	test   %eax,%eax
8010674c:	0f 94 c0             	sete   %al
8010674f:	89 c2                	mov    %eax,%edx
80106751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106754:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106757:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010675a:	83 e0 01             	and    $0x1,%eax
8010675d:	85 c0                	test   %eax,%eax
8010675f:	75 0a                	jne    8010676b <sys_open+0x183>
80106761:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106764:	83 e0 02             	and    $0x2,%eax
80106767:	85 c0                	test   %eax,%eax
80106769:	74 07                	je     80106772 <sys_open+0x18a>
8010676b:	b8 01 00 00 00       	mov    $0x1,%eax
80106770:	eb 05                	jmp    80106777 <sys_open+0x18f>
80106772:	b8 00 00 00 00       	mov    $0x0,%eax
80106777:	89 c2                	mov    %eax,%edx
80106779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010677c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010677f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106782:	c9                   	leave  
80106783:	c3                   	ret    

80106784 <sys_mkdir>:

int
sys_mkdir(void)
{
80106784:	55                   	push   %ebp
80106785:	89 e5                	mov    %esp,%ebp
80106787:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010678a:	e8 e6 d4 ff ff       	call   80103c75 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010678f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106792:	89 44 24 04          	mov    %eax,0x4(%esp)
80106796:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010679d:	e8 e2 f4 ff ff       	call   80105c84 <argstr>
801067a2:	85 c0                	test   %eax,%eax
801067a4:	78 2c                	js     801067d2 <sys_mkdir+0x4e>
801067a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801067b0:	00 
801067b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801067b8:	00 
801067b9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801067c0:	00 
801067c1:	89 04 24             	mov    %eax,(%esp)
801067c4:	e8 0a fc ff ff       	call   801063d3 <create>
801067c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067d0:	75 0c                	jne    801067de <sys_mkdir+0x5a>
    end_op();
801067d2:	e8 22 d5 ff ff       	call   80103cf9 <end_op>
    return -1;
801067d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067dc:	eb 15                	jmp    801067f3 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801067de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e1:	89 04 24             	mov    %eax,(%esp)
801067e4:	e8 21 b7 ff ff       	call   80101f0a <iunlockput>
  end_op();
801067e9:	e8 0b d5 ff ff       	call   80103cf9 <end_op>
  return 0;
801067ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067f3:	c9                   	leave  
801067f4:	c3                   	ret    

801067f5 <sys_mknod>:

int
sys_mknod(void)
{
801067f5:	55                   	push   %ebp
801067f6:	89 e5                	mov    %esp,%ebp
801067f8:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801067fb:	e8 75 d4 ff ff       	call   80103c75 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106800:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106803:	89 44 24 04          	mov    %eax,0x4(%esp)
80106807:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010680e:	e8 71 f4 ff ff       	call   80105c84 <argstr>
80106813:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106816:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010681a:	78 5e                	js     8010687a <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010681c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010681f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106823:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010682a:	e8 c5 f3 ff ff       	call   80105bf4 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010682f:	85 c0                	test   %eax,%eax
80106831:	78 47                	js     8010687a <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106833:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106836:	89 44 24 04          	mov    %eax,0x4(%esp)
8010683a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106841:	e8 ae f3 ff ff       	call   80105bf4 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106846:	85 c0                	test   %eax,%eax
80106848:	78 30                	js     8010687a <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010684a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010684d:	0f bf c8             	movswl %ax,%ecx
80106850:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106853:	0f bf d0             	movswl %ax,%edx
80106856:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106859:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010685d:	89 54 24 08          	mov    %edx,0x8(%esp)
80106861:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106868:	00 
80106869:	89 04 24             	mov    %eax,(%esp)
8010686c:	e8 62 fb ff ff       	call   801063d3 <create>
80106871:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106874:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106878:	75 0c                	jne    80106886 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010687a:	e8 7a d4 ff ff       	call   80103cf9 <end_op>
    return -1;
8010687f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106884:	eb 15                	jmp    8010689b <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106889:	89 04 24             	mov    %eax,(%esp)
8010688c:	e8 79 b6 ff ff       	call   80101f0a <iunlockput>
  end_op();
80106891:	e8 63 d4 ff ff       	call   80103cf9 <end_op>
  return 0;
80106896:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010689b:	c9                   	leave  
8010689c:	c3                   	ret    

8010689d <sys_chdir>:

int
sys_chdir(void)
{
8010689d:	55                   	push   %ebp
8010689e:	89 e5                	mov    %esp,%ebp
801068a0:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801068a3:	e8 cd d3 ff ff       	call   80103c75 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801068a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801068af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068b6:	e8 c9 f3 ff ff       	call   80105c84 <argstr>
801068bb:	85 c0                	test   %eax,%eax
801068bd:	78 14                	js     801068d3 <sys_chdir+0x36>
801068bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068c2:	89 04 24             	mov    %eax,(%esp)
801068c5:	e8 90 c0 ff ff       	call   8010295a <namei>
801068ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068d1:	75 0c                	jne    801068df <sys_chdir+0x42>
    end_op();
801068d3:	e8 21 d4 ff ff       	call   80103cf9 <end_op>
    return -1;
801068d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068dd:	eb 61                	jmp    80106940 <sys_chdir+0xa3>
  }
  ilock(ip);
801068df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e2:	89 04 24             	mov    %eax,(%esp)
801068e5:	e8 2c b3 ff ff       	call   80101c16 <ilock>
  if(ip->type != T_DIR){
801068ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ed:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
801068f1:	66 83 f8 01          	cmp    $0x1,%ax
801068f5:	74 17                	je     8010690e <sys_chdir+0x71>
    iunlockput(ip);
801068f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fa:	89 04 24             	mov    %eax,(%esp)
801068fd:	e8 08 b6 ff ff       	call   80101f0a <iunlockput>
    end_op();
80106902:	e8 f2 d3 ff ff       	call   80103cf9 <end_op>
    return -1;
80106907:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010690c:	eb 32                	jmp    80106940 <sys_chdir+0xa3>
  }
  iunlock(ip);
8010690e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106911:	89 04 24             	mov    %eax,(%esp)
80106914:	e8 bb b4 ff ff       	call   80101dd4 <iunlock>
  iput(proc->cwd);
80106919:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010691f:	8b 40 68             	mov    0x68(%eax),%eax
80106922:	89 04 24             	mov    %eax,(%esp)
80106925:	e8 0f b5 ff ff       	call   80101e39 <iput>
  end_op();
8010692a:	e8 ca d3 ff ff       	call   80103cf9 <end_op>
  proc->cwd = ip;
8010692f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106935:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106938:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010693b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106940:	c9                   	leave  
80106941:	c3                   	ret    

80106942 <sys_exec>:

int
sys_exec(void)
{
80106942:	55                   	push   %ebp
80106943:	89 e5                	mov    %esp,%ebp
80106945:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010694b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010694e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106952:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106959:	e8 26 f3 ff ff       	call   80105c84 <argstr>
8010695e:	85 c0                	test   %eax,%eax
80106960:	78 1a                	js     8010697c <sys_exec+0x3a>
80106962:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106968:	89 44 24 04          	mov    %eax,0x4(%esp)
8010696c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106973:	e8 7c f2 ff ff       	call   80105bf4 <argint>
80106978:	85 c0                	test   %eax,%eax
8010697a:	79 0a                	jns    80106986 <sys_exec+0x44>
    return -1;
8010697c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106981:	e9 c8 00 00 00       	jmp    80106a4e <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
80106986:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010698d:	00 
8010698e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106995:	00 
80106996:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010699c:	89 04 24             	mov    %eax,(%esp)
8010699f:	e8 0e ef ff ff       	call   801058b2 <memset>
  for(i=0;; i++){
801069a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801069ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ae:	83 f8 1f             	cmp    $0x1f,%eax
801069b1:	76 0a                	jbe    801069bd <sys_exec+0x7b>
      return -1;
801069b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b8:	e9 91 00 00 00       	jmp    80106a4e <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801069bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c0:	c1 e0 02             	shl    $0x2,%eax
801069c3:	89 c2                	mov    %eax,%edx
801069c5:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801069cb:	01 c2                	add    %eax,%edx
801069cd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801069d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801069d7:	89 14 24             	mov    %edx,(%esp)
801069da:	e8 79 f1 ff ff       	call   80105b58 <fetchint>
801069df:	85 c0                	test   %eax,%eax
801069e1:	79 07                	jns    801069ea <sys_exec+0xa8>
      return -1;
801069e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e8:	eb 64                	jmp    80106a4e <sys_exec+0x10c>
    if(uarg == 0){
801069ea:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801069f0:	85 c0                	test   %eax,%eax
801069f2:	75 26                	jne    80106a1a <sys_exec+0xd8>
      argv[i] = 0;
801069f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f7:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801069fe:	00 00 00 00 
      break;
80106a02:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a06:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106a0c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a10:	89 04 24             	mov    %eax,(%esp)
80106a13:	e8 f2 a0 ff ff       	call   80100b0a <exec>
80106a18:	eb 34                	jmp    80106a4e <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106a1a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106a20:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a23:	c1 e2 02             	shl    $0x2,%edx
80106a26:	01 c2                	add    %eax,%edx
80106a28:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106a2e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a32:	89 04 24             	mov    %eax,(%esp)
80106a35:	e8 58 f1 ff ff       	call   80105b92 <fetchstr>
80106a3a:	85 c0                	test   %eax,%eax
80106a3c:	79 07                	jns    80106a45 <sys_exec+0x103>
      return -1;
80106a3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a43:	eb 09                	jmp    80106a4e <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106a45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106a49:	e9 5d ff ff ff       	jmp    801069ab <sys_exec+0x69>
  return exec(path, argv);
}
80106a4e:	c9                   	leave  
80106a4f:	c3                   	ret    

80106a50 <sys_pipe>:

int
sys_pipe(void)
{
80106a50:	55                   	push   %ebp
80106a51:	89 e5                	mov    %esp,%ebp
80106a53:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106a56:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106a5d:	00 
80106a5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a61:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a6c:	e8 b1 f1 ff ff       	call   80105c22 <argptr>
80106a71:	85 c0                	test   %eax,%eax
80106a73:	79 0a                	jns    80106a7f <sys_pipe+0x2f>
    return -1;
80106a75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a7a:	e9 9b 00 00 00       	jmp    80106b1a <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106a7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106a82:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a86:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106a89:	89 04 24             	mov    %eax,(%esp)
80106a8c:	e8 f0 dc ff ff       	call   80104781 <pipealloc>
80106a91:	85 c0                	test   %eax,%eax
80106a93:	79 07                	jns    80106a9c <sys_pipe+0x4c>
    return -1;
80106a95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a9a:	eb 7e                	jmp    80106b1a <sys_pipe+0xca>
  fd0 = -1;
80106a9c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106aa3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106aa6:	89 04 24             	mov    %eax,(%esp)
80106aa9:	e8 11 f3 ff ff       	call   80105dbf <fdalloc>
80106aae:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ab1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ab5:	78 14                	js     80106acb <sys_pipe+0x7b>
80106ab7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106aba:	89 04 24             	mov    %eax,(%esp)
80106abd:	e8 fd f2 ff ff       	call   80105dbf <fdalloc>
80106ac2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ac5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ac9:	79 37                	jns    80106b02 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106acb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106acf:	78 14                	js     80106ae5 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106ad1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ad7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ada:	83 c2 08             	add    $0x8,%edx
80106add:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106ae4:	00 
    fileclose(rf);
80106ae5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ae8:	89 04 24             	mov    %eax,(%esp)
80106aeb:	e8 f9 a4 ff ff       	call   80100fe9 <fileclose>
    fileclose(wf);
80106af0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106af3:	89 04 24             	mov    %eax,(%esp)
80106af6:	e8 ee a4 ff ff       	call   80100fe9 <fileclose>
    return -1;
80106afb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b00:	eb 18                	jmp    80106b1a <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106b02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106b05:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b08:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106b0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106b0d:	8d 50 04             	lea    0x4(%eax),%edx
80106b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b13:	89 02                	mov    %eax,(%edx)
  return 0;
80106b15:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b1a:	c9                   	leave  
80106b1b:	c3                   	ret    

80106b1c <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106b1c:	55                   	push   %ebp
80106b1d:	89 e5                	mov    %esp,%ebp
80106b1f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106b22:	e8 05 e3 ff ff       	call   80104e2c <fork>
}
80106b27:	c9                   	leave  
80106b28:	c3                   	ret    

80106b29 <sys_exit>:

int
sys_exit(void)
{
80106b29:	55                   	push   %ebp
80106b2a:	89 e5                	mov    %esp,%ebp
80106b2c:	83 ec 08             	sub    $0x8,%esp
  exit();
80106b2f:	e8 73 e4 ff ff       	call   80104fa7 <exit>
  return 0;  // not reached
80106b34:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b39:	c9                   	leave  
80106b3a:	c3                   	ret    

80106b3b <sys_wait>:

int
sys_wait(void)
{
80106b3b:	55                   	push   %ebp
80106b3c:	89 e5                	mov    %esp,%ebp
80106b3e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106b41:	e8 83 e5 ff ff       	call   801050c9 <wait>
}
80106b46:	c9                   	leave  
80106b47:	c3                   	ret    

80106b48 <sys_kill>:

int
sys_kill(void)
{
80106b48:	55                   	push   %ebp
80106b49:	89 e5                	mov    %esp,%ebp
80106b4b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106b4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b51:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b5c:	e8 93 f0 ff ff       	call   80105bf4 <argint>
80106b61:	85 c0                	test   %eax,%eax
80106b63:	79 07                	jns    80106b6c <sys_kill+0x24>
    return -1;
80106b65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b6a:	eb 0b                	jmp    80106b77 <sys_kill+0x2f>
  return kill(pid);
80106b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6f:	89 04 24             	mov    %eax,(%esp)
80106b72:	e8 21 e9 ff ff       	call   80105498 <kill>
}
80106b77:	c9                   	leave  
80106b78:	c3                   	ret    

80106b79 <sys_getpid>:

int
sys_getpid(void)
{
80106b79:	55                   	push   %ebp
80106b7a:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106b7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b82:	8b 40 10             	mov    0x10(%eax),%eax
}
80106b85:	5d                   	pop    %ebp
80106b86:	c3                   	ret    

80106b87 <sys_sbrk>:

int
sys_sbrk(void)
{
80106b87:	55                   	push   %ebp
80106b88:	89 e5                	mov    %esp,%ebp
80106b8a:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106b8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b90:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b9b:	e8 54 f0 ff ff       	call   80105bf4 <argint>
80106ba0:	85 c0                	test   %eax,%eax
80106ba2:	79 07                	jns    80106bab <sys_sbrk+0x24>
    return -1;
80106ba4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ba9:	eb 24                	jmp    80106bcf <sys_sbrk+0x48>
  addr = proc->sz;
80106bab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bb1:	8b 00                	mov    (%eax),%eax
80106bb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bb9:	89 04 24             	mov    %eax,(%esp)
80106bbc:	e8 c6 e1 ff ff       	call   80104d87 <growproc>
80106bc1:	85 c0                	test   %eax,%eax
80106bc3:	79 07                	jns    80106bcc <sys_sbrk+0x45>
    return -1;
80106bc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bca:	eb 03                	jmp    80106bcf <sys_sbrk+0x48>
  return addr;
80106bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106bcf:	c9                   	leave  
80106bd0:	c3                   	ret    

80106bd1 <sys_sleep>:

int
sys_sleep(void)
{
80106bd1:	55                   	push   %ebp
80106bd2:	89 e5                	mov    %esp,%ebp
80106bd4:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106bd7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bda:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bde:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106be5:	e8 0a f0 ff ff       	call   80105bf4 <argint>
80106bea:	85 c0                	test   %eax,%eax
80106bec:	79 07                	jns    80106bf5 <sys_sleep+0x24>
    return -1;
80106bee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bf3:	eb 6c                	jmp    80106c61 <sys_sleep+0x90>
  acquire(&tickslock);
80106bf5:	c7 04 24 e0 74 11 80 	movl   $0x801174e0,(%esp)
80106bfc:	e8 5d ea ff ff       	call   8010565e <acquire>
  ticks0 = ticks;
80106c01:	a1 20 7d 11 80       	mov    0x80117d20,%eax
80106c06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106c09:	eb 34                	jmp    80106c3f <sys_sleep+0x6e>
    if(proc->killed){
80106c0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c11:	8b 40 24             	mov    0x24(%eax),%eax
80106c14:	85 c0                	test   %eax,%eax
80106c16:	74 13                	je     80106c2b <sys_sleep+0x5a>
      release(&tickslock);
80106c18:	c7 04 24 e0 74 11 80 	movl   $0x801174e0,(%esp)
80106c1f:	e8 9c ea ff ff       	call   801056c0 <release>
      return -1;
80106c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c29:	eb 36                	jmp    80106c61 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106c2b:	c7 44 24 04 e0 74 11 	movl   $0x801174e0,0x4(%esp)
80106c32:	80 
80106c33:	c7 04 24 20 7d 11 80 	movl   $0x80117d20,(%esp)
80106c3a:	e8 55 e7 ff ff       	call   80105394 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106c3f:	a1 20 7d 11 80       	mov    0x80117d20,%eax
80106c44:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106c47:	89 c2                	mov    %eax,%edx
80106c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c4c:	39 c2                	cmp    %eax,%edx
80106c4e:	72 bb                	jb     80106c0b <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106c50:	c7 04 24 e0 74 11 80 	movl   $0x801174e0,(%esp)
80106c57:	e8 64 ea ff ff       	call   801056c0 <release>
  return 0;
80106c5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c61:	c9                   	leave  
80106c62:	c3                   	ret    

80106c63 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106c63:	55                   	push   %ebp
80106c64:	89 e5                	mov    %esp,%ebp
80106c66:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106c69:	c7 04 24 e0 74 11 80 	movl   $0x801174e0,(%esp)
80106c70:	e8 e9 e9 ff ff       	call   8010565e <acquire>
  xticks = ticks;
80106c75:	a1 20 7d 11 80       	mov    0x80117d20,%eax
80106c7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106c7d:	c7 04 24 e0 74 11 80 	movl   $0x801174e0,(%esp)
80106c84:	e8 37 ea ff ff       	call   801056c0 <release>
  return xticks;
80106c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106c8c:	c9                   	leave  
80106c8d:	c3                   	ret    

80106c8e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c8e:	55                   	push   %ebp
80106c8f:	89 e5                	mov    %esp,%ebp
80106c91:	83 ec 08             	sub    $0x8,%esp
80106c94:	8b 55 08             	mov    0x8(%ebp),%edx
80106c97:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c9a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c9e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ca1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ca5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ca9:	ee                   	out    %al,(%dx)
}
80106caa:	c9                   	leave  
80106cab:	c3                   	ret    

80106cac <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106cac:	55                   	push   %ebp
80106cad:	89 e5                	mov    %esp,%ebp
80106caf:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106cb2:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106cb9:	00 
80106cba:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106cc1:	e8 c8 ff ff ff       	call   80106c8e <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106cc6:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106ccd:	00 
80106cce:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106cd5:	e8 b4 ff ff ff       	call   80106c8e <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106cda:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106ce1:	00 
80106ce2:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106ce9:	e8 a0 ff ff ff       	call   80106c8e <outb>
  picenable(IRQ_TIMER);
80106cee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cf5:	e8 1a d9 ff ff       	call   80104614 <picenable>
}
80106cfa:	c9                   	leave  
80106cfb:	c3                   	ret    

80106cfc <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106cfc:	1e                   	push   %ds
  pushl %es
80106cfd:	06                   	push   %es
  pushl %fs
80106cfe:	0f a0                	push   %fs
  pushl %gs
80106d00:	0f a8                	push   %gs
  pushal
80106d02:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106d03:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106d07:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106d09:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106d0b:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106d0f:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106d11:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106d13:	54                   	push   %esp
  call trap
80106d14:	e8 d8 01 00 00       	call   80106ef1 <trap>
  addl $4, %esp
80106d19:	83 c4 04             	add    $0x4,%esp

80106d1c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106d1c:	61                   	popa   
  popl %gs
80106d1d:	0f a9                	pop    %gs
  popl %fs
80106d1f:	0f a1                	pop    %fs
  popl %es
80106d21:	07                   	pop    %es
  popl %ds
80106d22:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106d23:	83 c4 08             	add    $0x8,%esp
  iret
80106d26:	cf                   	iret   

80106d27 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106d27:	55                   	push   %ebp
80106d28:	89 e5                	mov    %esp,%ebp
80106d2a:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d30:	83 e8 01             	sub    $0x1,%eax
80106d33:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106d37:	8b 45 08             	mov    0x8(%ebp),%eax
80106d3a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d41:	c1 e8 10             	shr    $0x10,%eax
80106d44:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106d48:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106d4b:	0f 01 18             	lidtl  (%eax)
}
80106d4e:	c9                   	leave  
80106d4f:	c3                   	ret    

80106d50 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106d50:	55                   	push   %ebp
80106d51:	89 e5                	mov    %esp,%ebp
80106d53:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106d56:	0f 20 d0             	mov    %cr2,%eax
80106d59:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106d5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d5f:	c9                   	leave  
80106d60:	c3                   	ret    

80106d61 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106d61:	55                   	push   %ebp
80106d62:	89 e5                	mov    %esp,%ebp
80106d64:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106d67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d6e:	e9 c3 00 00 00       	jmp    80106e36 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d76:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
80106d7d:	89 c2                	mov    %eax,%edx
80106d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d82:	66 89 14 c5 20 75 11 	mov    %dx,-0x7fee8ae0(,%eax,8)
80106d89:	80 
80106d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d8d:	66 c7 04 c5 22 75 11 	movw   $0x8,-0x7fee8ade(,%eax,8)
80106d94:	80 08 00 
80106d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d9a:	0f b6 14 c5 24 75 11 	movzbl -0x7fee8adc(,%eax,8),%edx
80106da1:	80 
80106da2:	83 e2 e0             	and    $0xffffffe0,%edx
80106da5:	88 14 c5 24 75 11 80 	mov    %dl,-0x7fee8adc(,%eax,8)
80106dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106daf:	0f b6 14 c5 24 75 11 	movzbl -0x7fee8adc(,%eax,8),%edx
80106db6:	80 
80106db7:	83 e2 1f             	and    $0x1f,%edx
80106dba:	88 14 c5 24 75 11 80 	mov    %dl,-0x7fee8adc(,%eax,8)
80106dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dc4:	0f b6 14 c5 25 75 11 	movzbl -0x7fee8adb(,%eax,8),%edx
80106dcb:	80 
80106dcc:	83 e2 f0             	and    $0xfffffff0,%edx
80106dcf:	83 ca 0e             	or     $0xe,%edx
80106dd2:	88 14 c5 25 75 11 80 	mov    %dl,-0x7fee8adb(,%eax,8)
80106dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ddc:	0f b6 14 c5 25 75 11 	movzbl -0x7fee8adb(,%eax,8),%edx
80106de3:	80 
80106de4:	83 e2 ef             	and    $0xffffffef,%edx
80106de7:	88 14 c5 25 75 11 80 	mov    %dl,-0x7fee8adb(,%eax,8)
80106dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106df1:	0f b6 14 c5 25 75 11 	movzbl -0x7fee8adb(,%eax,8),%edx
80106df8:	80 
80106df9:	83 e2 9f             	and    $0xffffff9f,%edx
80106dfc:	88 14 c5 25 75 11 80 	mov    %dl,-0x7fee8adb(,%eax,8)
80106e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e06:	0f b6 14 c5 25 75 11 	movzbl -0x7fee8adb(,%eax,8),%edx
80106e0d:	80 
80106e0e:	83 ca 80             	or     $0xffffff80,%edx
80106e11:	88 14 c5 25 75 11 80 	mov    %dl,-0x7fee8adb(,%eax,8)
80106e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e1b:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
80106e22:	c1 e8 10             	shr    $0x10,%eax
80106e25:	89 c2                	mov    %eax,%edx
80106e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e2a:	66 89 14 c5 26 75 11 	mov    %dx,-0x7fee8ada(,%eax,8)
80106e31:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106e32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e36:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106e3d:	0f 8e 30 ff ff ff    	jle    80106d73 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106e43:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80106e48:	66 a3 20 77 11 80    	mov    %ax,0x80117720
80106e4e:	66 c7 05 22 77 11 80 	movw   $0x8,0x80117722
80106e55:	08 00 
80106e57:	0f b6 05 24 77 11 80 	movzbl 0x80117724,%eax
80106e5e:	83 e0 e0             	and    $0xffffffe0,%eax
80106e61:	a2 24 77 11 80       	mov    %al,0x80117724
80106e66:	0f b6 05 24 77 11 80 	movzbl 0x80117724,%eax
80106e6d:	83 e0 1f             	and    $0x1f,%eax
80106e70:	a2 24 77 11 80       	mov    %al,0x80117724
80106e75:	0f b6 05 25 77 11 80 	movzbl 0x80117725,%eax
80106e7c:	83 c8 0f             	or     $0xf,%eax
80106e7f:	a2 25 77 11 80       	mov    %al,0x80117725
80106e84:	0f b6 05 25 77 11 80 	movzbl 0x80117725,%eax
80106e8b:	83 e0 ef             	and    $0xffffffef,%eax
80106e8e:	a2 25 77 11 80       	mov    %al,0x80117725
80106e93:	0f b6 05 25 77 11 80 	movzbl 0x80117725,%eax
80106e9a:	83 c8 60             	or     $0x60,%eax
80106e9d:	a2 25 77 11 80       	mov    %al,0x80117725
80106ea2:	0f b6 05 25 77 11 80 	movzbl 0x80117725,%eax
80106ea9:	83 c8 80             	or     $0xffffff80,%eax
80106eac:	a2 25 77 11 80       	mov    %al,0x80117725
80106eb1:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80106eb6:	c1 e8 10             	shr    $0x10,%eax
80106eb9:	66 a3 26 77 11 80    	mov    %ax,0x80117726
  
  initlock(&tickslock, "time");
80106ebf:	c7 44 24 04 08 93 10 	movl   $0x80109308,0x4(%esp)
80106ec6:	80 
80106ec7:	c7 04 24 e0 74 11 80 	movl   $0x801174e0,(%esp)
80106ece:	e8 6a e7 ff ff       	call   8010563d <initlock>
}
80106ed3:	c9                   	leave  
80106ed4:	c3                   	ret    

80106ed5 <idtinit>:

void
idtinit(void)
{
80106ed5:	55                   	push   %ebp
80106ed6:	89 e5                	mov    %esp,%ebp
80106ed8:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106edb:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106ee2:	00 
80106ee3:	c7 04 24 20 75 11 80 	movl   $0x80117520,(%esp)
80106eea:	e8 38 fe ff ff       	call   80106d27 <lidt>
}
80106eef:	c9                   	leave  
80106ef0:	c3                   	ret    

80106ef1 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106ef1:	55                   	push   %ebp
80106ef2:	89 e5                	mov    %esp,%ebp
80106ef4:	57                   	push   %edi
80106ef5:	56                   	push   %esi
80106ef6:	53                   	push   %ebx
80106ef7:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106efa:	8b 45 08             	mov    0x8(%ebp),%eax
80106efd:	8b 40 30             	mov    0x30(%eax),%eax
80106f00:	83 f8 40             	cmp    $0x40,%eax
80106f03:	75 3f                	jne    80106f44 <trap+0x53>
    if(proc->killed)
80106f05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f0b:	8b 40 24             	mov    0x24(%eax),%eax
80106f0e:	85 c0                	test   %eax,%eax
80106f10:	74 05                	je     80106f17 <trap+0x26>
      exit();
80106f12:	e8 90 e0 ff ff       	call   80104fa7 <exit>
    proc->tf = tf;
80106f17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f1d:	8b 55 08             	mov    0x8(%ebp),%edx
80106f20:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106f23:	e8 93 ed ff ff       	call   80105cbb <syscall>
    if(proc->killed)
80106f28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f2e:	8b 40 24             	mov    0x24(%eax),%eax
80106f31:	85 c0                	test   %eax,%eax
80106f33:	74 0a                	je     80106f3f <trap+0x4e>
      exit();
80106f35:	e8 6d e0 ff ff       	call   80104fa7 <exit>
    return;
80106f3a:	e9 2d 02 00 00       	jmp    8010716c <trap+0x27b>
80106f3f:	e9 28 02 00 00       	jmp    8010716c <trap+0x27b>
  }

  switch(tf->trapno){
80106f44:	8b 45 08             	mov    0x8(%ebp),%eax
80106f47:	8b 40 30             	mov    0x30(%eax),%eax
80106f4a:	83 e8 20             	sub    $0x20,%eax
80106f4d:	83 f8 1f             	cmp    $0x1f,%eax
80106f50:	0f 87 bc 00 00 00    	ja     80107012 <trap+0x121>
80106f56:	8b 04 85 b0 93 10 80 	mov    -0x7fef6c50(,%eax,4),%eax
80106f5d:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106f5f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106f65:	0f b6 00             	movzbl (%eax),%eax
80106f68:	84 c0                	test   %al,%al
80106f6a:	75 31                	jne    80106f9d <trap+0xac>
      acquire(&tickslock);
80106f6c:	c7 04 24 e0 74 11 80 	movl   $0x801174e0,(%esp)
80106f73:	e8 e6 e6 ff ff       	call   8010565e <acquire>
      ticks++;
80106f78:	a1 20 7d 11 80       	mov    0x80117d20,%eax
80106f7d:	83 c0 01             	add    $0x1,%eax
80106f80:	a3 20 7d 11 80       	mov    %eax,0x80117d20
      wakeup(&ticks);
80106f85:	c7 04 24 20 7d 11 80 	movl   $0x80117d20,(%esp)
80106f8c:	e8 dc e4 ff ff       	call   8010546d <wakeup>
      release(&tickslock);
80106f91:	c7 04 24 e0 74 11 80 	movl   $0x801174e0,(%esp)
80106f98:	e8 23 e7 ff ff       	call   801056c0 <release>
    }
    lapiceoi();
80106f9d:	e8 9b c7 ff ff       	call   8010373d <lapiceoi>
    break;
80106fa2:	e9 41 01 00 00       	jmp    801070e8 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106fa7:	e8 9f bf ff ff       	call   80102f4b <ideintr>
    lapiceoi();
80106fac:	e8 8c c7 ff ff       	call   8010373d <lapiceoi>
    break;
80106fb1:	e9 32 01 00 00       	jmp    801070e8 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106fb6:	e8 51 c5 ff ff       	call   8010350c <kbdintr>
    lapiceoi();
80106fbb:	e8 7d c7 ff ff       	call   8010373d <lapiceoi>
    break;
80106fc0:	e9 23 01 00 00       	jmp    801070e8 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106fc5:	e8 97 03 00 00       	call   80107361 <uartintr>
    lapiceoi();
80106fca:	e8 6e c7 ff ff       	call   8010373d <lapiceoi>
    break;
80106fcf:	e9 14 01 00 00       	jmp    801070e8 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80106fd7:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106fda:	8b 45 08             	mov    0x8(%ebp),%eax
80106fdd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106fe1:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106fe4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106fea:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106fed:	0f b6 c0             	movzbl %al,%eax
80106ff0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ff4:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ffc:	c7 04 24 10 93 10 80 	movl   $0x80109310,(%esp)
80107003:	e8 98 93 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107008:	e8 30 c7 ff ff       	call   8010373d <lapiceoi>
    break;
8010700d:	e9 d6 00 00 00       	jmp    801070e8 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107012:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107018:	85 c0                	test   %eax,%eax
8010701a:	74 11                	je     8010702d <trap+0x13c>
8010701c:	8b 45 08             	mov    0x8(%ebp),%eax
8010701f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107023:	0f b7 c0             	movzwl %ax,%eax
80107026:	83 e0 03             	and    $0x3,%eax
80107029:	85 c0                	test   %eax,%eax
8010702b:	75 46                	jne    80107073 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010702d:	e8 1e fd ff ff       	call   80106d50 <rcr2>
80107032:	8b 55 08             	mov    0x8(%ebp),%edx
80107035:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107038:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010703f:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107042:	0f b6 ca             	movzbl %dl,%ecx
80107045:	8b 55 08             	mov    0x8(%ebp),%edx
80107048:	8b 52 30             	mov    0x30(%edx),%edx
8010704b:	89 44 24 10          	mov    %eax,0x10(%esp)
8010704f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80107053:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107057:	89 54 24 04          	mov    %edx,0x4(%esp)
8010705b:	c7 04 24 34 93 10 80 	movl   $0x80109334,(%esp)
80107062:	e8 39 93 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107067:	c7 04 24 66 93 10 80 	movl   $0x80109366,(%esp)
8010706e:	e8 c7 94 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107073:	e8 d8 fc ff ff       	call   80106d50 <rcr2>
80107078:	89 c2                	mov    %eax,%edx
8010707a:	8b 45 08             	mov    0x8(%ebp),%eax
8010707d:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107080:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107086:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107089:	0f b6 f0             	movzbl %al,%esi
8010708c:	8b 45 08             	mov    0x8(%ebp),%eax
8010708f:	8b 58 34             	mov    0x34(%eax),%ebx
80107092:	8b 45 08             	mov    0x8(%ebp),%eax
80107095:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107098:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010709e:	83 c0 6c             	add    $0x6c,%eax
801070a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801070a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801070aa:	8b 40 10             	mov    0x10(%eax),%eax
801070ad:	89 54 24 1c          	mov    %edx,0x1c(%esp)
801070b1:	89 7c 24 18          	mov    %edi,0x18(%esp)
801070b5:	89 74 24 14          	mov    %esi,0x14(%esp)
801070b9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801070bd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801070c1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801070c4:	89 74 24 08          	mov    %esi,0x8(%esp)
801070c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801070cc:	c7 04 24 6c 93 10 80 	movl   $0x8010936c,(%esp)
801070d3:	e8 c8 92 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801070d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070de:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801070e5:	eb 01                	jmp    801070e8 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801070e7:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801070e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070ee:	85 c0                	test   %eax,%eax
801070f0:	74 24                	je     80107116 <trap+0x225>
801070f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070f8:	8b 40 24             	mov    0x24(%eax),%eax
801070fb:	85 c0                	test   %eax,%eax
801070fd:	74 17                	je     80107116 <trap+0x225>
801070ff:	8b 45 08             	mov    0x8(%ebp),%eax
80107102:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107106:	0f b7 c0             	movzwl %ax,%eax
80107109:	83 e0 03             	and    $0x3,%eax
8010710c:	83 f8 03             	cmp    $0x3,%eax
8010710f:	75 05                	jne    80107116 <trap+0x225>
    exit();
80107111:	e8 91 de ff ff       	call   80104fa7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107116:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010711c:	85 c0                	test   %eax,%eax
8010711e:	74 1e                	je     8010713e <trap+0x24d>
80107120:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107126:	8b 40 0c             	mov    0xc(%eax),%eax
80107129:	83 f8 04             	cmp    $0x4,%eax
8010712c:	75 10                	jne    8010713e <trap+0x24d>
8010712e:	8b 45 08             	mov    0x8(%ebp),%eax
80107131:	8b 40 30             	mov    0x30(%eax),%eax
80107134:	83 f8 20             	cmp    $0x20,%eax
80107137:	75 05                	jne    8010713e <trap+0x24d>
    yield();
80107139:	e8 e4 e1 ff ff       	call   80105322 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010713e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107144:	85 c0                	test   %eax,%eax
80107146:	74 24                	je     8010716c <trap+0x27b>
80107148:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010714e:	8b 40 24             	mov    0x24(%eax),%eax
80107151:	85 c0                	test   %eax,%eax
80107153:	74 17                	je     8010716c <trap+0x27b>
80107155:	8b 45 08             	mov    0x8(%ebp),%eax
80107158:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010715c:	0f b7 c0             	movzwl %ax,%eax
8010715f:	83 e0 03             	and    $0x3,%eax
80107162:	83 f8 03             	cmp    $0x3,%eax
80107165:	75 05                	jne    8010716c <trap+0x27b>
    exit();
80107167:	e8 3b de ff ff       	call   80104fa7 <exit>
}
8010716c:	83 c4 3c             	add    $0x3c,%esp
8010716f:	5b                   	pop    %ebx
80107170:	5e                   	pop    %esi
80107171:	5f                   	pop    %edi
80107172:	5d                   	pop    %ebp
80107173:	c3                   	ret    

80107174 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107174:	55                   	push   %ebp
80107175:	89 e5                	mov    %esp,%ebp
80107177:	83 ec 14             	sub    $0x14,%esp
8010717a:	8b 45 08             	mov    0x8(%ebp),%eax
8010717d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107181:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107185:	89 c2                	mov    %eax,%edx
80107187:	ec                   	in     (%dx),%al
80107188:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010718b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010718f:	c9                   	leave  
80107190:	c3                   	ret    

80107191 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107191:	55                   	push   %ebp
80107192:	89 e5                	mov    %esp,%ebp
80107194:	83 ec 08             	sub    $0x8,%esp
80107197:	8b 55 08             	mov    0x8(%ebp),%edx
8010719a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010719d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801071a1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801071a4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801071a8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801071ac:	ee                   	out    %al,(%dx)
}
801071ad:	c9                   	leave  
801071ae:	c3                   	ret    

801071af <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801071af:	55                   	push   %ebp
801071b0:	89 e5                	mov    %esp,%ebp
801071b2:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801071b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801071bc:	00 
801071bd:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801071c4:	e8 c8 ff ff ff       	call   80107191 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801071c9:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801071d0:	00 
801071d1:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801071d8:	e8 b4 ff ff ff       	call   80107191 <outb>
  outb(COM1+0, 115200/9600);
801071dd:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801071e4:	00 
801071e5:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801071ec:	e8 a0 ff ff ff       	call   80107191 <outb>
  outb(COM1+1, 0);
801071f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801071f8:	00 
801071f9:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107200:	e8 8c ff ff ff       	call   80107191 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107205:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010720c:	00 
8010720d:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107214:	e8 78 ff ff ff       	call   80107191 <outb>
  outb(COM1+4, 0);
80107219:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107220:	00 
80107221:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107228:	e8 64 ff ff ff       	call   80107191 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010722d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107234:	00 
80107235:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010723c:	e8 50 ff ff ff       	call   80107191 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107241:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107248:	e8 27 ff ff ff       	call   80107174 <inb>
8010724d:	3c ff                	cmp    $0xff,%al
8010724f:	75 02                	jne    80107253 <uartinit+0xa4>
    return;
80107251:	eb 6a                	jmp    801072bd <uartinit+0x10e>
  uart = 1;
80107253:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
8010725a:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010725d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107264:	e8 0b ff ff ff       	call   80107174 <inb>
  inb(COM1+0);
80107269:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107270:	e8 ff fe ff ff       	call   80107174 <inb>
  picenable(IRQ_COM1);
80107275:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010727c:	e8 93 d3 ff ff       	call   80104614 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107281:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107288:	00 
80107289:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107290:	e8 35 bf ff ff       	call   801031ca <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107295:	c7 45 f4 30 94 10 80 	movl   $0x80109430,-0xc(%ebp)
8010729c:	eb 15                	jmp    801072b3 <uartinit+0x104>
    uartputc(*p);
8010729e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a1:	0f b6 00             	movzbl (%eax),%eax
801072a4:	0f be c0             	movsbl %al,%eax
801072a7:	89 04 24             	mov    %eax,(%esp)
801072aa:	e8 10 00 00 00       	call   801072bf <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801072af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801072b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b6:	0f b6 00             	movzbl (%eax),%eax
801072b9:	84 c0                	test   %al,%al
801072bb:	75 e1                	jne    8010729e <uartinit+0xef>
    uartputc(*p);
}
801072bd:	c9                   	leave  
801072be:	c3                   	ret    

801072bf <uartputc>:

void
uartputc(int c)
{
801072bf:	55                   	push   %ebp
801072c0:	89 e5                	mov    %esp,%ebp
801072c2:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801072c5:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
801072ca:	85 c0                	test   %eax,%eax
801072cc:	75 02                	jne    801072d0 <uartputc+0x11>
    return;
801072ce:	eb 4b                	jmp    8010731b <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801072d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801072d7:	eb 10                	jmp    801072e9 <uartputc+0x2a>
    microdelay(10);
801072d9:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801072e0:	e8 7d c4 ff ff       	call   80103762 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801072e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801072e9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801072ed:	7f 16                	jg     80107305 <uartputc+0x46>
801072ef:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801072f6:	e8 79 fe ff ff       	call   80107174 <inb>
801072fb:	0f b6 c0             	movzbl %al,%eax
801072fe:	83 e0 20             	and    $0x20,%eax
80107301:	85 c0                	test   %eax,%eax
80107303:	74 d4                	je     801072d9 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107305:	8b 45 08             	mov    0x8(%ebp),%eax
80107308:	0f b6 c0             	movzbl %al,%eax
8010730b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010730f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107316:	e8 76 fe ff ff       	call   80107191 <outb>
}
8010731b:	c9                   	leave  
8010731c:	c3                   	ret    

8010731d <uartgetc>:

static int
uartgetc(void)
{
8010731d:	55                   	push   %ebp
8010731e:	89 e5                	mov    %esp,%ebp
80107320:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107323:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107328:	85 c0                	test   %eax,%eax
8010732a:	75 07                	jne    80107333 <uartgetc+0x16>
    return -1;
8010732c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107331:	eb 2c                	jmp    8010735f <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107333:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010733a:	e8 35 fe ff ff       	call   80107174 <inb>
8010733f:	0f b6 c0             	movzbl %al,%eax
80107342:	83 e0 01             	and    $0x1,%eax
80107345:	85 c0                	test   %eax,%eax
80107347:	75 07                	jne    80107350 <uartgetc+0x33>
    return -1;
80107349:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010734e:	eb 0f                	jmp    8010735f <uartgetc+0x42>
  return inb(COM1+0);
80107350:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107357:	e8 18 fe ff ff       	call   80107174 <inb>
8010735c:	0f b6 c0             	movzbl %al,%eax
}
8010735f:	c9                   	leave  
80107360:	c3                   	ret    

80107361 <uartintr>:

void
uartintr(void)
{
80107361:	55                   	push   %ebp
80107362:	89 e5                	mov    %esp,%ebp
80107364:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107367:	c7 04 24 1d 73 10 80 	movl   $0x8010731d,(%esp)
8010736e:	e8 55 94 ff ff       	call   801007c8 <consoleintr>
}
80107373:	c9                   	leave  
80107374:	c3                   	ret    

80107375 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $0
80107377:	6a 00                	push   $0x0
  jmp alltraps
80107379:	e9 7e f9 ff ff       	jmp    80106cfc <alltraps>

8010737e <vector1>:
.globl vector1
vector1:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $1
80107380:	6a 01                	push   $0x1
  jmp alltraps
80107382:	e9 75 f9 ff ff       	jmp    80106cfc <alltraps>

80107387 <vector2>:
.globl vector2
vector2:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $2
80107389:	6a 02                	push   $0x2
  jmp alltraps
8010738b:	e9 6c f9 ff ff       	jmp    80106cfc <alltraps>

80107390 <vector3>:
.globl vector3
vector3:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $3
80107392:	6a 03                	push   $0x3
  jmp alltraps
80107394:	e9 63 f9 ff ff       	jmp    80106cfc <alltraps>

80107399 <vector4>:
.globl vector4
vector4:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $4
8010739b:	6a 04                	push   $0x4
  jmp alltraps
8010739d:	e9 5a f9 ff ff       	jmp    80106cfc <alltraps>

801073a2 <vector5>:
.globl vector5
vector5:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $5
801073a4:	6a 05                	push   $0x5
  jmp alltraps
801073a6:	e9 51 f9 ff ff       	jmp    80106cfc <alltraps>

801073ab <vector6>:
.globl vector6
vector6:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $6
801073ad:	6a 06                	push   $0x6
  jmp alltraps
801073af:	e9 48 f9 ff ff       	jmp    80106cfc <alltraps>

801073b4 <vector7>:
.globl vector7
vector7:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $7
801073b6:	6a 07                	push   $0x7
  jmp alltraps
801073b8:	e9 3f f9 ff ff       	jmp    80106cfc <alltraps>

801073bd <vector8>:
.globl vector8
vector8:
  pushl $8
801073bd:	6a 08                	push   $0x8
  jmp alltraps
801073bf:	e9 38 f9 ff ff       	jmp    80106cfc <alltraps>

801073c4 <vector9>:
.globl vector9
vector9:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $9
801073c6:	6a 09                	push   $0x9
  jmp alltraps
801073c8:	e9 2f f9 ff ff       	jmp    80106cfc <alltraps>

801073cd <vector10>:
.globl vector10
vector10:
  pushl $10
801073cd:	6a 0a                	push   $0xa
  jmp alltraps
801073cf:	e9 28 f9 ff ff       	jmp    80106cfc <alltraps>

801073d4 <vector11>:
.globl vector11
vector11:
  pushl $11
801073d4:	6a 0b                	push   $0xb
  jmp alltraps
801073d6:	e9 21 f9 ff ff       	jmp    80106cfc <alltraps>

801073db <vector12>:
.globl vector12
vector12:
  pushl $12
801073db:	6a 0c                	push   $0xc
  jmp alltraps
801073dd:	e9 1a f9 ff ff       	jmp    80106cfc <alltraps>

801073e2 <vector13>:
.globl vector13
vector13:
  pushl $13
801073e2:	6a 0d                	push   $0xd
  jmp alltraps
801073e4:	e9 13 f9 ff ff       	jmp    80106cfc <alltraps>

801073e9 <vector14>:
.globl vector14
vector14:
  pushl $14
801073e9:	6a 0e                	push   $0xe
  jmp alltraps
801073eb:	e9 0c f9 ff ff       	jmp    80106cfc <alltraps>

801073f0 <vector15>:
.globl vector15
vector15:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $15
801073f2:	6a 0f                	push   $0xf
  jmp alltraps
801073f4:	e9 03 f9 ff ff       	jmp    80106cfc <alltraps>

801073f9 <vector16>:
.globl vector16
vector16:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $16
801073fb:	6a 10                	push   $0x10
  jmp alltraps
801073fd:	e9 fa f8 ff ff       	jmp    80106cfc <alltraps>

80107402 <vector17>:
.globl vector17
vector17:
  pushl $17
80107402:	6a 11                	push   $0x11
  jmp alltraps
80107404:	e9 f3 f8 ff ff       	jmp    80106cfc <alltraps>

80107409 <vector18>:
.globl vector18
vector18:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $18
8010740b:	6a 12                	push   $0x12
  jmp alltraps
8010740d:	e9 ea f8 ff ff       	jmp    80106cfc <alltraps>

80107412 <vector19>:
.globl vector19
vector19:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $19
80107414:	6a 13                	push   $0x13
  jmp alltraps
80107416:	e9 e1 f8 ff ff       	jmp    80106cfc <alltraps>

8010741b <vector20>:
.globl vector20
vector20:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $20
8010741d:	6a 14                	push   $0x14
  jmp alltraps
8010741f:	e9 d8 f8 ff ff       	jmp    80106cfc <alltraps>

80107424 <vector21>:
.globl vector21
vector21:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $21
80107426:	6a 15                	push   $0x15
  jmp alltraps
80107428:	e9 cf f8 ff ff       	jmp    80106cfc <alltraps>

8010742d <vector22>:
.globl vector22
vector22:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $22
8010742f:	6a 16                	push   $0x16
  jmp alltraps
80107431:	e9 c6 f8 ff ff       	jmp    80106cfc <alltraps>

80107436 <vector23>:
.globl vector23
vector23:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $23
80107438:	6a 17                	push   $0x17
  jmp alltraps
8010743a:	e9 bd f8 ff ff       	jmp    80106cfc <alltraps>

8010743f <vector24>:
.globl vector24
vector24:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $24
80107441:	6a 18                	push   $0x18
  jmp alltraps
80107443:	e9 b4 f8 ff ff       	jmp    80106cfc <alltraps>

80107448 <vector25>:
.globl vector25
vector25:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $25
8010744a:	6a 19                	push   $0x19
  jmp alltraps
8010744c:	e9 ab f8 ff ff       	jmp    80106cfc <alltraps>

80107451 <vector26>:
.globl vector26
vector26:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $26
80107453:	6a 1a                	push   $0x1a
  jmp alltraps
80107455:	e9 a2 f8 ff ff       	jmp    80106cfc <alltraps>

8010745a <vector27>:
.globl vector27
vector27:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $27
8010745c:	6a 1b                	push   $0x1b
  jmp alltraps
8010745e:	e9 99 f8 ff ff       	jmp    80106cfc <alltraps>

80107463 <vector28>:
.globl vector28
vector28:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $28
80107465:	6a 1c                	push   $0x1c
  jmp alltraps
80107467:	e9 90 f8 ff ff       	jmp    80106cfc <alltraps>

8010746c <vector29>:
.globl vector29
vector29:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $29
8010746e:	6a 1d                	push   $0x1d
  jmp alltraps
80107470:	e9 87 f8 ff ff       	jmp    80106cfc <alltraps>

80107475 <vector30>:
.globl vector30
vector30:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $30
80107477:	6a 1e                	push   $0x1e
  jmp alltraps
80107479:	e9 7e f8 ff ff       	jmp    80106cfc <alltraps>

8010747e <vector31>:
.globl vector31
vector31:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $31
80107480:	6a 1f                	push   $0x1f
  jmp alltraps
80107482:	e9 75 f8 ff ff       	jmp    80106cfc <alltraps>

80107487 <vector32>:
.globl vector32
vector32:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $32
80107489:	6a 20                	push   $0x20
  jmp alltraps
8010748b:	e9 6c f8 ff ff       	jmp    80106cfc <alltraps>

80107490 <vector33>:
.globl vector33
vector33:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $33
80107492:	6a 21                	push   $0x21
  jmp alltraps
80107494:	e9 63 f8 ff ff       	jmp    80106cfc <alltraps>

80107499 <vector34>:
.globl vector34
vector34:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $34
8010749b:	6a 22                	push   $0x22
  jmp alltraps
8010749d:	e9 5a f8 ff ff       	jmp    80106cfc <alltraps>

801074a2 <vector35>:
.globl vector35
vector35:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $35
801074a4:	6a 23                	push   $0x23
  jmp alltraps
801074a6:	e9 51 f8 ff ff       	jmp    80106cfc <alltraps>

801074ab <vector36>:
.globl vector36
vector36:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $36
801074ad:	6a 24                	push   $0x24
  jmp alltraps
801074af:	e9 48 f8 ff ff       	jmp    80106cfc <alltraps>

801074b4 <vector37>:
.globl vector37
vector37:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $37
801074b6:	6a 25                	push   $0x25
  jmp alltraps
801074b8:	e9 3f f8 ff ff       	jmp    80106cfc <alltraps>

801074bd <vector38>:
.globl vector38
vector38:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $38
801074bf:	6a 26                	push   $0x26
  jmp alltraps
801074c1:	e9 36 f8 ff ff       	jmp    80106cfc <alltraps>

801074c6 <vector39>:
.globl vector39
vector39:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $39
801074c8:	6a 27                	push   $0x27
  jmp alltraps
801074ca:	e9 2d f8 ff ff       	jmp    80106cfc <alltraps>

801074cf <vector40>:
.globl vector40
vector40:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $40
801074d1:	6a 28                	push   $0x28
  jmp alltraps
801074d3:	e9 24 f8 ff ff       	jmp    80106cfc <alltraps>

801074d8 <vector41>:
.globl vector41
vector41:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $41
801074da:	6a 29                	push   $0x29
  jmp alltraps
801074dc:	e9 1b f8 ff ff       	jmp    80106cfc <alltraps>

801074e1 <vector42>:
.globl vector42
vector42:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $42
801074e3:	6a 2a                	push   $0x2a
  jmp alltraps
801074e5:	e9 12 f8 ff ff       	jmp    80106cfc <alltraps>

801074ea <vector43>:
.globl vector43
vector43:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $43
801074ec:	6a 2b                	push   $0x2b
  jmp alltraps
801074ee:	e9 09 f8 ff ff       	jmp    80106cfc <alltraps>

801074f3 <vector44>:
.globl vector44
vector44:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $44
801074f5:	6a 2c                	push   $0x2c
  jmp alltraps
801074f7:	e9 00 f8 ff ff       	jmp    80106cfc <alltraps>

801074fc <vector45>:
.globl vector45
vector45:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $45
801074fe:	6a 2d                	push   $0x2d
  jmp alltraps
80107500:	e9 f7 f7 ff ff       	jmp    80106cfc <alltraps>

80107505 <vector46>:
.globl vector46
vector46:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $46
80107507:	6a 2e                	push   $0x2e
  jmp alltraps
80107509:	e9 ee f7 ff ff       	jmp    80106cfc <alltraps>

8010750e <vector47>:
.globl vector47
vector47:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $47
80107510:	6a 2f                	push   $0x2f
  jmp alltraps
80107512:	e9 e5 f7 ff ff       	jmp    80106cfc <alltraps>

80107517 <vector48>:
.globl vector48
vector48:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $48
80107519:	6a 30                	push   $0x30
  jmp alltraps
8010751b:	e9 dc f7 ff ff       	jmp    80106cfc <alltraps>

80107520 <vector49>:
.globl vector49
vector49:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $49
80107522:	6a 31                	push   $0x31
  jmp alltraps
80107524:	e9 d3 f7 ff ff       	jmp    80106cfc <alltraps>

80107529 <vector50>:
.globl vector50
vector50:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $50
8010752b:	6a 32                	push   $0x32
  jmp alltraps
8010752d:	e9 ca f7 ff ff       	jmp    80106cfc <alltraps>

80107532 <vector51>:
.globl vector51
vector51:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $51
80107534:	6a 33                	push   $0x33
  jmp alltraps
80107536:	e9 c1 f7 ff ff       	jmp    80106cfc <alltraps>

8010753b <vector52>:
.globl vector52
vector52:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $52
8010753d:	6a 34                	push   $0x34
  jmp alltraps
8010753f:	e9 b8 f7 ff ff       	jmp    80106cfc <alltraps>

80107544 <vector53>:
.globl vector53
vector53:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $53
80107546:	6a 35                	push   $0x35
  jmp alltraps
80107548:	e9 af f7 ff ff       	jmp    80106cfc <alltraps>

8010754d <vector54>:
.globl vector54
vector54:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $54
8010754f:	6a 36                	push   $0x36
  jmp alltraps
80107551:	e9 a6 f7 ff ff       	jmp    80106cfc <alltraps>

80107556 <vector55>:
.globl vector55
vector55:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $55
80107558:	6a 37                	push   $0x37
  jmp alltraps
8010755a:	e9 9d f7 ff ff       	jmp    80106cfc <alltraps>

8010755f <vector56>:
.globl vector56
vector56:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $56
80107561:	6a 38                	push   $0x38
  jmp alltraps
80107563:	e9 94 f7 ff ff       	jmp    80106cfc <alltraps>

80107568 <vector57>:
.globl vector57
vector57:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $57
8010756a:	6a 39                	push   $0x39
  jmp alltraps
8010756c:	e9 8b f7 ff ff       	jmp    80106cfc <alltraps>

80107571 <vector58>:
.globl vector58
vector58:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $58
80107573:	6a 3a                	push   $0x3a
  jmp alltraps
80107575:	e9 82 f7 ff ff       	jmp    80106cfc <alltraps>

8010757a <vector59>:
.globl vector59
vector59:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $59
8010757c:	6a 3b                	push   $0x3b
  jmp alltraps
8010757e:	e9 79 f7 ff ff       	jmp    80106cfc <alltraps>

80107583 <vector60>:
.globl vector60
vector60:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $60
80107585:	6a 3c                	push   $0x3c
  jmp alltraps
80107587:	e9 70 f7 ff ff       	jmp    80106cfc <alltraps>

8010758c <vector61>:
.globl vector61
vector61:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $61
8010758e:	6a 3d                	push   $0x3d
  jmp alltraps
80107590:	e9 67 f7 ff ff       	jmp    80106cfc <alltraps>

80107595 <vector62>:
.globl vector62
vector62:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $62
80107597:	6a 3e                	push   $0x3e
  jmp alltraps
80107599:	e9 5e f7 ff ff       	jmp    80106cfc <alltraps>

8010759e <vector63>:
.globl vector63
vector63:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $63
801075a0:	6a 3f                	push   $0x3f
  jmp alltraps
801075a2:	e9 55 f7 ff ff       	jmp    80106cfc <alltraps>

801075a7 <vector64>:
.globl vector64
vector64:
  pushl $0
801075a7:	6a 00                	push   $0x0
  pushl $64
801075a9:	6a 40                	push   $0x40
  jmp alltraps
801075ab:	e9 4c f7 ff ff       	jmp    80106cfc <alltraps>

801075b0 <vector65>:
.globl vector65
vector65:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $65
801075b2:	6a 41                	push   $0x41
  jmp alltraps
801075b4:	e9 43 f7 ff ff       	jmp    80106cfc <alltraps>

801075b9 <vector66>:
.globl vector66
vector66:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $66
801075bb:	6a 42                	push   $0x42
  jmp alltraps
801075bd:	e9 3a f7 ff ff       	jmp    80106cfc <alltraps>

801075c2 <vector67>:
.globl vector67
vector67:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $67
801075c4:	6a 43                	push   $0x43
  jmp alltraps
801075c6:	e9 31 f7 ff ff       	jmp    80106cfc <alltraps>

801075cb <vector68>:
.globl vector68
vector68:
  pushl $0
801075cb:	6a 00                	push   $0x0
  pushl $68
801075cd:	6a 44                	push   $0x44
  jmp alltraps
801075cf:	e9 28 f7 ff ff       	jmp    80106cfc <alltraps>

801075d4 <vector69>:
.globl vector69
vector69:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $69
801075d6:	6a 45                	push   $0x45
  jmp alltraps
801075d8:	e9 1f f7 ff ff       	jmp    80106cfc <alltraps>

801075dd <vector70>:
.globl vector70
vector70:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $70
801075df:	6a 46                	push   $0x46
  jmp alltraps
801075e1:	e9 16 f7 ff ff       	jmp    80106cfc <alltraps>

801075e6 <vector71>:
.globl vector71
vector71:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $71
801075e8:	6a 47                	push   $0x47
  jmp alltraps
801075ea:	e9 0d f7 ff ff       	jmp    80106cfc <alltraps>

801075ef <vector72>:
.globl vector72
vector72:
  pushl $0
801075ef:	6a 00                	push   $0x0
  pushl $72
801075f1:	6a 48                	push   $0x48
  jmp alltraps
801075f3:	e9 04 f7 ff ff       	jmp    80106cfc <alltraps>

801075f8 <vector73>:
.globl vector73
vector73:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $73
801075fa:	6a 49                	push   $0x49
  jmp alltraps
801075fc:	e9 fb f6 ff ff       	jmp    80106cfc <alltraps>

80107601 <vector74>:
.globl vector74
vector74:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $74
80107603:	6a 4a                	push   $0x4a
  jmp alltraps
80107605:	e9 f2 f6 ff ff       	jmp    80106cfc <alltraps>

8010760a <vector75>:
.globl vector75
vector75:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $75
8010760c:	6a 4b                	push   $0x4b
  jmp alltraps
8010760e:	e9 e9 f6 ff ff       	jmp    80106cfc <alltraps>

80107613 <vector76>:
.globl vector76
vector76:
  pushl $0
80107613:	6a 00                	push   $0x0
  pushl $76
80107615:	6a 4c                	push   $0x4c
  jmp alltraps
80107617:	e9 e0 f6 ff ff       	jmp    80106cfc <alltraps>

8010761c <vector77>:
.globl vector77
vector77:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $77
8010761e:	6a 4d                	push   $0x4d
  jmp alltraps
80107620:	e9 d7 f6 ff ff       	jmp    80106cfc <alltraps>

80107625 <vector78>:
.globl vector78
vector78:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $78
80107627:	6a 4e                	push   $0x4e
  jmp alltraps
80107629:	e9 ce f6 ff ff       	jmp    80106cfc <alltraps>

8010762e <vector79>:
.globl vector79
vector79:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $79
80107630:	6a 4f                	push   $0x4f
  jmp alltraps
80107632:	e9 c5 f6 ff ff       	jmp    80106cfc <alltraps>

80107637 <vector80>:
.globl vector80
vector80:
  pushl $0
80107637:	6a 00                	push   $0x0
  pushl $80
80107639:	6a 50                	push   $0x50
  jmp alltraps
8010763b:	e9 bc f6 ff ff       	jmp    80106cfc <alltraps>

80107640 <vector81>:
.globl vector81
vector81:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $81
80107642:	6a 51                	push   $0x51
  jmp alltraps
80107644:	e9 b3 f6 ff ff       	jmp    80106cfc <alltraps>

80107649 <vector82>:
.globl vector82
vector82:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $82
8010764b:	6a 52                	push   $0x52
  jmp alltraps
8010764d:	e9 aa f6 ff ff       	jmp    80106cfc <alltraps>

80107652 <vector83>:
.globl vector83
vector83:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $83
80107654:	6a 53                	push   $0x53
  jmp alltraps
80107656:	e9 a1 f6 ff ff       	jmp    80106cfc <alltraps>

8010765b <vector84>:
.globl vector84
vector84:
  pushl $0
8010765b:	6a 00                	push   $0x0
  pushl $84
8010765d:	6a 54                	push   $0x54
  jmp alltraps
8010765f:	e9 98 f6 ff ff       	jmp    80106cfc <alltraps>

80107664 <vector85>:
.globl vector85
vector85:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $85
80107666:	6a 55                	push   $0x55
  jmp alltraps
80107668:	e9 8f f6 ff ff       	jmp    80106cfc <alltraps>

8010766d <vector86>:
.globl vector86
vector86:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $86
8010766f:	6a 56                	push   $0x56
  jmp alltraps
80107671:	e9 86 f6 ff ff       	jmp    80106cfc <alltraps>

80107676 <vector87>:
.globl vector87
vector87:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $87
80107678:	6a 57                	push   $0x57
  jmp alltraps
8010767a:	e9 7d f6 ff ff       	jmp    80106cfc <alltraps>

8010767f <vector88>:
.globl vector88
vector88:
  pushl $0
8010767f:	6a 00                	push   $0x0
  pushl $88
80107681:	6a 58                	push   $0x58
  jmp alltraps
80107683:	e9 74 f6 ff ff       	jmp    80106cfc <alltraps>

80107688 <vector89>:
.globl vector89
vector89:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $89
8010768a:	6a 59                	push   $0x59
  jmp alltraps
8010768c:	e9 6b f6 ff ff       	jmp    80106cfc <alltraps>

80107691 <vector90>:
.globl vector90
vector90:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $90
80107693:	6a 5a                	push   $0x5a
  jmp alltraps
80107695:	e9 62 f6 ff ff       	jmp    80106cfc <alltraps>

8010769a <vector91>:
.globl vector91
vector91:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $91
8010769c:	6a 5b                	push   $0x5b
  jmp alltraps
8010769e:	e9 59 f6 ff ff       	jmp    80106cfc <alltraps>

801076a3 <vector92>:
.globl vector92
vector92:
  pushl $0
801076a3:	6a 00                	push   $0x0
  pushl $92
801076a5:	6a 5c                	push   $0x5c
  jmp alltraps
801076a7:	e9 50 f6 ff ff       	jmp    80106cfc <alltraps>

801076ac <vector93>:
.globl vector93
vector93:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $93
801076ae:	6a 5d                	push   $0x5d
  jmp alltraps
801076b0:	e9 47 f6 ff ff       	jmp    80106cfc <alltraps>

801076b5 <vector94>:
.globl vector94
vector94:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $94
801076b7:	6a 5e                	push   $0x5e
  jmp alltraps
801076b9:	e9 3e f6 ff ff       	jmp    80106cfc <alltraps>

801076be <vector95>:
.globl vector95
vector95:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $95
801076c0:	6a 5f                	push   $0x5f
  jmp alltraps
801076c2:	e9 35 f6 ff ff       	jmp    80106cfc <alltraps>

801076c7 <vector96>:
.globl vector96
vector96:
  pushl $0
801076c7:	6a 00                	push   $0x0
  pushl $96
801076c9:	6a 60                	push   $0x60
  jmp alltraps
801076cb:	e9 2c f6 ff ff       	jmp    80106cfc <alltraps>

801076d0 <vector97>:
.globl vector97
vector97:
  pushl $0
801076d0:	6a 00                	push   $0x0
  pushl $97
801076d2:	6a 61                	push   $0x61
  jmp alltraps
801076d4:	e9 23 f6 ff ff       	jmp    80106cfc <alltraps>

801076d9 <vector98>:
.globl vector98
vector98:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $98
801076db:	6a 62                	push   $0x62
  jmp alltraps
801076dd:	e9 1a f6 ff ff       	jmp    80106cfc <alltraps>

801076e2 <vector99>:
.globl vector99
vector99:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $99
801076e4:	6a 63                	push   $0x63
  jmp alltraps
801076e6:	e9 11 f6 ff ff       	jmp    80106cfc <alltraps>

801076eb <vector100>:
.globl vector100
vector100:
  pushl $0
801076eb:	6a 00                	push   $0x0
  pushl $100
801076ed:	6a 64                	push   $0x64
  jmp alltraps
801076ef:	e9 08 f6 ff ff       	jmp    80106cfc <alltraps>

801076f4 <vector101>:
.globl vector101
vector101:
  pushl $0
801076f4:	6a 00                	push   $0x0
  pushl $101
801076f6:	6a 65                	push   $0x65
  jmp alltraps
801076f8:	e9 ff f5 ff ff       	jmp    80106cfc <alltraps>

801076fd <vector102>:
.globl vector102
vector102:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $102
801076ff:	6a 66                	push   $0x66
  jmp alltraps
80107701:	e9 f6 f5 ff ff       	jmp    80106cfc <alltraps>

80107706 <vector103>:
.globl vector103
vector103:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $103
80107708:	6a 67                	push   $0x67
  jmp alltraps
8010770a:	e9 ed f5 ff ff       	jmp    80106cfc <alltraps>

8010770f <vector104>:
.globl vector104
vector104:
  pushl $0
8010770f:	6a 00                	push   $0x0
  pushl $104
80107711:	6a 68                	push   $0x68
  jmp alltraps
80107713:	e9 e4 f5 ff ff       	jmp    80106cfc <alltraps>

80107718 <vector105>:
.globl vector105
vector105:
  pushl $0
80107718:	6a 00                	push   $0x0
  pushl $105
8010771a:	6a 69                	push   $0x69
  jmp alltraps
8010771c:	e9 db f5 ff ff       	jmp    80106cfc <alltraps>

80107721 <vector106>:
.globl vector106
vector106:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $106
80107723:	6a 6a                	push   $0x6a
  jmp alltraps
80107725:	e9 d2 f5 ff ff       	jmp    80106cfc <alltraps>

8010772a <vector107>:
.globl vector107
vector107:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $107
8010772c:	6a 6b                	push   $0x6b
  jmp alltraps
8010772e:	e9 c9 f5 ff ff       	jmp    80106cfc <alltraps>

80107733 <vector108>:
.globl vector108
vector108:
  pushl $0
80107733:	6a 00                	push   $0x0
  pushl $108
80107735:	6a 6c                	push   $0x6c
  jmp alltraps
80107737:	e9 c0 f5 ff ff       	jmp    80106cfc <alltraps>

8010773c <vector109>:
.globl vector109
vector109:
  pushl $0
8010773c:	6a 00                	push   $0x0
  pushl $109
8010773e:	6a 6d                	push   $0x6d
  jmp alltraps
80107740:	e9 b7 f5 ff ff       	jmp    80106cfc <alltraps>

80107745 <vector110>:
.globl vector110
vector110:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $110
80107747:	6a 6e                	push   $0x6e
  jmp alltraps
80107749:	e9 ae f5 ff ff       	jmp    80106cfc <alltraps>

8010774e <vector111>:
.globl vector111
vector111:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $111
80107750:	6a 6f                	push   $0x6f
  jmp alltraps
80107752:	e9 a5 f5 ff ff       	jmp    80106cfc <alltraps>

80107757 <vector112>:
.globl vector112
vector112:
  pushl $0
80107757:	6a 00                	push   $0x0
  pushl $112
80107759:	6a 70                	push   $0x70
  jmp alltraps
8010775b:	e9 9c f5 ff ff       	jmp    80106cfc <alltraps>

80107760 <vector113>:
.globl vector113
vector113:
  pushl $0
80107760:	6a 00                	push   $0x0
  pushl $113
80107762:	6a 71                	push   $0x71
  jmp alltraps
80107764:	e9 93 f5 ff ff       	jmp    80106cfc <alltraps>

80107769 <vector114>:
.globl vector114
vector114:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $114
8010776b:	6a 72                	push   $0x72
  jmp alltraps
8010776d:	e9 8a f5 ff ff       	jmp    80106cfc <alltraps>

80107772 <vector115>:
.globl vector115
vector115:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $115
80107774:	6a 73                	push   $0x73
  jmp alltraps
80107776:	e9 81 f5 ff ff       	jmp    80106cfc <alltraps>

8010777b <vector116>:
.globl vector116
vector116:
  pushl $0
8010777b:	6a 00                	push   $0x0
  pushl $116
8010777d:	6a 74                	push   $0x74
  jmp alltraps
8010777f:	e9 78 f5 ff ff       	jmp    80106cfc <alltraps>

80107784 <vector117>:
.globl vector117
vector117:
  pushl $0
80107784:	6a 00                	push   $0x0
  pushl $117
80107786:	6a 75                	push   $0x75
  jmp alltraps
80107788:	e9 6f f5 ff ff       	jmp    80106cfc <alltraps>

8010778d <vector118>:
.globl vector118
vector118:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $118
8010778f:	6a 76                	push   $0x76
  jmp alltraps
80107791:	e9 66 f5 ff ff       	jmp    80106cfc <alltraps>

80107796 <vector119>:
.globl vector119
vector119:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $119
80107798:	6a 77                	push   $0x77
  jmp alltraps
8010779a:	e9 5d f5 ff ff       	jmp    80106cfc <alltraps>

8010779f <vector120>:
.globl vector120
vector120:
  pushl $0
8010779f:	6a 00                	push   $0x0
  pushl $120
801077a1:	6a 78                	push   $0x78
  jmp alltraps
801077a3:	e9 54 f5 ff ff       	jmp    80106cfc <alltraps>

801077a8 <vector121>:
.globl vector121
vector121:
  pushl $0
801077a8:	6a 00                	push   $0x0
  pushl $121
801077aa:	6a 79                	push   $0x79
  jmp alltraps
801077ac:	e9 4b f5 ff ff       	jmp    80106cfc <alltraps>

801077b1 <vector122>:
.globl vector122
vector122:
  pushl $0
801077b1:	6a 00                	push   $0x0
  pushl $122
801077b3:	6a 7a                	push   $0x7a
  jmp alltraps
801077b5:	e9 42 f5 ff ff       	jmp    80106cfc <alltraps>

801077ba <vector123>:
.globl vector123
vector123:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $123
801077bc:	6a 7b                	push   $0x7b
  jmp alltraps
801077be:	e9 39 f5 ff ff       	jmp    80106cfc <alltraps>

801077c3 <vector124>:
.globl vector124
vector124:
  pushl $0
801077c3:	6a 00                	push   $0x0
  pushl $124
801077c5:	6a 7c                	push   $0x7c
  jmp alltraps
801077c7:	e9 30 f5 ff ff       	jmp    80106cfc <alltraps>

801077cc <vector125>:
.globl vector125
vector125:
  pushl $0
801077cc:	6a 00                	push   $0x0
  pushl $125
801077ce:	6a 7d                	push   $0x7d
  jmp alltraps
801077d0:	e9 27 f5 ff ff       	jmp    80106cfc <alltraps>

801077d5 <vector126>:
.globl vector126
vector126:
  pushl $0
801077d5:	6a 00                	push   $0x0
  pushl $126
801077d7:	6a 7e                	push   $0x7e
  jmp alltraps
801077d9:	e9 1e f5 ff ff       	jmp    80106cfc <alltraps>

801077de <vector127>:
.globl vector127
vector127:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $127
801077e0:	6a 7f                	push   $0x7f
  jmp alltraps
801077e2:	e9 15 f5 ff ff       	jmp    80106cfc <alltraps>

801077e7 <vector128>:
.globl vector128
vector128:
  pushl $0
801077e7:	6a 00                	push   $0x0
  pushl $128
801077e9:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801077ee:	e9 09 f5 ff ff       	jmp    80106cfc <alltraps>

801077f3 <vector129>:
.globl vector129
vector129:
  pushl $0
801077f3:	6a 00                	push   $0x0
  pushl $129
801077f5:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801077fa:	e9 fd f4 ff ff       	jmp    80106cfc <alltraps>

801077ff <vector130>:
.globl vector130
vector130:
  pushl $0
801077ff:	6a 00                	push   $0x0
  pushl $130
80107801:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107806:	e9 f1 f4 ff ff       	jmp    80106cfc <alltraps>

8010780b <vector131>:
.globl vector131
vector131:
  pushl $0
8010780b:	6a 00                	push   $0x0
  pushl $131
8010780d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107812:	e9 e5 f4 ff ff       	jmp    80106cfc <alltraps>

80107817 <vector132>:
.globl vector132
vector132:
  pushl $0
80107817:	6a 00                	push   $0x0
  pushl $132
80107819:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010781e:	e9 d9 f4 ff ff       	jmp    80106cfc <alltraps>

80107823 <vector133>:
.globl vector133
vector133:
  pushl $0
80107823:	6a 00                	push   $0x0
  pushl $133
80107825:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010782a:	e9 cd f4 ff ff       	jmp    80106cfc <alltraps>

8010782f <vector134>:
.globl vector134
vector134:
  pushl $0
8010782f:	6a 00                	push   $0x0
  pushl $134
80107831:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107836:	e9 c1 f4 ff ff       	jmp    80106cfc <alltraps>

8010783b <vector135>:
.globl vector135
vector135:
  pushl $0
8010783b:	6a 00                	push   $0x0
  pushl $135
8010783d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107842:	e9 b5 f4 ff ff       	jmp    80106cfc <alltraps>

80107847 <vector136>:
.globl vector136
vector136:
  pushl $0
80107847:	6a 00                	push   $0x0
  pushl $136
80107849:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010784e:	e9 a9 f4 ff ff       	jmp    80106cfc <alltraps>

80107853 <vector137>:
.globl vector137
vector137:
  pushl $0
80107853:	6a 00                	push   $0x0
  pushl $137
80107855:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010785a:	e9 9d f4 ff ff       	jmp    80106cfc <alltraps>

8010785f <vector138>:
.globl vector138
vector138:
  pushl $0
8010785f:	6a 00                	push   $0x0
  pushl $138
80107861:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107866:	e9 91 f4 ff ff       	jmp    80106cfc <alltraps>

8010786b <vector139>:
.globl vector139
vector139:
  pushl $0
8010786b:	6a 00                	push   $0x0
  pushl $139
8010786d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107872:	e9 85 f4 ff ff       	jmp    80106cfc <alltraps>

80107877 <vector140>:
.globl vector140
vector140:
  pushl $0
80107877:	6a 00                	push   $0x0
  pushl $140
80107879:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010787e:	e9 79 f4 ff ff       	jmp    80106cfc <alltraps>

80107883 <vector141>:
.globl vector141
vector141:
  pushl $0
80107883:	6a 00                	push   $0x0
  pushl $141
80107885:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010788a:	e9 6d f4 ff ff       	jmp    80106cfc <alltraps>

8010788f <vector142>:
.globl vector142
vector142:
  pushl $0
8010788f:	6a 00                	push   $0x0
  pushl $142
80107891:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107896:	e9 61 f4 ff ff       	jmp    80106cfc <alltraps>

8010789b <vector143>:
.globl vector143
vector143:
  pushl $0
8010789b:	6a 00                	push   $0x0
  pushl $143
8010789d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801078a2:	e9 55 f4 ff ff       	jmp    80106cfc <alltraps>

801078a7 <vector144>:
.globl vector144
vector144:
  pushl $0
801078a7:	6a 00                	push   $0x0
  pushl $144
801078a9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801078ae:	e9 49 f4 ff ff       	jmp    80106cfc <alltraps>

801078b3 <vector145>:
.globl vector145
vector145:
  pushl $0
801078b3:	6a 00                	push   $0x0
  pushl $145
801078b5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801078ba:	e9 3d f4 ff ff       	jmp    80106cfc <alltraps>

801078bf <vector146>:
.globl vector146
vector146:
  pushl $0
801078bf:	6a 00                	push   $0x0
  pushl $146
801078c1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801078c6:	e9 31 f4 ff ff       	jmp    80106cfc <alltraps>

801078cb <vector147>:
.globl vector147
vector147:
  pushl $0
801078cb:	6a 00                	push   $0x0
  pushl $147
801078cd:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801078d2:	e9 25 f4 ff ff       	jmp    80106cfc <alltraps>

801078d7 <vector148>:
.globl vector148
vector148:
  pushl $0
801078d7:	6a 00                	push   $0x0
  pushl $148
801078d9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801078de:	e9 19 f4 ff ff       	jmp    80106cfc <alltraps>

801078e3 <vector149>:
.globl vector149
vector149:
  pushl $0
801078e3:	6a 00                	push   $0x0
  pushl $149
801078e5:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801078ea:	e9 0d f4 ff ff       	jmp    80106cfc <alltraps>

801078ef <vector150>:
.globl vector150
vector150:
  pushl $0
801078ef:	6a 00                	push   $0x0
  pushl $150
801078f1:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801078f6:	e9 01 f4 ff ff       	jmp    80106cfc <alltraps>

801078fb <vector151>:
.globl vector151
vector151:
  pushl $0
801078fb:	6a 00                	push   $0x0
  pushl $151
801078fd:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107902:	e9 f5 f3 ff ff       	jmp    80106cfc <alltraps>

80107907 <vector152>:
.globl vector152
vector152:
  pushl $0
80107907:	6a 00                	push   $0x0
  pushl $152
80107909:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010790e:	e9 e9 f3 ff ff       	jmp    80106cfc <alltraps>

80107913 <vector153>:
.globl vector153
vector153:
  pushl $0
80107913:	6a 00                	push   $0x0
  pushl $153
80107915:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010791a:	e9 dd f3 ff ff       	jmp    80106cfc <alltraps>

8010791f <vector154>:
.globl vector154
vector154:
  pushl $0
8010791f:	6a 00                	push   $0x0
  pushl $154
80107921:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107926:	e9 d1 f3 ff ff       	jmp    80106cfc <alltraps>

8010792b <vector155>:
.globl vector155
vector155:
  pushl $0
8010792b:	6a 00                	push   $0x0
  pushl $155
8010792d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107932:	e9 c5 f3 ff ff       	jmp    80106cfc <alltraps>

80107937 <vector156>:
.globl vector156
vector156:
  pushl $0
80107937:	6a 00                	push   $0x0
  pushl $156
80107939:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010793e:	e9 b9 f3 ff ff       	jmp    80106cfc <alltraps>

80107943 <vector157>:
.globl vector157
vector157:
  pushl $0
80107943:	6a 00                	push   $0x0
  pushl $157
80107945:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010794a:	e9 ad f3 ff ff       	jmp    80106cfc <alltraps>

8010794f <vector158>:
.globl vector158
vector158:
  pushl $0
8010794f:	6a 00                	push   $0x0
  pushl $158
80107951:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107956:	e9 a1 f3 ff ff       	jmp    80106cfc <alltraps>

8010795b <vector159>:
.globl vector159
vector159:
  pushl $0
8010795b:	6a 00                	push   $0x0
  pushl $159
8010795d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107962:	e9 95 f3 ff ff       	jmp    80106cfc <alltraps>

80107967 <vector160>:
.globl vector160
vector160:
  pushl $0
80107967:	6a 00                	push   $0x0
  pushl $160
80107969:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010796e:	e9 89 f3 ff ff       	jmp    80106cfc <alltraps>

80107973 <vector161>:
.globl vector161
vector161:
  pushl $0
80107973:	6a 00                	push   $0x0
  pushl $161
80107975:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010797a:	e9 7d f3 ff ff       	jmp    80106cfc <alltraps>

8010797f <vector162>:
.globl vector162
vector162:
  pushl $0
8010797f:	6a 00                	push   $0x0
  pushl $162
80107981:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107986:	e9 71 f3 ff ff       	jmp    80106cfc <alltraps>

8010798b <vector163>:
.globl vector163
vector163:
  pushl $0
8010798b:	6a 00                	push   $0x0
  pushl $163
8010798d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107992:	e9 65 f3 ff ff       	jmp    80106cfc <alltraps>

80107997 <vector164>:
.globl vector164
vector164:
  pushl $0
80107997:	6a 00                	push   $0x0
  pushl $164
80107999:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010799e:	e9 59 f3 ff ff       	jmp    80106cfc <alltraps>

801079a3 <vector165>:
.globl vector165
vector165:
  pushl $0
801079a3:	6a 00                	push   $0x0
  pushl $165
801079a5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801079aa:	e9 4d f3 ff ff       	jmp    80106cfc <alltraps>

801079af <vector166>:
.globl vector166
vector166:
  pushl $0
801079af:	6a 00                	push   $0x0
  pushl $166
801079b1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801079b6:	e9 41 f3 ff ff       	jmp    80106cfc <alltraps>

801079bb <vector167>:
.globl vector167
vector167:
  pushl $0
801079bb:	6a 00                	push   $0x0
  pushl $167
801079bd:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801079c2:	e9 35 f3 ff ff       	jmp    80106cfc <alltraps>

801079c7 <vector168>:
.globl vector168
vector168:
  pushl $0
801079c7:	6a 00                	push   $0x0
  pushl $168
801079c9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801079ce:	e9 29 f3 ff ff       	jmp    80106cfc <alltraps>

801079d3 <vector169>:
.globl vector169
vector169:
  pushl $0
801079d3:	6a 00                	push   $0x0
  pushl $169
801079d5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801079da:	e9 1d f3 ff ff       	jmp    80106cfc <alltraps>

801079df <vector170>:
.globl vector170
vector170:
  pushl $0
801079df:	6a 00                	push   $0x0
  pushl $170
801079e1:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801079e6:	e9 11 f3 ff ff       	jmp    80106cfc <alltraps>

801079eb <vector171>:
.globl vector171
vector171:
  pushl $0
801079eb:	6a 00                	push   $0x0
  pushl $171
801079ed:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801079f2:	e9 05 f3 ff ff       	jmp    80106cfc <alltraps>

801079f7 <vector172>:
.globl vector172
vector172:
  pushl $0
801079f7:	6a 00                	push   $0x0
  pushl $172
801079f9:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801079fe:	e9 f9 f2 ff ff       	jmp    80106cfc <alltraps>

80107a03 <vector173>:
.globl vector173
vector173:
  pushl $0
80107a03:	6a 00                	push   $0x0
  pushl $173
80107a05:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107a0a:	e9 ed f2 ff ff       	jmp    80106cfc <alltraps>

80107a0f <vector174>:
.globl vector174
vector174:
  pushl $0
80107a0f:	6a 00                	push   $0x0
  pushl $174
80107a11:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107a16:	e9 e1 f2 ff ff       	jmp    80106cfc <alltraps>

80107a1b <vector175>:
.globl vector175
vector175:
  pushl $0
80107a1b:	6a 00                	push   $0x0
  pushl $175
80107a1d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107a22:	e9 d5 f2 ff ff       	jmp    80106cfc <alltraps>

80107a27 <vector176>:
.globl vector176
vector176:
  pushl $0
80107a27:	6a 00                	push   $0x0
  pushl $176
80107a29:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107a2e:	e9 c9 f2 ff ff       	jmp    80106cfc <alltraps>

80107a33 <vector177>:
.globl vector177
vector177:
  pushl $0
80107a33:	6a 00                	push   $0x0
  pushl $177
80107a35:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107a3a:	e9 bd f2 ff ff       	jmp    80106cfc <alltraps>

80107a3f <vector178>:
.globl vector178
vector178:
  pushl $0
80107a3f:	6a 00                	push   $0x0
  pushl $178
80107a41:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107a46:	e9 b1 f2 ff ff       	jmp    80106cfc <alltraps>

80107a4b <vector179>:
.globl vector179
vector179:
  pushl $0
80107a4b:	6a 00                	push   $0x0
  pushl $179
80107a4d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107a52:	e9 a5 f2 ff ff       	jmp    80106cfc <alltraps>

80107a57 <vector180>:
.globl vector180
vector180:
  pushl $0
80107a57:	6a 00                	push   $0x0
  pushl $180
80107a59:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107a5e:	e9 99 f2 ff ff       	jmp    80106cfc <alltraps>

80107a63 <vector181>:
.globl vector181
vector181:
  pushl $0
80107a63:	6a 00                	push   $0x0
  pushl $181
80107a65:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107a6a:	e9 8d f2 ff ff       	jmp    80106cfc <alltraps>

80107a6f <vector182>:
.globl vector182
vector182:
  pushl $0
80107a6f:	6a 00                	push   $0x0
  pushl $182
80107a71:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107a76:	e9 81 f2 ff ff       	jmp    80106cfc <alltraps>

80107a7b <vector183>:
.globl vector183
vector183:
  pushl $0
80107a7b:	6a 00                	push   $0x0
  pushl $183
80107a7d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107a82:	e9 75 f2 ff ff       	jmp    80106cfc <alltraps>

80107a87 <vector184>:
.globl vector184
vector184:
  pushl $0
80107a87:	6a 00                	push   $0x0
  pushl $184
80107a89:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107a8e:	e9 69 f2 ff ff       	jmp    80106cfc <alltraps>

80107a93 <vector185>:
.globl vector185
vector185:
  pushl $0
80107a93:	6a 00                	push   $0x0
  pushl $185
80107a95:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107a9a:	e9 5d f2 ff ff       	jmp    80106cfc <alltraps>

80107a9f <vector186>:
.globl vector186
vector186:
  pushl $0
80107a9f:	6a 00                	push   $0x0
  pushl $186
80107aa1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107aa6:	e9 51 f2 ff ff       	jmp    80106cfc <alltraps>

80107aab <vector187>:
.globl vector187
vector187:
  pushl $0
80107aab:	6a 00                	push   $0x0
  pushl $187
80107aad:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107ab2:	e9 45 f2 ff ff       	jmp    80106cfc <alltraps>

80107ab7 <vector188>:
.globl vector188
vector188:
  pushl $0
80107ab7:	6a 00                	push   $0x0
  pushl $188
80107ab9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107abe:	e9 39 f2 ff ff       	jmp    80106cfc <alltraps>

80107ac3 <vector189>:
.globl vector189
vector189:
  pushl $0
80107ac3:	6a 00                	push   $0x0
  pushl $189
80107ac5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107aca:	e9 2d f2 ff ff       	jmp    80106cfc <alltraps>

80107acf <vector190>:
.globl vector190
vector190:
  pushl $0
80107acf:	6a 00                	push   $0x0
  pushl $190
80107ad1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107ad6:	e9 21 f2 ff ff       	jmp    80106cfc <alltraps>

80107adb <vector191>:
.globl vector191
vector191:
  pushl $0
80107adb:	6a 00                	push   $0x0
  pushl $191
80107add:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107ae2:	e9 15 f2 ff ff       	jmp    80106cfc <alltraps>

80107ae7 <vector192>:
.globl vector192
vector192:
  pushl $0
80107ae7:	6a 00                	push   $0x0
  pushl $192
80107ae9:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107aee:	e9 09 f2 ff ff       	jmp    80106cfc <alltraps>

80107af3 <vector193>:
.globl vector193
vector193:
  pushl $0
80107af3:	6a 00                	push   $0x0
  pushl $193
80107af5:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107afa:	e9 fd f1 ff ff       	jmp    80106cfc <alltraps>

80107aff <vector194>:
.globl vector194
vector194:
  pushl $0
80107aff:	6a 00                	push   $0x0
  pushl $194
80107b01:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107b06:	e9 f1 f1 ff ff       	jmp    80106cfc <alltraps>

80107b0b <vector195>:
.globl vector195
vector195:
  pushl $0
80107b0b:	6a 00                	push   $0x0
  pushl $195
80107b0d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107b12:	e9 e5 f1 ff ff       	jmp    80106cfc <alltraps>

80107b17 <vector196>:
.globl vector196
vector196:
  pushl $0
80107b17:	6a 00                	push   $0x0
  pushl $196
80107b19:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107b1e:	e9 d9 f1 ff ff       	jmp    80106cfc <alltraps>

80107b23 <vector197>:
.globl vector197
vector197:
  pushl $0
80107b23:	6a 00                	push   $0x0
  pushl $197
80107b25:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107b2a:	e9 cd f1 ff ff       	jmp    80106cfc <alltraps>

80107b2f <vector198>:
.globl vector198
vector198:
  pushl $0
80107b2f:	6a 00                	push   $0x0
  pushl $198
80107b31:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107b36:	e9 c1 f1 ff ff       	jmp    80106cfc <alltraps>

80107b3b <vector199>:
.globl vector199
vector199:
  pushl $0
80107b3b:	6a 00                	push   $0x0
  pushl $199
80107b3d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107b42:	e9 b5 f1 ff ff       	jmp    80106cfc <alltraps>

80107b47 <vector200>:
.globl vector200
vector200:
  pushl $0
80107b47:	6a 00                	push   $0x0
  pushl $200
80107b49:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107b4e:	e9 a9 f1 ff ff       	jmp    80106cfc <alltraps>

80107b53 <vector201>:
.globl vector201
vector201:
  pushl $0
80107b53:	6a 00                	push   $0x0
  pushl $201
80107b55:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107b5a:	e9 9d f1 ff ff       	jmp    80106cfc <alltraps>

80107b5f <vector202>:
.globl vector202
vector202:
  pushl $0
80107b5f:	6a 00                	push   $0x0
  pushl $202
80107b61:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107b66:	e9 91 f1 ff ff       	jmp    80106cfc <alltraps>

80107b6b <vector203>:
.globl vector203
vector203:
  pushl $0
80107b6b:	6a 00                	push   $0x0
  pushl $203
80107b6d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107b72:	e9 85 f1 ff ff       	jmp    80106cfc <alltraps>

80107b77 <vector204>:
.globl vector204
vector204:
  pushl $0
80107b77:	6a 00                	push   $0x0
  pushl $204
80107b79:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107b7e:	e9 79 f1 ff ff       	jmp    80106cfc <alltraps>

80107b83 <vector205>:
.globl vector205
vector205:
  pushl $0
80107b83:	6a 00                	push   $0x0
  pushl $205
80107b85:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107b8a:	e9 6d f1 ff ff       	jmp    80106cfc <alltraps>

80107b8f <vector206>:
.globl vector206
vector206:
  pushl $0
80107b8f:	6a 00                	push   $0x0
  pushl $206
80107b91:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107b96:	e9 61 f1 ff ff       	jmp    80106cfc <alltraps>

80107b9b <vector207>:
.globl vector207
vector207:
  pushl $0
80107b9b:	6a 00                	push   $0x0
  pushl $207
80107b9d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107ba2:	e9 55 f1 ff ff       	jmp    80106cfc <alltraps>

80107ba7 <vector208>:
.globl vector208
vector208:
  pushl $0
80107ba7:	6a 00                	push   $0x0
  pushl $208
80107ba9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107bae:	e9 49 f1 ff ff       	jmp    80106cfc <alltraps>

80107bb3 <vector209>:
.globl vector209
vector209:
  pushl $0
80107bb3:	6a 00                	push   $0x0
  pushl $209
80107bb5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107bba:	e9 3d f1 ff ff       	jmp    80106cfc <alltraps>

80107bbf <vector210>:
.globl vector210
vector210:
  pushl $0
80107bbf:	6a 00                	push   $0x0
  pushl $210
80107bc1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107bc6:	e9 31 f1 ff ff       	jmp    80106cfc <alltraps>

80107bcb <vector211>:
.globl vector211
vector211:
  pushl $0
80107bcb:	6a 00                	push   $0x0
  pushl $211
80107bcd:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107bd2:	e9 25 f1 ff ff       	jmp    80106cfc <alltraps>

80107bd7 <vector212>:
.globl vector212
vector212:
  pushl $0
80107bd7:	6a 00                	push   $0x0
  pushl $212
80107bd9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107bde:	e9 19 f1 ff ff       	jmp    80106cfc <alltraps>

80107be3 <vector213>:
.globl vector213
vector213:
  pushl $0
80107be3:	6a 00                	push   $0x0
  pushl $213
80107be5:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107bea:	e9 0d f1 ff ff       	jmp    80106cfc <alltraps>

80107bef <vector214>:
.globl vector214
vector214:
  pushl $0
80107bef:	6a 00                	push   $0x0
  pushl $214
80107bf1:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107bf6:	e9 01 f1 ff ff       	jmp    80106cfc <alltraps>

80107bfb <vector215>:
.globl vector215
vector215:
  pushl $0
80107bfb:	6a 00                	push   $0x0
  pushl $215
80107bfd:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107c02:	e9 f5 f0 ff ff       	jmp    80106cfc <alltraps>

80107c07 <vector216>:
.globl vector216
vector216:
  pushl $0
80107c07:	6a 00                	push   $0x0
  pushl $216
80107c09:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107c0e:	e9 e9 f0 ff ff       	jmp    80106cfc <alltraps>

80107c13 <vector217>:
.globl vector217
vector217:
  pushl $0
80107c13:	6a 00                	push   $0x0
  pushl $217
80107c15:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107c1a:	e9 dd f0 ff ff       	jmp    80106cfc <alltraps>

80107c1f <vector218>:
.globl vector218
vector218:
  pushl $0
80107c1f:	6a 00                	push   $0x0
  pushl $218
80107c21:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107c26:	e9 d1 f0 ff ff       	jmp    80106cfc <alltraps>

80107c2b <vector219>:
.globl vector219
vector219:
  pushl $0
80107c2b:	6a 00                	push   $0x0
  pushl $219
80107c2d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107c32:	e9 c5 f0 ff ff       	jmp    80106cfc <alltraps>

80107c37 <vector220>:
.globl vector220
vector220:
  pushl $0
80107c37:	6a 00                	push   $0x0
  pushl $220
80107c39:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107c3e:	e9 b9 f0 ff ff       	jmp    80106cfc <alltraps>

80107c43 <vector221>:
.globl vector221
vector221:
  pushl $0
80107c43:	6a 00                	push   $0x0
  pushl $221
80107c45:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107c4a:	e9 ad f0 ff ff       	jmp    80106cfc <alltraps>

80107c4f <vector222>:
.globl vector222
vector222:
  pushl $0
80107c4f:	6a 00                	push   $0x0
  pushl $222
80107c51:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107c56:	e9 a1 f0 ff ff       	jmp    80106cfc <alltraps>

80107c5b <vector223>:
.globl vector223
vector223:
  pushl $0
80107c5b:	6a 00                	push   $0x0
  pushl $223
80107c5d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107c62:	e9 95 f0 ff ff       	jmp    80106cfc <alltraps>

80107c67 <vector224>:
.globl vector224
vector224:
  pushl $0
80107c67:	6a 00                	push   $0x0
  pushl $224
80107c69:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107c6e:	e9 89 f0 ff ff       	jmp    80106cfc <alltraps>

80107c73 <vector225>:
.globl vector225
vector225:
  pushl $0
80107c73:	6a 00                	push   $0x0
  pushl $225
80107c75:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107c7a:	e9 7d f0 ff ff       	jmp    80106cfc <alltraps>

80107c7f <vector226>:
.globl vector226
vector226:
  pushl $0
80107c7f:	6a 00                	push   $0x0
  pushl $226
80107c81:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107c86:	e9 71 f0 ff ff       	jmp    80106cfc <alltraps>

80107c8b <vector227>:
.globl vector227
vector227:
  pushl $0
80107c8b:	6a 00                	push   $0x0
  pushl $227
80107c8d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107c92:	e9 65 f0 ff ff       	jmp    80106cfc <alltraps>

80107c97 <vector228>:
.globl vector228
vector228:
  pushl $0
80107c97:	6a 00                	push   $0x0
  pushl $228
80107c99:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107c9e:	e9 59 f0 ff ff       	jmp    80106cfc <alltraps>

80107ca3 <vector229>:
.globl vector229
vector229:
  pushl $0
80107ca3:	6a 00                	push   $0x0
  pushl $229
80107ca5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107caa:	e9 4d f0 ff ff       	jmp    80106cfc <alltraps>

80107caf <vector230>:
.globl vector230
vector230:
  pushl $0
80107caf:	6a 00                	push   $0x0
  pushl $230
80107cb1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107cb6:	e9 41 f0 ff ff       	jmp    80106cfc <alltraps>

80107cbb <vector231>:
.globl vector231
vector231:
  pushl $0
80107cbb:	6a 00                	push   $0x0
  pushl $231
80107cbd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107cc2:	e9 35 f0 ff ff       	jmp    80106cfc <alltraps>

80107cc7 <vector232>:
.globl vector232
vector232:
  pushl $0
80107cc7:	6a 00                	push   $0x0
  pushl $232
80107cc9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107cce:	e9 29 f0 ff ff       	jmp    80106cfc <alltraps>

80107cd3 <vector233>:
.globl vector233
vector233:
  pushl $0
80107cd3:	6a 00                	push   $0x0
  pushl $233
80107cd5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107cda:	e9 1d f0 ff ff       	jmp    80106cfc <alltraps>

80107cdf <vector234>:
.globl vector234
vector234:
  pushl $0
80107cdf:	6a 00                	push   $0x0
  pushl $234
80107ce1:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ce6:	e9 11 f0 ff ff       	jmp    80106cfc <alltraps>

80107ceb <vector235>:
.globl vector235
vector235:
  pushl $0
80107ceb:	6a 00                	push   $0x0
  pushl $235
80107ced:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107cf2:	e9 05 f0 ff ff       	jmp    80106cfc <alltraps>

80107cf7 <vector236>:
.globl vector236
vector236:
  pushl $0
80107cf7:	6a 00                	push   $0x0
  pushl $236
80107cf9:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107cfe:	e9 f9 ef ff ff       	jmp    80106cfc <alltraps>

80107d03 <vector237>:
.globl vector237
vector237:
  pushl $0
80107d03:	6a 00                	push   $0x0
  pushl $237
80107d05:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107d0a:	e9 ed ef ff ff       	jmp    80106cfc <alltraps>

80107d0f <vector238>:
.globl vector238
vector238:
  pushl $0
80107d0f:	6a 00                	push   $0x0
  pushl $238
80107d11:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107d16:	e9 e1 ef ff ff       	jmp    80106cfc <alltraps>

80107d1b <vector239>:
.globl vector239
vector239:
  pushl $0
80107d1b:	6a 00                	push   $0x0
  pushl $239
80107d1d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107d22:	e9 d5 ef ff ff       	jmp    80106cfc <alltraps>

80107d27 <vector240>:
.globl vector240
vector240:
  pushl $0
80107d27:	6a 00                	push   $0x0
  pushl $240
80107d29:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107d2e:	e9 c9 ef ff ff       	jmp    80106cfc <alltraps>

80107d33 <vector241>:
.globl vector241
vector241:
  pushl $0
80107d33:	6a 00                	push   $0x0
  pushl $241
80107d35:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107d3a:	e9 bd ef ff ff       	jmp    80106cfc <alltraps>

80107d3f <vector242>:
.globl vector242
vector242:
  pushl $0
80107d3f:	6a 00                	push   $0x0
  pushl $242
80107d41:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107d46:	e9 b1 ef ff ff       	jmp    80106cfc <alltraps>

80107d4b <vector243>:
.globl vector243
vector243:
  pushl $0
80107d4b:	6a 00                	push   $0x0
  pushl $243
80107d4d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107d52:	e9 a5 ef ff ff       	jmp    80106cfc <alltraps>

80107d57 <vector244>:
.globl vector244
vector244:
  pushl $0
80107d57:	6a 00                	push   $0x0
  pushl $244
80107d59:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107d5e:	e9 99 ef ff ff       	jmp    80106cfc <alltraps>

80107d63 <vector245>:
.globl vector245
vector245:
  pushl $0
80107d63:	6a 00                	push   $0x0
  pushl $245
80107d65:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107d6a:	e9 8d ef ff ff       	jmp    80106cfc <alltraps>

80107d6f <vector246>:
.globl vector246
vector246:
  pushl $0
80107d6f:	6a 00                	push   $0x0
  pushl $246
80107d71:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107d76:	e9 81 ef ff ff       	jmp    80106cfc <alltraps>

80107d7b <vector247>:
.globl vector247
vector247:
  pushl $0
80107d7b:	6a 00                	push   $0x0
  pushl $247
80107d7d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107d82:	e9 75 ef ff ff       	jmp    80106cfc <alltraps>

80107d87 <vector248>:
.globl vector248
vector248:
  pushl $0
80107d87:	6a 00                	push   $0x0
  pushl $248
80107d89:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107d8e:	e9 69 ef ff ff       	jmp    80106cfc <alltraps>

80107d93 <vector249>:
.globl vector249
vector249:
  pushl $0
80107d93:	6a 00                	push   $0x0
  pushl $249
80107d95:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107d9a:	e9 5d ef ff ff       	jmp    80106cfc <alltraps>

80107d9f <vector250>:
.globl vector250
vector250:
  pushl $0
80107d9f:	6a 00                	push   $0x0
  pushl $250
80107da1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107da6:	e9 51 ef ff ff       	jmp    80106cfc <alltraps>

80107dab <vector251>:
.globl vector251
vector251:
  pushl $0
80107dab:	6a 00                	push   $0x0
  pushl $251
80107dad:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107db2:	e9 45 ef ff ff       	jmp    80106cfc <alltraps>

80107db7 <vector252>:
.globl vector252
vector252:
  pushl $0
80107db7:	6a 00                	push   $0x0
  pushl $252
80107db9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107dbe:	e9 39 ef ff ff       	jmp    80106cfc <alltraps>

80107dc3 <vector253>:
.globl vector253
vector253:
  pushl $0
80107dc3:	6a 00                	push   $0x0
  pushl $253
80107dc5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107dca:	e9 2d ef ff ff       	jmp    80106cfc <alltraps>

80107dcf <vector254>:
.globl vector254
vector254:
  pushl $0
80107dcf:	6a 00                	push   $0x0
  pushl $254
80107dd1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107dd6:	e9 21 ef ff ff       	jmp    80106cfc <alltraps>

80107ddb <vector255>:
.globl vector255
vector255:
  pushl $0
80107ddb:	6a 00                	push   $0x0
  pushl $255
80107ddd:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107de2:	e9 15 ef ff ff       	jmp    80106cfc <alltraps>

80107de7 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107de7:	55                   	push   %ebp
80107de8:	89 e5                	mov    %esp,%ebp
80107dea:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107ded:	8b 45 0c             	mov    0xc(%ebp),%eax
80107df0:	83 e8 01             	sub    $0x1,%eax
80107df3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107df7:	8b 45 08             	mov    0x8(%ebp),%eax
80107dfa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80107e01:	c1 e8 10             	shr    $0x10,%eax
80107e04:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107e08:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107e0b:	0f 01 10             	lgdtl  (%eax)
}
80107e0e:	c9                   	leave  
80107e0f:	c3                   	ret    

80107e10 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107e10:	55                   	push   %ebp
80107e11:	89 e5                	mov    %esp,%ebp
80107e13:	83 ec 04             	sub    $0x4,%esp
80107e16:	8b 45 08             	mov    0x8(%ebp),%eax
80107e19:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107e1d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107e21:	0f 00 d8             	ltr    %ax
}
80107e24:	c9                   	leave  
80107e25:	c3                   	ret    

80107e26 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107e26:	55                   	push   %ebp
80107e27:	89 e5                	mov    %esp,%ebp
80107e29:	83 ec 04             	sub    $0x4,%esp
80107e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e2f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107e33:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107e37:	8e e8                	mov    %eax,%gs
}
80107e39:	c9                   	leave  
80107e3a:	c3                   	ret    

80107e3b <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107e3b:	55                   	push   %ebp
80107e3c:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80107e41:	0f 22 d8             	mov    %eax,%cr3
}
80107e44:	5d                   	pop    %ebp
80107e45:	c3                   	ret    

80107e46 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107e46:	55                   	push   %ebp
80107e47:	89 e5                	mov    %esp,%ebp
80107e49:	8b 45 08             	mov    0x8(%ebp),%eax
80107e4c:	05 00 00 00 80       	add    $0x80000000,%eax
80107e51:	5d                   	pop    %ebp
80107e52:	c3                   	ret    

80107e53 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107e53:	55                   	push   %ebp
80107e54:	89 e5                	mov    %esp,%ebp
80107e56:	8b 45 08             	mov    0x8(%ebp),%eax
80107e59:	05 00 00 00 80       	add    $0x80000000,%eax
80107e5e:	5d                   	pop    %ebp
80107e5f:	c3                   	ret    

80107e60 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107e60:	55                   	push   %ebp
80107e61:	89 e5                	mov    %esp,%ebp
80107e63:	53                   	push   %ebx
80107e64:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107e67:	e8 79 b8 ff ff       	call   801036e5 <cpunum>
80107e6c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107e72:	05 a0 4f 11 80       	add    $0x80114fa0,%eax
80107e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e86:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8f:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e96:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e9a:	83 e2 f0             	and    $0xfffffff0,%edx
80107e9d:	83 ca 0a             	or     $0xa,%edx
80107ea0:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107eaa:	83 ca 10             	or     $0x10,%edx
80107ead:	88 50 7d             	mov    %dl,0x7d(%eax)
80107eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107eb7:	83 e2 9f             	and    $0xffffff9f,%edx
80107eba:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ec4:	83 ca 80             	or     $0xffffff80,%edx
80107ec7:	88 50 7d             	mov    %dl,0x7d(%eax)
80107eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ed1:	83 ca 0f             	or     $0xf,%edx
80107ed4:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eda:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ede:	83 e2 ef             	and    $0xffffffef,%edx
80107ee1:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107eeb:	83 e2 df             	and    $0xffffffdf,%edx
80107eee:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ef8:	83 ca 40             	or     $0x40,%edx
80107efb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f01:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f05:	83 ca 80             	or     $0xffffff80,%edx
80107f08:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f15:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107f1c:	ff ff 
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f21:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107f28:	00 00 
80107f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2d:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f37:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f3e:	83 e2 f0             	and    $0xfffffff0,%edx
80107f41:	83 ca 02             	or     $0x2,%edx
80107f44:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f54:	83 ca 10             	or     $0x10,%edx
80107f57:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f60:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f67:	83 e2 9f             	and    $0xffffff9f,%edx
80107f6a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f73:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f7a:	83 ca 80             	or     $0xffffff80,%edx
80107f7d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f86:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f8d:	83 ca 0f             	or     $0xf,%edx
80107f90:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f99:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107fa0:	83 e2 ef             	and    $0xffffffef,%edx
80107fa3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fac:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107fb3:	83 e2 df             	and    $0xffffffdf,%edx
80107fb6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107fc6:	83 ca 40             	or     $0x40,%edx
80107fc9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107fd9:	83 ca 80             	or     $0xffffff80,%edx
80107fdc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe5:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fef:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107ff6:	ff ff 
80107ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffb:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108002:	00 00 
80108004:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108007:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010800e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108011:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108018:	83 e2 f0             	and    $0xfffffff0,%edx
8010801b:	83 ca 0a             	or     $0xa,%edx
8010801e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108027:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010802e:	83 ca 10             	or     $0x10,%edx
80108031:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108041:	83 ca 60             	or     $0x60,%edx
80108044:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108054:	83 ca 80             	or     $0xffffff80,%edx
80108057:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010805d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108060:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108067:	83 ca 0f             	or     $0xf,%edx
8010806a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108073:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010807a:	83 e2 ef             	and    $0xffffffef,%edx
8010807d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108086:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010808d:	83 e2 df             	and    $0xffffffdf,%edx
80108090:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108099:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801080a0:	83 ca 40             	or     $0x40,%edx
801080a3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801080a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ac:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801080b3:	83 ca 80             	or     $0xffffff80,%edx
801080b6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801080bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bf:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801080c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c9:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801080d0:	ff ff 
801080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d5:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801080dc:	00 00 
801080de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e1:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801080e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080eb:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080f2:	83 e2 f0             	and    $0xfffffff0,%edx
801080f5:	83 ca 02             	or     $0x2,%edx
801080f8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801080fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108101:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108108:	83 ca 10             	or     $0x10,%edx
8010810b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108114:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010811b:	83 ca 60             	or     $0x60,%edx
8010811e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108127:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010812e:	83 ca 80             	or     $0xffffff80,%edx
80108131:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108141:	83 ca 0f             	or     $0xf,%edx
80108144:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010814a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108154:	83 e2 ef             	and    $0xffffffef,%edx
80108157:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010815d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108160:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108167:	83 e2 df             	and    $0xffffffdf,%edx
8010816a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108173:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010817a:	83 ca 40             	or     $0x40,%edx
8010817d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108186:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010818d:	83 ca 80             	or     $0xffffff80,%edx
80108190:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108199:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801081a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a3:	05 b4 00 00 00       	add    $0xb4,%eax
801081a8:	89 c3                	mov    %eax,%ebx
801081aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ad:	05 b4 00 00 00       	add    $0xb4,%eax
801081b2:	c1 e8 10             	shr    $0x10,%eax
801081b5:	89 c1                	mov    %eax,%ecx
801081b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ba:	05 b4 00 00 00       	add    $0xb4,%eax
801081bf:	c1 e8 18             	shr    $0x18,%eax
801081c2:	89 c2                	mov    %eax,%edx
801081c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c7:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801081ce:	00 00 
801081d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d3:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801081da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dd:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801081e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e6:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801081ed:	83 e1 f0             	and    $0xfffffff0,%ecx
801081f0:	83 c9 02             	or     $0x2,%ecx
801081f3:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801081f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fc:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108203:	83 c9 10             	or     $0x10,%ecx
80108206:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010820c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108216:	83 e1 9f             	and    $0xffffff9f,%ecx
80108219:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010821f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108222:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108229:	83 c9 80             	or     $0xffffff80,%ecx
8010822c:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108235:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010823c:	83 e1 f0             	and    $0xfffffff0,%ecx
8010823f:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108245:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108248:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010824f:	83 e1 ef             	and    $0xffffffef,%ecx
80108252:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825b:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108262:	83 e1 df             	and    $0xffffffdf,%ecx
80108265:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010826b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108275:	83 c9 40             	or     $0x40,%ecx
80108278:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010827e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108281:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108288:	83 c9 80             	or     $0xffffff80,%ecx
8010828b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108294:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010829a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829d:	83 c0 70             	add    $0x70,%eax
801082a0:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
801082a7:	00 
801082a8:	89 04 24             	mov    %eax,(%esp)
801082ab:	e8 37 fb ff ff       	call   80107de7 <lgdt>
  loadgs(SEG_KCPU << 3);
801082b0:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
801082b7:	e8 6a fb ff ff       	call   80107e26 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
801082bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bf:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801082c5:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801082cc:	00 00 00 00 
}
801082d0:	83 c4 24             	add    $0x24,%esp
801082d3:	5b                   	pop    %ebx
801082d4:	5d                   	pop    %ebp
801082d5:	c3                   	ret    

801082d6 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801082d6:	55                   	push   %ebp
801082d7:	89 e5                	mov    %esp,%ebp
801082d9:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801082dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801082df:	c1 e8 16             	shr    $0x16,%eax
801082e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082e9:	8b 45 08             	mov    0x8(%ebp),%eax
801082ec:	01 d0                	add    %edx,%eax
801082ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801082f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f4:	8b 00                	mov    (%eax),%eax
801082f6:	83 e0 01             	and    $0x1,%eax
801082f9:	85 c0                	test   %eax,%eax
801082fb:	74 17                	je     80108314 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801082fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108300:	8b 00                	mov    (%eax),%eax
80108302:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108307:	89 04 24             	mov    %eax,(%esp)
8010830a:	e8 44 fb ff ff       	call   80107e53 <p2v>
8010830f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108312:	eb 4b                	jmp    8010835f <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108314:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108318:	74 0e                	je     80108328 <walkpgdir+0x52>
8010831a:	e8 30 b0 ff ff       	call   8010334f <kalloc>
8010831f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108322:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108326:	75 07                	jne    8010832f <walkpgdir+0x59>
      return 0;
80108328:	b8 00 00 00 00       	mov    $0x0,%eax
8010832d:	eb 47                	jmp    80108376 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010832f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108336:	00 
80108337:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010833e:	00 
8010833f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108342:	89 04 24             	mov    %eax,(%esp)
80108345:	e8 68 d5 ff ff       	call   801058b2 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010834a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834d:	89 04 24             	mov    %eax,(%esp)
80108350:	e8 f1 fa ff ff       	call   80107e46 <v2p>
80108355:	83 c8 07             	or     $0x7,%eax
80108358:	89 c2                	mov    %eax,%edx
8010835a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010835d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010835f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108362:	c1 e8 0c             	shr    $0xc,%eax
80108365:	25 ff 03 00 00       	and    $0x3ff,%eax
8010836a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108374:	01 d0                	add    %edx,%eax
}
80108376:	c9                   	leave  
80108377:	c3                   	ret    

80108378 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108378:	55                   	push   %ebp
80108379:	89 e5                	mov    %esp,%ebp
8010837b:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010837e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108381:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108386:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108389:	8b 55 0c             	mov    0xc(%ebp),%edx
8010838c:	8b 45 10             	mov    0x10(%ebp),%eax
8010838f:	01 d0                	add    %edx,%eax
80108391:	83 e8 01             	sub    $0x1,%eax
80108394:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108399:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010839c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801083a3:	00 
801083a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801083ab:	8b 45 08             	mov    0x8(%ebp),%eax
801083ae:	89 04 24             	mov    %eax,(%esp)
801083b1:	e8 20 ff ff ff       	call   801082d6 <walkpgdir>
801083b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083bd:	75 07                	jne    801083c6 <mappages+0x4e>
      return -1;
801083bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083c4:	eb 48                	jmp    8010840e <mappages+0x96>
    if(*pte & PTE_P)
801083c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c9:	8b 00                	mov    (%eax),%eax
801083cb:	83 e0 01             	and    $0x1,%eax
801083ce:	85 c0                	test   %eax,%eax
801083d0:	74 0c                	je     801083de <mappages+0x66>
      panic("remap");
801083d2:	c7 04 24 38 94 10 80 	movl   $0x80109438,(%esp)
801083d9:	e8 5c 81 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
801083de:	8b 45 18             	mov    0x18(%ebp),%eax
801083e1:	0b 45 14             	or     0x14(%ebp),%eax
801083e4:	83 c8 01             	or     $0x1,%eax
801083e7:	89 c2                	mov    %eax,%edx
801083e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ec:	89 10                	mov    %edx,(%eax)
    if(a == last)
801083ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083f4:	75 08                	jne    801083fe <mappages+0x86>
      break;
801083f6:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801083f7:	b8 00 00 00 00       	mov    $0x0,%eax
801083fc:	eb 10                	jmp    8010840e <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801083fe:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108405:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010840c:	eb 8e                	jmp    8010839c <mappages+0x24>
  return 0;
}
8010840e:	c9                   	leave  
8010840f:	c3                   	ret    

80108410 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108410:	55                   	push   %ebp
80108411:	89 e5                	mov    %esp,%ebp
80108413:	53                   	push   %ebx
80108414:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108417:	e8 33 af ff ff       	call   8010334f <kalloc>
8010841c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010841f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108423:	75 0a                	jne    8010842f <setupkvm+0x1f>
    return 0;
80108425:	b8 00 00 00 00       	mov    $0x0,%eax
8010842a:	e9 98 00 00 00       	jmp    801084c7 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
8010842f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108436:	00 
80108437:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010843e:	00 
8010843f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108442:	89 04 24             	mov    %eax,(%esp)
80108445:	e8 68 d4 ff ff       	call   801058b2 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010844a:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108451:	e8 fd f9 ff ff       	call   80107e53 <p2v>
80108456:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010845b:	76 0c                	jbe    80108469 <setupkvm+0x59>
    panic("PHYSTOP too high");
8010845d:	c7 04 24 3e 94 10 80 	movl   $0x8010943e,(%esp)
80108464:	e8 d1 80 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108469:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108470:	eb 49                	jmp    801084bb <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108475:	8b 48 0c             	mov    0xc(%eax),%ecx
80108478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847b:	8b 50 04             	mov    0x4(%eax),%edx
8010847e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108481:	8b 58 08             	mov    0x8(%eax),%ebx
80108484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108487:	8b 40 04             	mov    0x4(%eax),%eax
8010848a:	29 c3                	sub    %eax,%ebx
8010848c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848f:	8b 00                	mov    (%eax),%eax
80108491:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108495:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108499:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010849d:	89 44 24 04          	mov    %eax,0x4(%esp)
801084a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a4:	89 04 24             	mov    %eax,(%esp)
801084a7:	e8 cc fe ff ff       	call   80108378 <mappages>
801084ac:	85 c0                	test   %eax,%eax
801084ae:	79 07                	jns    801084b7 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801084b0:	b8 00 00 00 00       	mov    $0x0,%eax
801084b5:	eb 10                	jmp    801084c7 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801084b7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801084bb:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
801084c2:	72 ae                	jb     80108472 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801084c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801084c7:	83 c4 34             	add    $0x34,%esp
801084ca:	5b                   	pop    %ebx
801084cb:	5d                   	pop    %ebp
801084cc:	c3                   	ret    

801084cd <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801084cd:	55                   	push   %ebp
801084ce:	89 e5                	mov    %esp,%ebp
801084d0:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801084d3:	e8 38 ff ff ff       	call   80108410 <setupkvm>
801084d8:	a3 78 7d 11 80       	mov    %eax,0x80117d78
  switchkvm();
801084dd:	e8 02 00 00 00       	call   801084e4 <switchkvm>
}
801084e2:	c9                   	leave  
801084e3:	c3                   	ret    

801084e4 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801084e4:	55                   	push   %ebp
801084e5:	89 e5                	mov    %esp,%ebp
801084e7:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801084ea:	a1 78 7d 11 80       	mov    0x80117d78,%eax
801084ef:	89 04 24             	mov    %eax,(%esp)
801084f2:	e8 4f f9 ff ff       	call   80107e46 <v2p>
801084f7:	89 04 24             	mov    %eax,(%esp)
801084fa:	e8 3c f9 ff ff       	call   80107e3b <lcr3>
}
801084ff:	c9                   	leave  
80108500:	c3                   	ret    

80108501 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108501:	55                   	push   %ebp
80108502:	89 e5                	mov    %esp,%ebp
80108504:	53                   	push   %ebx
80108505:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108508:	e8 a5 d2 ff ff       	call   801057b2 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010850d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108513:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010851a:	83 c2 08             	add    $0x8,%edx
8010851d:	89 d3                	mov    %edx,%ebx
8010851f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108526:	83 c2 08             	add    $0x8,%edx
80108529:	c1 ea 10             	shr    $0x10,%edx
8010852c:	89 d1                	mov    %edx,%ecx
8010852e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108535:	83 c2 08             	add    $0x8,%edx
80108538:	c1 ea 18             	shr    $0x18,%edx
8010853b:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108542:	67 00 
80108544:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
8010854b:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108551:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108558:	83 e1 f0             	and    $0xfffffff0,%ecx
8010855b:	83 c9 09             	or     $0x9,%ecx
8010855e:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108564:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010856b:	83 c9 10             	or     $0x10,%ecx
8010856e:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108574:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010857b:	83 e1 9f             	and    $0xffffff9f,%ecx
8010857e:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108584:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010858b:	83 c9 80             	or     $0xffffff80,%ecx
8010858e:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108594:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010859b:	83 e1 f0             	and    $0xfffffff0,%ecx
8010859e:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801085a4:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801085ab:	83 e1 ef             	and    $0xffffffef,%ecx
801085ae:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801085b4:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801085bb:	83 e1 df             	and    $0xffffffdf,%ecx
801085be:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801085c4:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801085cb:	83 c9 40             	or     $0x40,%ecx
801085ce:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801085d4:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801085db:	83 e1 7f             	and    $0x7f,%ecx
801085de:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801085e4:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801085ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801085f0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801085f7:	83 e2 ef             	and    $0xffffffef,%edx
801085fa:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108600:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108606:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010860c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108612:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108619:	8b 52 08             	mov    0x8(%edx),%edx
8010861c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108622:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108625:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
8010862c:	e8 df f7 ff ff       	call   80107e10 <ltr>
  if(p->pgdir == 0)
80108631:	8b 45 08             	mov    0x8(%ebp),%eax
80108634:	8b 40 04             	mov    0x4(%eax),%eax
80108637:	85 c0                	test   %eax,%eax
80108639:	75 0c                	jne    80108647 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
8010863b:	c7 04 24 4f 94 10 80 	movl   $0x8010944f,(%esp)
80108642:	e8 f3 7e ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108647:	8b 45 08             	mov    0x8(%ebp),%eax
8010864a:	8b 40 04             	mov    0x4(%eax),%eax
8010864d:	89 04 24             	mov    %eax,(%esp)
80108650:	e8 f1 f7 ff ff       	call   80107e46 <v2p>
80108655:	89 04 24             	mov    %eax,(%esp)
80108658:	e8 de f7 ff ff       	call   80107e3b <lcr3>
  popcli();
8010865d:	e8 94 d1 ff ff       	call   801057f6 <popcli>
}
80108662:	83 c4 14             	add    $0x14,%esp
80108665:	5b                   	pop    %ebx
80108666:	5d                   	pop    %ebp
80108667:	c3                   	ret    

80108668 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108668:	55                   	push   %ebp
80108669:	89 e5                	mov    %esp,%ebp
8010866b:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010866e:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108675:	76 0c                	jbe    80108683 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108677:	c7 04 24 63 94 10 80 	movl   $0x80109463,(%esp)
8010867e:	e8 b7 7e ff ff       	call   8010053a <panic>
  mem = kalloc();
80108683:	e8 c7 ac ff ff       	call   8010334f <kalloc>
80108688:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010868b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108692:	00 
80108693:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010869a:	00 
8010869b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869e:	89 04 24             	mov    %eax,(%esp)
801086a1:	e8 0c d2 ff ff       	call   801058b2 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801086a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a9:	89 04 24             	mov    %eax,(%esp)
801086ac:	e8 95 f7 ff ff       	call   80107e46 <v2p>
801086b1:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801086b8:	00 
801086b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
801086bd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086c4:	00 
801086c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801086cc:	00 
801086cd:	8b 45 08             	mov    0x8(%ebp),%eax
801086d0:	89 04 24             	mov    %eax,(%esp)
801086d3:	e8 a0 fc ff ff       	call   80108378 <mappages>
  memmove(mem, init, sz);
801086d8:	8b 45 10             	mov    0x10(%ebp),%eax
801086db:	89 44 24 08          	mov    %eax,0x8(%esp)
801086df:	8b 45 0c             	mov    0xc(%ebp),%eax
801086e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801086e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e9:	89 04 24             	mov    %eax,(%esp)
801086ec:	e8 90 d2 ff ff       	call   80105981 <memmove>
}
801086f1:	c9                   	leave  
801086f2:	c3                   	ret    

801086f3 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801086f3:	55                   	push   %ebp
801086f4:	89 e5                	mov    %esp,%ebp
801086f6:	53                   	push   %ebx
801086f7:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801086fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801086fd:	25 ff 0f 00 00       	and    $0xfff,%eax
80108702:	85 c0                	test   %eax,%eax
80108704:	74 0c                	je     80108712 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108706:	c7 04 24 80 94 10 80 	movl   $0x80109480,(%esp)
8010870d:	e8 28 7e ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108712:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108719:	e9 a9 00 00 00       	jmp    801087c7 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010871e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108721:	8b 55 0c             	mov    0xc(%ebp),%edx
80108724:	01 d0                	add    %edx,%eax
80108726:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010872d:	00 
8010872e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108732:	8b 45 08             	mov    0x8(%ebp),%eax
80108735:	89 04 24             	mov    %eax,(%esp)
80108738:	e8 99 fb ff ff       	call   801082d6 <walkpgdir>
8010873d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108740:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108744:	75 0c                	jne    80108752 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108746:	c7 04 24 a3 94 10 80 	movl   $0x801094a3,(%esp)
8010874d:	e8 e8 7d ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108752:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108755:	8b 00                	mov    (%eax),%eax
80108757:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010875c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010875f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108762:	8b 55 18             	mov    0x18(%ebp),%edx
80108765:	29 c2                	sub    %eax,%edx
80108767:	89 d0                	mov    %edx,%eax
80108769:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010876e:	77 0f                	ja     8010877f <loaduvm+0x8c>
      n = sz - i;
80108770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108773:	8b 55 18             	mov    0x18(%ebp),%edx
80108776:	29 c2                	sub    %eax,%edx
80108778:	89 d0                	mov    %edx,%eax
8010877a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010877d:	eb 07                	jmp    80108786 <loaduvm+0x93>
    else
      n = PGSIZE;
8010877f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108789:	8b 55 14             	mov    0x14(%ebp),%edx
8010878c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010878f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108792:	89 04 24             	mov    %eax,(%esp)
80108795:	e8 b9 f6 ff ff       	call   80107e53 <p2v>
8010879a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010879d:	89 54 24 0c          	mov    %edx,0xc(%esp)
801087a1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801087a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801087a9:	8b 45 10             	mov    0x10(%ebp),%eax
801087ac:	89 04 24             	mov    %eax,(%esp)
801087af:	e8 46 9a ff ff       	call   801021fa <readi>
801087b4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801087b7:	74 07                	je     801087c0 <loaduvm+0xcd>
      return -1;
801087b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087be:	eb 18                	jmp    801087d8 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801087c0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801087c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ca:	3b 45 18             	cmp    0x18(%ebp),%eax
801087cd:	0f 82 4b ff ff ff    	jb     8010871e <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801087d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087d8:	83 c4 24             	add    $0x24,%esp
801087db:	5b                   	pop    %ebx
801087dc:	5d                   	pop    %ebp
801087dd:	c3                   	ret    

801087de <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801087de:	55                   	push   %ebp
801087df:	89 e5                	mov    %esp,%ebp
801087e1:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801087e4:	8b 45 10             	mov    0x10(%ebp),%eax
801087e7:	85 c0                	test   %eax,%eax
801087e9:	79 0a                	jns    801087f5 <allocuvm+0x17>
    return 0;
801087eb:	b8 00 00 00 00       	mov    $0x0,%eax
801087f0:	e9 c1 00 00 00       	jmp    801088b6 <allocuvm+0xd8>
  if(newsz < oldsz)
801087f5:	8b 45 10             	mov    0x10(%ebp),%eax
801087f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087fb:	73 08                	jae    80108805 <allocuvm+0x27>
    return oldsz;
801087fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108800:	e9 b1 00 00 00       	jmp    801088b6 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108805:	8b 45 0c             	mov    0xc(%ebp),%eax
80108808:	05 ff 0f 00 00       	add    $0xfff,%eax
8010880d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108812:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108815:	e9 8d 00 00 00       	jmp    801088a7 <allocuvm+0xc9>
    mem = kalloc();
8010881a:	e8 30 ab ff ff       	call   8010334f <kalloc>
8010881f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108822:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108826:	75 2c                	jne    80108854 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108828:	c7 04 24 c1 94 10 80 	movl   $0x801094c1,(%esp)
8010882f:	e8 6c 7b ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108834:	8b 45 0c             	mov    0xc(%ebp),%eax
80108837:	89 44 24 08          	mov    %eax,0x8(%esp)
8010883b:	8b 45 10             	mov    0x10(%ebp),%eax
8010883e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108842:	8b 45 08             	mov    0x8(%ebp),%eax
80108845:	89 04 24             	mov    %eax,(%esp)
80108848:	e8 6b 00 00 00       	call   801088b8 <deallocuvm>
      return 0;
8010884d:	b8 00 00 00 00       	mov    $0x0,%eax
80108852:	eb 62                	jmp    801088b6 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108854:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010885b:	00 
8010885c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108863:	00 
80108864:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108867:	89 04 24             	mov    %eax,(%esp)
8010886a:	e8 43 d0 ff ff       	call   801058b2 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010886f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108872:	89 04 24             	mov    %eax,(%esp)
80108875:	e8 cc f5 ff ff       	call   80107e46 <v2p>
8010887a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010887d:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108884:	00 
80108885:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108889:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108890:	00 
80108891:	89 54 24 04          	mov    %edx,0x4(%esp)
80108895:	8b 45 08             	mov    0x8(%ebp),%eax
80108898:	89 04 24             	mov    %eax,(%esp)
8010889b:	e8 d8 fa ff ff       	call   80108378 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801088a0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088aa:	3b 45 10             	cmp    0x10(%ebp),%eax
801088ad:	0f 82 67 ff ff ff    	jb     8010881a <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801088b3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801088b6:	c9                   	leave  
801088b7:	c3                   	ret    

801088b8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801088b8:	55                   	push   %ebp
801088b9:	89 e5                	mov    %esp,%ebp
801088bb:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801088be:	8b 45 10             	mov    0x10(%ebp),%eax
801088c1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088c4:	72 08                	jb     801088ce <deallocuvm+0x16>
    return oldsz;
801088c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801088c9:	e9 a4 00 00 00       	jmp    80108972 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801088ce:	8b 45 10             	mov    0x10(%ebp),%eax
801088d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801088d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801088de:	e9 80 00 00 00       	jmp    80108963 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801088e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801088ed:	00 
801088ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801088f2:	8b 45 08             	mov    0x8(%ebp),%eax
801088f5:	89 04 24             	mov    %eax,(%esp)
801088f8:	e8 d9 f9 ff ff       	call   801082d6 <walkpgdir>
801088fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108900:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108904:	75 09                	jne    8010890f <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108906:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010890d:	eb 4d                	jmp    8010895c <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
8010890f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108912:	8b 00                	mov    (%eax),%eax
80108914:	83 e0 01             	and    $0x1,%eax
80108917:	85 c0                	test   %eax,%eax
80108919:	74 41                	je     8010895c <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
8010891b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010891e:	8b 00                	mov    (%eax),%eax
80108920:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108925:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108928:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010892c:	75 0c                	jne    8010893a <deallocuvm+0x82>
        panic("kfree");
8010892e:	c7 04 24 d9 94 10 80 	movl   $0x801094d9,(%esp)
80108935:	e8 00 7c ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
8010893a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010893d:	89 04 24             	mov    %eax,(%esp)
80108940:	e8 0e f5 ff ff       	call   80107e53 <p2v>
80108945:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108948:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010894b:	89 04 24             	mov    %eax,(%esp)
8010894e:	e8 63 a9 ff ff       	call   801032b6 <kfree>
      *pte = 0;
80108953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108956:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010895c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108966:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108969:	0f 82 74 ff ff ff    	jb     801088e3 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010896f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108972:	c9                   	leave  
80108973:	c3                   	ret    

80108974 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108974:	55                   	push   %ebp
80108975:	89 e5                	mov    %esp,%ebp
80108977:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010897a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010897e:	75 0c                	jne    8010898c <freevm+0x18>
    panic("freevm: no pgdir");
80108980:	c7 04 24 df 94 10 80 	movl   $0x801094df,(%esp)
80108987:	e8 ae 7b ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010898c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108993:	00 
80108994:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010899b:	80 
8010899c:	8b 45 08             	mov    0x8(%ebp),%eax
8010899f:	89 04 24             	mov    %eax,(%esp)
801089a2:	e8 11 ff ff ff       	call   801088b8 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801089a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089ae:	eb 48                	jmp    801089f8 <freevm+0x84>
    if(pgdir[i] & PTE_P){
801089b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089ba:	8b 45 08             	mov    0x8(%ebp),%eax
801089bd:	01 d0                	add    %edx,%eax
801089bf:	8b 00                	mov    (%eax),%eax
801089c1:	83 e0 01             	and    $0x1,%eax
801089c4:	85 c0                	test   %eax,%eax
801089c6:	74 2c                	je     801089f4 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801089c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089d2:	8b 45 08             	mov    0x8(%ebp),%eax
801089d5:	01 d0                	add    %edx,%eax
801089d7:	8b 00                	mov    (%eax),%eax
801089d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089de:	89 04 24             	mov    %eax,(%esp)
801089e1:	e8 6d f4 ff ff       	call   80107e53 <p2v>
801089e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801089e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ec:	89 04 24             	mov    %eax,(%esp)
801089ef:	e8 c2 a8 ff ff       	call   801032b6 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801089f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089f8:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801089ff:	76 af                	jbe    801089b0 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108a01:	8b 45 08             	mov    0x8(%ebp),%eax
80108a04:	89 04 24             	mov    %eax,(%esp)
80108a07:	e8 aa a8 ff ff       	call   801032b6 <kfree>
}
80108a0c:	c9                   	leave  
80108a0d:	c3                   	ret    

80108a0e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108a0e:	55                   	push   %ebp
80108a0f:	89 e5                	mov    %esp,%ebp
80108a11:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108a14:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a1b:	00 
80108a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a23:	8b 45 08             	mov    0x8(%ebp),%eax
80108a26:	89 04 24             	mov    %eax,(%esp)
80108a29:	e8 a8 f8 ff ff       	call   801082d6 <walkpgdir>
80108a2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108a31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a35:	75 0c                	jne    80108a43 <clearpteu+0x35>
    panic("clearpteu");
80108a37:	c7 04 24 f0 94 10 80 	movl   $0x801094f0,(%esp)
80108a3e:	e8 f7 7a ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80108a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a46:	8b 00                	mov    (%eax),%eax
80108a48:	83 e0 fb             	and    $0xfffffffb,%eax
80108a4b:	89 c2                	mov    %eax,%edx
80108a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a50:	89 10                	mov    %edx,(%eax)
}
80108a52:	c9                   	leave  
80108a53:	c3                   	ret    

80108a54 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108a54:	55                   	push   %ebp
80108a55:	89 e5                	mov    %esp,%ebp
80108a57:	53                   	push   %ebx
80108a58:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108a5b:	e8 b0 f9 ff ff       	call   80108410 <setupkvm>
80108a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a67:	75 0a                	jne    80108a73 <copyuvm+0x1f>
    return 0;
80108a69:	b8 00 00 00 00       	mov    $0x0,%eax
80108a6e:	e9 fd 00 00 00       	jmp    80108b70 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108a73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a7a:	e9 d0 00 00 00       	jmp    80108b4f <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a89:	00 
80108a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a91:	89 04 24             	mov    %eax,(%esp)
80108a94:	e8 3d f8 ff ff       	call   801082d6 <walkpgdir>
80108a99:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a9c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108aa0:	75 0c                	jne    80108aae <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108aa2:	c7 04 24 fa 94 10 80 	movl   $0x801094fa,(%esp)
80108aa9:	e8 8c 7a ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108aae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ab1:	8b 00                	mov    (%eax),%eax
80108ab3:	83 e0 01             	and    $0x1,%eax
80108ab6:	85 c0                	test   %eax,%eax
80108ab8:	75 0c                	jne    80108ac6 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108aba:	c7 04 24 14 95 10 80 	movl   $0x80109514,(%esp)
80108ac1:	e8 74 7a ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108ac6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ac9:	8b 00                	mov    (%eax),%eax
80108acb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ad0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108ad3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ad6:	8b 00                	mov    (%eax),%eax
80108ad8:	25 ff 0f 00 00       	and    $0xfff,%eax
80108add:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108ae0:	e8 6a a8 ff ff       	call   8010334f <kalloc>
80108ae5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108ae8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108aec:	75 02                	jne    80108af0 <copyuvm+0x9c>
      goto bad;
80108aee:	eb 70                	jmp    80108b60 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108af0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108af3:	89 04 24             	mov    %eax,(%esp)
80108af6:	e8 58 f3 ff ff       	call   80107e53 <p2v>
80108afb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b02:	00 
80108b03:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b0a:	89 04 24             	mov    %eax,(%esp)
80108b0d:	e8 6f ce ff ff       	call   80105981 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108b12:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108b15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b18:	89 04 24             	mov    %eax,(%esp)
80108b1b:	e8 26 f3 ff ff       	call   80107e46 <v2p>
80108b20:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b23:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108b27:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108b2b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b32:	00 
80108b33:	89 54 24 04          	mov    %edx,0x4(%esp)
80108b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b3a:	89 04 24             	mov    %eax,(%esp)
80108b3d:	e8 36 f8 ff ff       	call   80108378 <mappages>
80108b42:	85 c0                	test   %eax,%eax
80108b44:	79 02                	jns    80108b48 <copyuvm+0xf4>
      goto bad;
80108b46:	eb 18                	jmp    80108b60 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108b48:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b52:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b55:	0f 82 24 ff ff ff    	jb     80108a7f <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b5e:	eb 10                	jmp    80108b70 <copyuvm+0x11c>

bad:
  freevm(d);
80108b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b63:	89 04 24             	mov    %eax,(%esp)
80108b66:	e8 09 fe ff ff       	call   80108974 <freevm>
  return 0;
80108b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b70:	83 c4 44             	add    $0x44,%esp
80108b73:	5b                   	pop    %ebx
80108b74:	5d                   	pop    %ebp
80108b75:	c3                   	ret    

80108b76 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108b76:	55                   	push   %ebp
80108b77:	89 e5                	mov    %esp,%ebp
80108b79:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108b7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b83:	00 
80108b84:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b87:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80108b8e:	89 04 24             	mov    %eax,(%esp)
80108b91:	e8 40 f7 ff ff       	call   801082d6 <walkpgdir>
80108b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9c:	8b 00                	mov    (%eax),%eax
80108b9e:	83 e0 01             	and    $0x1,%eax
80108ba1:	85 c0                	test   %eax,%eax
80108ba3:	75 07                	jne    80108bac <uva2ka+0x36>
    return 0;
80108ba5:	b8 00 00 00 00       	mov    $0x0,%eax
80108baa:	eb 25                	jmp    80108bd1 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108baf:	8b 00                	mov    (%eax),%eax
80108bb1:	83 e0 04             	and    $0x4,%eax
80108bb4:	85 c0                	test   %eax,%eax
80108bb6:	75 07                	jne    80108bbf <uva2ka+0x49>
    return 0;
80108bb8:	b8 00 00 00 00       	mov    $0x0,%eax
80108bbd:	eb 12                	jmp    80108bd1 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc2:	8b 00                	mov    (%eax),%eax
80108bc4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bc9:	89 04 24             	mov    %eax,(%esp)
80108bcc:	e8 82 f2 ff ff       	call   80107e53 <p2v>
}
80108bd1:	c9                   	leave  
80108bd2:	c3                   	ret    

80108bd3 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108bd3:	55                   	push   %ebp
80108bd4:	89 e5                	mov    %esp,%ebp
80108bd6:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108bd9:	8b 45 10             	mov    0x10(%ebp),%eax
80108bdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108bdf:	e9 87 00 00 00       	jmp    80108c6b <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108be4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108be7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bec:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80108bf9:	89 04 24             	mov    %eax,(%esp)
80108bfc:	e8 75 ff ff ff       	call   80108b76 <uva2ka>
80108c01:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108c04:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108c08:	75 07                	jne    80108c11 <copyout+0x3e>
      return -1;
80108c0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c0f:	eb 69                	jmp    80108c7a <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108c11:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c14:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108c17:	29 c2                	sub    %eax,%edx
80108c19:	89 d0                	mov    %edx,%eax
80108c1b:	05 00 10 00 00       	add    $0x1000,%eax
80108c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c26:	3b 45 14             	cmp    0x14(%ebp),%eax
80108c29:	76 06                	jbe    80108c31 <copyout+0x5e>
      n = len;
80108c2b:	8b 45 14             	mov    0x14(%ebp),%eax
80108c2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108c31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c34:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c37:	29 c2                	sub    %eax,%edx
80108c39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c3c:	01 c2                	add    %eax,%edx
80108c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c41:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c48:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c4c:	89 14 24             	mov    %edx,(%esp)
80108c4f:	e8 2d cd ff ff       	call   80105981 <memmove>
    len -= n;
80108c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c57:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c5d:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108c60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c63:	05 00 10 00 00       	add    $0x1000,%eax
80108c68:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108c6b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108c6f:	0f 85 6f ff ff ff    	jne    80108be4 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108c75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c7a:	c9                   	leave  
80108c7b:	c3                   	ret    