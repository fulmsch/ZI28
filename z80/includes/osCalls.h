#define coldStart  0000h

#define putc       0008h
#define setOutput  000Ch
#define getc       0010h
#define setInput   0014h

#define sdRead     0020h

#define monitor    0038h

#define u_open     monitor + 3
#define u_close    u_open + 3
#define u_read     u_close + 3
#define u_write    u_read + 3
#define u_seek     u_write + 3

#define SEEK_SET  0
#define SEEK_PCUR 1
#define SEEK_NCUR 2
#define SEEK_END  3
