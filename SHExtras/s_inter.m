/* Copyright (c) 1997-1999 Miller Puckette.
* For information on usage and redistribution, and for a DISCLAIMER OF ALL
* WARRANTIES, see the file, "LICENSE.txt," in this distribution.  */

/* Pd side of the Pd/Pd-gui interface.  Also, some system interface routines
that didn't really belong anywhere. */

#import "s_inter.h"
//#include "s_stuff.h"
//#include "m_imp.h"
//#include "g_canvas.h"   /* for GUI queueing stuff */

#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <sys/resource.h>

//sh #ifdef HAVE_BSTRING_H
//sh 	#include <bstring.h>
//sh #endif

#include <stdarg.h>
#include <signal.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>


#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>


//sh #define DEBUG_MESSUP 1      /* messages up from pd to pd-gui */
//sh #define DEBUG_MESSDOWN 2    /* messages down from pd-gui to pd */

//sh #ifndef PDBINDIR
//sh #define PDBINDIR "bin/"
//sh #endif

//sh #ifndef WISHAPP
//sh #define WISHAPP "wish84.exe"
//sh #endif

//sh #define LOCALHOST "localhost"


//sh typedef struct _fdpoll
//sh {
//sh     int fdp_fd;
//sh     t_fdpollfn fdp_fn;
//sh     void *fdp_ptr;
//sh } t_fdpoll;

//sh #define INBUFSIZE 4096

//sh struct _socketreceiver
//sh {
//sh     char *sr_inbuf;
//sh     int sr_inhead;
//sh     int sr_intail;
//sh     void *sr_owner;
//sh     int sr_udp;
//sh     t_socketnotifier sr_notifier;
//sh     t_socketreceivefn sr_socketreceivefn;
//sh };

//sh extern char pd_version[];
//sh extern int sys_guisetportnumber;
//sh extern char sys_font[]; /* tb: typeface */

//sh static int sys_nfdpoll;
//sh static t_fdpoll *sys_fdpoll;
//sh static int sys_maxfd;
//sh static int sys_guisock;

//sh static t_binbuf *inbinbuf;
//sh static t_socketreceiver *sys_socketreceiver;
//sh extern int sys_addhist(int phase);

/* ----------- functions for timing, signals, priorities, etc  --------- */



/* get "real time" in seconds; take the
first time we get called as a reference time of zero. */
double sys_getrealtime(void)    
{
    static struct timeval then;
    struct timeval now;
    gettimeofday(&now, 0);
    if (then.tv_sec == 0 && then.tv_usec == 0) then = now;
    return ((now.tv_sec - then.tv_sec) + (1./1000000.) * (now.tv_usec - then.tv_usec));
}

//sh static int sys_domicrosleep(int microsec, int pollem)
//sh {
//sh     struct timeval timout;
//sh     int i, didsomething = 0;
//sh     t_fdpoll *fp;
//sh     timout.tv_sec = 0;
//sh     timout.tv_usec = microsec;
 //sh    if (pollem)
//sh     {
//sh         fd_set readset, writeset, exceptset;
//sh         FD_ZERO(&writeset);
//sh         FD_ZERO(&readset);
//sh         FD_ZERO(&exceptset);
 //sh        for (fp = sys_fdpoll, i = sys_nfdpoll; i--; fp++)
//sh             FD_SET(fp->fdp_fd, &readset);
//sh 
//sh         select(sys_maxfd+1, &readset, &writeset, &exceptset, &timout);
//sh         for (i = 0; i < sys_nfdpoll; i++)
//sh             if (FD_ISSET(sys_fdpoll[i].fdp_fd, &readset))
//sh         {
//sh #ifdef THREAD_LOCKING
//sh             sys_lock();
//sh #endif
//sh             (*sys_fdpoll[i].fdp_fn)(sys_fdpoll[i].fdp_ptr, sys_fdpoll[i].fdp_fd);
//sh #ifdef THREAD_LOCKING
//sh             sys_unlock();
//sh #endif
//sh             didsomething = 1;
//sh         }
//sh         return (didsomething);
//sh     }
//sh     else
//sh     {
//sh         select(0, 0, 0, 0, &timout);
//sh         return (0);
//sh     }
//sh }

//sh void sys_microsleep(int microsec)
//sh {
//sh     sys_domicrosleep(microsec, 1);
//sh }

//sh typedef void (*sighandler_t)(int);

//sh static void sys_signal(int signo, sighandler_t sigfun)
//sh {
//sh     struct sigaction action;
//sh     action.sa_flags = 0;
//sh     action.sa_handler = sigfun;
//sh     memset(&action.sa_mask, 0, sizeof(action.sa_mask));
//sh #if 0  /* GG says: don't use that */
//sh     action.sa_restorer = 0;
//sh #endif
//sh     if (sigaction(signo, &action, 0) < 0)
//sh         perror("sigaction");
//sh }

//sh static void sys_exithandler(int n)
//sh {
//sh     static int trouble = 0;
//sh     if (!trouble)
//sh    {
//sh         trouble = 1;
//sh         fprintf(stderr, "Pd: signal %d\n", n);
//sh         sys_bail(1);
//sh     }
//sh     else _exit(1);
//sh }

//sh static void sys_alarmhandler(int n)
//sh {
//sh     fprintf(stderr, "Pd: system call timed out\n");
//sh }

//sh static void sys_huphandler(int n)
//sh {
//sh     struct timeval timout;
//sh     timout.tv_sec = 0;
//sh     timout.tv_usec = 30000;
//sh     select(1, 0, 0, 0, &timout);
//sh }

//sh void sys_setalarm(int microsec)
//sh {
//sh     struct itimerval gonzo;
//sh #if 0
//sh     fprintf(stderr, "timer %d\n", microsec);
//sh #endif
 //sh    gonzo.it_interval.tv_sec = 0;
//sh     gonzo.it_interval.tv_usec = 0;
//sh     gonzo.it_value.tv_sec = 0;
//sh     gonzo.it_value.tv_usec = microsec;
//sh     if (microsec)
//sh         sys_signal(SIGALRM, sys_alarmhandler);
//sh     else sys_signal(SIGALRM, SIG_IGN);
//sh     setitimer(ITIMER_REAL, &gonzo, 0);
//sh }






/* ------------------ receiving incoming messages over sockets ------------- */

//sh void sys_sockerror(char *s)
//sh {
//sh     int err = errno;
//sh     fprintf(stderr, "%s: %s (%d)\n", s, strerror(err), err);
//sh }

//sh void sys_addpollfn(int fd, t_fdpollfn fn, void *ptr)
//sh {
//sh     int nfd = sys_nfdpoll;
//sh     int size = nfd * sizeof(t_fdpoll);
//sh     t_fdpoll *fp;
//sh     sys_fdpoll = (t_fdpoll *)t_resizebytes(sys_fdpoll, size,
//sh         size + sizeof(t_fdpoll));
//sh     fp = sys_fdpoll + nfd;
//sh     fp->fdp_fd = fd;
//sh     fp->fdp_fn = fn;
//sh     fp->fdp_ptr = ptr;
//sh     sys_nfdpoll = nfd + 1;
//sh     if (fd >= sys_maxfd) sys_maxfd = fd + 1;
//sh }

//sh void sys_rmpollfn(int fd)
//sh {
//sh     int nfd = sys_nfdpoll;
//sh     int i, size = nfd * sizeof(t_fdpoll);
//sh     t_fdpoll *fp;
//sh     for (i = nfd, fp = sys_fdpoll; i--; fp++)
//sh     {
//sh         if (fp->fdp_fd == fd)
//sh         {
//sh             while (i--)
//sh             {
//sh                 fp[0] = fp[1];
//sh                 fp++;
//sh             }
//sh             sys_fdpoll = (t_fdpoll *)t_resizebytes(sys_fdpoll, size,
 //sh               size - sizeof(t_fdpoll));
 //sh            sys_nfdpoll = nfd - 1;
 //sh            return;
//sh         }
//sh     }
//sh     post("warning: %d removed from poll list but not found", fd);
//sh }

//sh t_socketreceiver *socketreceiver_new(void *owner, t_socketnotifier notifier, t_socketreceivefn socketreceivefn, int udp)
//sh {
//sh     t_socketreceiver *x = (t_socketreceiver *)getbytes(sizeof(*x));
//sh     x->sr_inhead = x->sr_intail = 0;
//sh     x->sr_owner = owner;
//sh     x->sr_notifier = notifier;
//sh     x->sr_socketreceivefn = socketreceivefn;
//sh     x->sr_udp = udp;
//sh     if (!(x->sr_inbuf = malloc(INBUFSIZE))) bug("t_socketreceiver");;
//sh     return (x);
//sh }

//sh void socketreceiver_free(t_socketreceiver *x)
//sh {
//sh     free(x->sr_inbuf);
//sh     freebytes(x, sizeof(*x));
//sh }

    /* this is in a separately called subroutine so that the buffer isn't
    sitting on the stack while the messages are getting passed. */
//sh static int socketreceiver_doread(t_socketreceiver *x)
//sh {
 //sh    char messbuf[INBUFSIZE], *bp = messbuf;
 //sh    int indx;
//sh     int inhead = x->sr_inhead;
//sh     int intail = x->sr_intail;
//sh     char *inbuf = x->sr_inbuf;
//sh     if (intail == inhead) return (0);
//sh     for (indx = intail; indx != inhead; indx = (indx+1)&(INBUFSIZE-1))
//sh     {
            /* if we hit a semi that isn't preceeded by a \, it's a message
            boundary.  LATER we should deal with the possibility that the
            preceeding \ might itself be escaped! */
 //sh        char c = *bp++ = inbuf[indx];
//sh         if (c == ';' && (!indx || inbuf[indx-1] != '\\'))
//sh         {
 //sh            intail = (indx+1)&(INBUFSIZE-1);
 //sh            binbuf_text(inbinbuf, messbuf, bp - messbuf);
 //sh            if (sys_debuglevel & DEBUG_MESSDOWN)
 //sh            {
//sh                 write(2,  messbuf, bp - messbuf);
//sh                 write(2, "\n", 1);
//sh             }
//sh             x->sr_inhead = inhead;
//sh             x->sr_intail = intail;
//sh             return (1);
//sh         }
//sh    }
//sh     return (0);
//sh }

//sh static void socketreceiver_getudp(t_socketreceiver *x, int fd)
//sh {
//sh     char buf[INBUFSIZE+1];
//sh     int ret = recv(fd, buf, INBUFSIZE, 0);
//sh     if (ret < 0)
//sh     {
 //sh        sys_sockerror("recv");
 //sh        sys_rmpollfn(fd);
 //sh        sys_closesocket(fd);
 //sh    }
 //sh    else if (ret > 0)
 //sh    {
 //sh        buf[ret] = 0;
//sh #if 0
 //sh        post("%s", buf);
//sh #endif
 //sh        if (buf[ret-1] != '\n')
//sh         {
//sh #if 0
//sh             buf[ret] = 0;
//sh             error("dropped bad buffer %s\n", buf);
//sh #endif
//sh         }
//sh         else
//sh         {
//sh             char *semi = strchr(buf, ';');
//sh             if (semi) 
 //sh               *semi = 0;
//sh             binbuf_text(inbinbuf, buf, strlen(buf));
//sh             outlet_setstacklim();
//sh             if (x->sr_socketreceivefn)
//sh                 (*x->sr_socketreceivefn)(x->sr_owner, inbinbuf);
//sh             else bug("socketreceiver_getudp");
//sh        }
//sh     }
//sh }

//sh void sys_exit(void);

//sh void socketreceiver_read(t_socketreceiver *x, int fd)
//sh {
//sh     if (x->sr_udp)   /* UDP ("datagram") socket protocol */
//sh         socketreceiver_getudp(x, fd);
//sh     else  /* TCP ("streaming") socket protocol */
//sh     {
//sh         //sh char *semi;
//sh         int readto =
//sh             (x->sr_inhead >= x->sr_intail ? INBUFSIZE : x->sr_intail-1);
 //sh        int ret;
//sh 
//sh            /* the input buffer might be full.  If so, drop the whole thing */
//sh         if (readto == x->sr_inhead)
//sh         {
//sh             fprintf(stderr, "pd: dropped message from gui\n");
//sh             x->sr_inhead = x->sr_intail = 0;
//sh             readto = INBUFSIZE;
//sh         }
//sh         else
//sh        {
//sh             ret = recv(fd, x->sr_inbuf + x->sr_inhead,
//sh                 readto - x->sr_inhead, 0);
//sh             if (ret < 0)
//sh             {
//sh                 sys_sockerror("recv");
//sh                 if (x == sys_socketreceiver) sys_bail(1);
//sh                 else
//sh                 {
//sh                     if (x->sr_notifier) (*x->sr_notifier)(x->sr_owner);
//sh                     sys_rmpollfn(fd);
//sh                     sys_closesocket(fd);
//sh                 }
//sh             }
//sh             else if (ret == 0)
//sh             {
//sh                 if (x == sys_socketreceiver)
//sh                 {
//sh                     fprintf(stderr, "pd: exiting\n");
 //sh                    sys_exit();
//sh                    return;
//sh                }
//sh                 else
//sh                 {
//sh                    post("EOF on socket %d\n", fd);
 //sh                    if (x->sr_notifier) (*x->sr_notifier)(x->sr_owner);
//sh                    sys_rmpollfn(fd);
 //sh                    sys_closesocket(fd);
 //sh                }
//sh             }
//sh             else
//sh             {
//sh                 x->sr_inhead += ret;
//sh                 if (x->sr_inhead >= INBUFSIZE) x->sr_inhead = 0;
//sh                while (socketreceiver_doread(x))
//sh                 {
 //sh                    outlet_setstacklim();
 //sh                    if (x->sr_socketreceivefn)
 //sh                        (*x->sr_socketreceivefn)(x->sr_owner, inbinbuf);
 //sh                    else binbuf_eval(inbinbuf, 0, 0, 0);
//sh                }
//sh             }
//sh         }
//sh     }
//sh }

//sh void sys_closesocket(int fd)
//sh {
//sh 
//sh     close(fd);
//sh 
//sh 
//sh }

/* ---------------------- sending messages to the GUI ------------------ */
//sh #define GUI_ALLOCCHUNK 8192
//sh #define GUI_UPDATESLICE 512 /* how much we try to do in one idle period */
//sh #define GUI_BYTESPERPING 1024 /* how much we send up per ping */

//sh typedef struct _guiqueue
//sh {
//sh     void *gq_client;
//sh     t_glist *gq_glist;
//sh     t_guicallbackfn gq_fn;
//sh     struct _guiqueue *gq_next;
//sh } t_guiqueue;

//sh static t_guiqueue *sys_guiqueuehead;
//sh static char *sys_guibuf;
//sh static int sys_guibufhead;
//sh static int sys_guibuftail;
//sh static int sys_guibufsize;
//sh static int sys_waitingforping;
//sh static int sys_bytessincelastping;

//sh static void sys_trytogetmoreguibuf(int newsize)
//sh {
//sh     char *newbuf = realloc(sys_guibuf, newsize);
//sh #if 0
//sh     static int sizewas;
//sh     if (newsize > 70000 && sizewas < 70000)
//sh     {
 //sh        int i;
//sh         for (i = sys_guibuftail; i < sys_guibufhead; i++)
//sh             fputc(sys_guibuf[i], stderr);
//sh     }
//sh     sizewas = newsize;
//sh #endif
//sh #if 0
//sh     fprintf(stderr, "new size %d (head %d, tail %d)\n",
//sh         newsize, sys_guibufhead, sys_guibuftail);
//sh #endif

        /* if realloc fails, make a last-ditch attempt to stay alive by
        synchronously writing out the existing contents.  LATER test
        this by intentionally setting newbuf to zero */
//sh     if (!newbuf)
//sh     {
//sh         int bytestowrite = sys_guibuftail - sys_guibufhead;
//sh         int written = 0;
//sh         while (1)
//sh         {
//sh             int res = send(sys_guisock,
//sh                 sys_guibuf + sys_guibuftail + written, bytestowrite, 0);
//sh             if (res < 0)
//sh             {
//sh                 perror("pd output pipe");
//sh                 sys_bail(1);
//sh             }
//sh             else
//sh             {
//sh                 written += res;
//sh                 if (written >= bytestowrite)
//sh                     break;
//sh             }
//sh         }
//sh         sys_guibufhead = sys_guibuftail = 0;
//sh     }
//sh     else
//sh     {
//sh         sys_guibufsize = newsize;
//sh         sys_guibuf = newbuf;
//sh     }
//sh }

//sh void sys_vgui(char *fmt, ...)
//sh {
	// printf( "s_inter.c: sys_vgui\n"); // called too often!

//sh    int msglen; //sh bytesleft, headwas, nwrote;
//sh     va_list ap;

//sh     if (sys_nogui)
//sh         return;
//sh     if (!sys_guibuf)
//sh     {
//sh         if (!(sys_guibuf = malloc(GUI_ALLOCCHUNK)))
//sh         {
//sh             fprintf(stderr, "Pd: couldn't allocate GUI buffer\n");
//sh             sys_bail(1);
//sh         }
//sh         sys_guibufsize = GUI_ALLOCCHUNK;
//sh         sys_guibufhead = sys_guibuftail = 0;
//sh     }
//sh     if (sys_guibufhead > sys_guibufsize - (GUI_ALLOCCHUNK/2))
//sh         sys_trytogetmoreguibuf(sys_guibufsize + GUI_ALLOCCHUNK);
//sh     va_start(ap, fmt);
//sh     msglen = vsnprintf(sys_guibuf + sys_guibufhead,
//sh         sys_guibufsize - sys_guibufhead, fmt, ap);
//sh     va_end(ap);
//sh     if(msglen < 0) 
//sh     {
//sh         fprintf(stderr, "Pd: buffer space wasn't sufficient for long GUI string\n");
//sh         return;
//sh     }
//sh     if (msglen >= sys_guibufsize - sys_guibufhead)
//sh     {
 //sh        int msglen2, newsize = sys_guibufsize + 1 +
 //sh            (msglen > GUI_ALLOCCHUNK ? msglen : GUI_ALLOCCHUNK);
 //sh        sys_trytogetmoreguibuf(newsize);

//sh         va_start(ap, fmt);
//sh         msglen2 = vsnprintf(sys_guibuf + sys_guibufhead,
//sh             sys_guibufsize - sys_guibufhead, fmt, ap);
//sh         va_end(ap);
//sh         if (msglen2 != msglen)
//sh             bug("sys_vgui");
//sh         if (msglen >= sys_guibufsize - sys_guibufhead)
//sh             msglen = sys_guibufsize - sys_guibufhead;
//sh     }
//sh     if (sys_debuglevel & DEBUG_MESSUP)
//sh         fprintf(stderr, "%s",  sys_guibuf + sys_guibufhead);
//sh     sys_guibufhead += msglen;
//sh     sys_bytessincelastping += msglen;
//sh }

//sh void sys_gui(char *s)
//sh {
//sh 	printf( "s_inter.c: sys_vgui\n");
//sh 
//sh     sys_vgui("%s", s);
//sh }

//sh static int sys_flushtogui( void)
//sh {
//sh     int writesize = sys_guibufhead - sys_guibuftail, nwrote = 0;
//sh     if (writesize > 0)
//sh         nwrote = send(sys_guisock, sys_guibuf + sys_guibuftail, writesize, 0);

//sh #if 0   
//sh     if (writesize)
//sh         fprintf(stderr, "wrote %d of %d\n", nwrote, writesize);
//sh #endif

//sh     if (nwrote < 0)
//sh     {
//sh         perror("pd-to-gui socket");
 //sh        sys_bail(1);
//sh     }
 //sh    else if (!nwrote)
//sh         return (0);
//sh     else if (nwrote >= sys_guibufhead - sys_guibuftail)
//sh          sys_guibufhead = sys_guibuftail = 0;
//sh     else if (nwrote)
//sh     {
//sh         sys_guibuftail += nwrote;
//sh         if (sys_guibuftail > (sys_guibufsize >> 2))
//sh         {
//sh            memmove(sys_guibuf, sys_guibuf + sys_guibuftail,
 //sh                sys_guibufhead - sys_guibuftail);
//sh             sys_guibufhead = sys_guibufhead - sys_guibuftail;
//sh             sys_guibuftail = 0;
//sh         }
//sh     }
//sh     return (1);
//sh }

//sh void glob_ping(t_pd *dummy)
//sh {
//sh     sys_waitingforping = 0;
//sh }

//sh static int sys_flushqueue(void )
//sh {
//sh     int wherestop = sys_bytessincelastping + GUI_UPDATESLICE;
//sh     if (wherestop + (GUI_UPDATESLICE >> 1) > GUI_BYTESPERPING)
//sh         wherestop = 0x7fffffff;
//sh     if (sys_waitingforping)
//sh         return (0);
//sh    if (!sys_guiqueuehead)
//sh         return (0);
//sh     while (1)
//sh     {
//sh         if (sys_bytessincelastping >= GUI_BYTESPERPING)
//sh         {
//sh            sys_gui("pdtk_ping\n");
//sh             sys_bytessincelastping = 0;
//sh            sys_waitingforping = 1;
//sh             return (1);
//sh         }
//sh         if (sys_guiqueuehead)
//sh         {
//sh             t_guiqueue *headwas = sys_guiqueuehead;
//sh             sys_guiqueuehead = headwas->gq_next;
//sh             (*headwas->gq_fn)(headwas->gq_client, headwas->gq_glist);
//sh            t_freebytes(headwas, sizeof(*headwas));
//sh             if (sys_bytessincelastping >= wherestop)
//sh                 break;
//sh         }
//sh         else break;
//sh     }
//sh     sys_flushtogui();
//sh     return (1);
//sh }

    /* flush output buffer and update queue to gui in small time slices */
//sh static int sys_poll_togui(void) /* returns 1 if did anything */
//sh {
//sh     if (sys_nogui)
//sh         return (0);
        /* see if there is stuff still in the buffer, if so we
            must have fallen behind, so just try to clear that. */
//sh     if (sys_flushtogui())
//sh         return (1);
        /* if the flush wasn't complete, wait. */
//sh     if (sys_guibufhead > sys_guibuftail)
//sh         return (0);
    
        /* check for queued updates */
//sh     if (sys_flushqueue())
//sh         return (1);
    
 //sh    return (0);
//sh }

    /* if some GUI object is having to do heavy computations, it can tell
    us to back off from doing more updates by faking a big one itself. */
//sh void sys_pretendguibytes(int n)
//sh {
//sh     sys_bytessincelastping += n;
//sh }

//sh void sys_queuegui(void *client, t_glist *glist, t_guicallbackfn f)
//sh {
//sh     t_guiqueue **gqnextptr, *gq;
//sh     if (!sys_guiqueuehead)
//sh         gqnextptr = &sys_guiqueuehead;
 //sh    else
 //sh    {
//sh         for (gq = sys_guiqueuehead; gq->gq_next; gq = gq->gq_next)
 //sh            if (gq->gq_client == client)
//sh                 return;
//sh         gqnextptr = &gq->gq_next;
//sh     }
//sh     gq = t_getbytes(sizeof(*gq));
//sh     gq->gq_next = 0;
//sh     gq->gq_client = client;
 //sh    gq->gq_glist = glist;
//sh     gq->gq_fn = f;
//sh     gq->gq_next = 0;
//sh     *gqnextptr = gq;
//sh }

//sh void sys_unqueuegui(void *client)
//sh {
//sh     t_guiqueue *gq, *gq2;
//sh     if (!sys_guiqueuehead)
//sh        return;
//sh     if (sys_guiqueuehead->gq_client == client)
//sh     {
//sh        t_freebytes(sys_guiqueuehead, sizeof(*sys_guiqueuehead));
//sh        sys_guiqueuehead = 0;
 //sh    }
//sh     else for (gq = sys_guiqueuehead; gq2 = gq->gq_next; gq = gq2)
//sh        if (gq2->gq_client == client)
 //sh    {
//sh        gq->gq_next = gq2->gq_next;
//sh        t_freebytes(gq2, sizeof(*gq2));
//sh         break;
//sh     }
//sh }

//sh int sys_pollgui(void)
//sh {
//sh     return (sys_domicrosleep(0, 1) || sys_poll_togui());
//sh }



/* --------------------- starting up the GUI connection ------------- */

//sh static int sys_watchfd;


//sh #define FIRSTPORTNUM 5400

//sh static int defaultfontshit[] = { 8, 5, 9, 10, 6, 10, 12, 7, 13, 14, 9, 17, 16, 10, 19, 24, 15, 28, 24, 15, 28};

//=========================================================== 
//  sys_startgui 
//=========================================================== 
//sh int sys_startgui(const char *guidir)
//sh {
 //sh    pid_t childpid;
//sh     char cmdbuf[4*MAXPDSTRING];
//sh     struct sockaddr_in server;
    //sh int msgsock;
    //sh char buf[15];
 //sh    int len = sizeof(server);
	
//sh 	printf("s_inter.c.c: sys_startgui len of server is %i\n", len);

//sh     int ntry = 0, portno = FIRSTPORTNUM;
//sh     int xsock = -1;


    //sh int stdinpipe[2];

    /* create an empty FD poll list */
//sh     sys_fdpoll = (t_fdpoll *)t_getbytes(0);
//sh     sys_nfdpoll = 0;
//sh     inbinbuf = binbuf_new();


//sh     signal(SIGHUP, sys_huphandler);
 //sh    signal(SIGINT, sys_exithandler);
//sh     signal(SIGQUIT, sys_exithandler);
//sh     signal(SIGILL, sys_exithandler);
//sh     signal(SIGIOT, sys_exithandler);
//sh     signal(SIGFPE, SIG_IGN);
    /* signal(SIGILL, sys_exithandler);
    signal(SIGBUS, sys_exithandler);
    signal(SIGSEGV, sys_exithandler); */
//sh    signal(SIGPIPE, SIG_IGN);
 //sh    signal(SIGALRM, SIG_IGN);
//sh #if 0  /* GG says: don't use that */
//sh     signal(SIGSTKFLT, sys_exithandler);
//sh #endif

//sh     if (sys_nogui)
//sh     {
//sh 		printf("s_inter.c: sys_nogui \n");

            /* fake the GUI's message giving cwd and font sizes; then
            skip starting the GUI up. */
  //sh      t_atom zz[19];
//sh        int i;


//sh         if (!getcwd(cmdbuf, MAXPDSTRING))
//sh             strcpy(cmdbuf, ".");
        
//sh         SETSYMBOL(zz, gensym(cmdbuf));
//sh         for (i = 1; i < 22; i++)
//sh             SETFLOAT(zz + i, defaultfontshit[i-1]);
//sh         SETFLOAT(zz+22,0);
//sh         glob_initfromgui(0, 0, 23, zz);
//sh     } else if (sys_guisetportnumber)  /* GUI exists and sent us a port number */
//sh     {
//sh 		printf("s_inter.c: GUI exists and sent us a port number \n");

 //sh        struct sockaddr_in server;
 //sh        struct hostent *hp;
        /* create a socket */
 //sh        sys_guisock = socket(AF_INET, SOCK_STREAM, 0);
 //sh        if (sys_guisock < 0)
 //sh            sys_sockerror("socket");

        /* connect socket using hostname provided in command line */
 //sh        server.sin_family = AF_INET;

//sh         hp = gethostbyname(LOCALHOST);

//sh         if (hp == 0)
//sh         {
//sh             fprintf(stderr, "localhost not found (inet protocol not installed?)\n");
//sh             exit(1);
  //sh       }
 //sh        memcpy((char *)&server.sin_addr, (char *)hp->h_addr, hp->h_length);

        /* assign client port number */
 //sh        server.sin_port = htons((unsigned short)sys_guisetportnumber);

		/* try to connect */
 //sh        if (connect(sys_guisock, (struct sockaddr *) &server, sizeof (server)) < 0)
//sh         {
 //sh            sys_sockerror("connecting stream socket");
//sh             exit(1);
//sh         }
//sh     } else    /* default behavior: start up the GUI ourselves. */
//sh     {
//sh 		printf("s_inter.c: starting gui...\n");
 //sh        int intarg;
		
        /* create a socket */
 //sh        xsock = socket(AF_INET, SOCK_STREAM, 0);
 //sh        if (xsock < 0) 
//sh 		{
//sh 			printf("s_inter.c: socket \n");
//sh 			sys_sockerror("socket");
//sh 		}

//sh         intarg = 0;
//sh        if (setsockopt(xsock, SOL_SOCKET, SO_SNDBUF,  &intarg, sizeof(intarg)) < 0)
//sh 		{
//sh 			printf("s_inter.c: setsockopt (SO_RCVBUF) failed \n");
//sh 			post("setsockopt (SO_RCVBUF) failed\n");
//sh 		}
//sh         intarg = 0;
 //sh        if (setsockopt(xsock, SOL_SOCKET, SO_RCVBUF,  &intarg, sizeof(intarg)) < 0)
//sh 		{
//sh 			printf("s_inter.c: setsockopt (SO_RCVBUF) failed \n");
//sh 			post("setsockopt (SO_RCVBUF) failed\n");
//sh 		}

 //sh        intarg = 1;
//sh         if (setsockopt(xsock, IPPROTO_TCP, TCP_NODELAY, &intarg, sizeof(intarg)) < 0)
//sh 		{
 //sh           post("setsockopt (TCP_NODELAY) failed\n");
//sh 			printf("s_inter.c: setsockopt (TCP_NODELAY) failed \n");
//sh         }
//sh         server.sin_family = AF_INET;
 //sh        server.sin_addr.s_addr = INADDR_ANY;

        /* assign server port number */
  //sh       server.sin_port =  htons((unsigned short)portno);

        /* name the socket */
 //sh        while (bind(xsock, (struct sockaddr *)&server, sizeof(server)) < 0)
 //sh        {
 //sh           int err = errno;

 //sh            if ((ntry++ > 20) || (err != EADDRINUSE))
 //sh            {
 //sh               perror("bind");
  //sh               fprintf(stderr, "Pd needs your machine to be configured with\n");
 //sh                fprintf(stderr,  "'networking' turned on (see Pd's html doc for details.)\n");
//sh                 exit(1);
//sh             }
//sh             portno++;
//sh             server.sin_port = htons((unsigned short)(portno));
//sh         }

 //sh        if (sys_verbose) 
//sh 			fprintf(stderr, "port %d\n", portno);

 //sh        childpid = fork();
//sh        if (childpid < 0)
 //sh        {
//sh             if (errno) 
//sh 				perror("sys_startgui");
//sh             else 
//sh 				fprintf(stderr, "sys_startgui failed\n");
//sh             return (1);
//sh         }
//sh         else if (!childpid)                     /* we're the child */
//sh         {
//sh             seteuid(getuid());          /* lose setuid priveliges */

 //sh            if (!sys_guicmd)
//sh            {
//sh 			printf("\ns_inter.c: boooooo!");

  //sh               char *homedir = getenv("HOME"), filename[250];
 //sh                struct stat statbuf;
//sh 				/* first look for Wish bundled with and renamed "Pd" */
 //sh                sprintf(filename, "%s/../../MacOS/Pd", guidir);
//sh                 if (stat(filename, &statbuf) >= 0)
//sh                     goto foundit;
//sh                 if (!homedir || strlen(homedir) > 150)
//sh                     goto nohomedir;
//sh                     /* Look for Wish in user's Applications.  Might or might
 //sh                    not be names "Wish Shell", and might or might not be
 //sh                    in "Utilities" subdir. */
 //sh                sprintf(filename, "%s/Applications/Utilities/Wish shell.app/Contents/MacOS/Wish Shell", homedir);
 //sh                if (stat(filename, &statbuf) >= 0)
//sh                     goto foundit;
//sh                 sprintf(filename,  "%s/Applications/Utilities/Wish.app/Contents/MacOS/Wish", homedir);
 //sh                if (stat(filename, &statbuf) >= 0)
 //sh                    goto foundit;
 //sh                sprintf(filename, "%s/Applications/Wish shell.app/Contents/MacOS/Wish Shell", homedir);
//sh                 if (stat(filename, &statbuf) >= 0)
//sh                     goto foundit;
//sh                 sprintf(filename, "%s/Applications/Wish.app/Contents/MacOS/Wish",  homedir);
//sh                 if (stat(filename, &statbuf) >= 0)
//sh                     goto foundit;
//sh             nohomedir:
 //sh                    /* Perform the same search among system applications. */
//sh                 strcpy(filename, "/Applications/Utilities/Wish Shell.app/Contents/MacOS/Wish Shell");
//sh                 if (stat(filename, &statbuf) >= 0)
//sh                     goto foundit;
//sh                 strcpy(filename, "/Applications/Utilities/Wish.app/Contents/MacOS/Wish");
//sh                 if (stat(filename, &statbuf) >= 0)
//sh                     goto foundit;
 //sh                strcpy(filename, "/Applications/Wish Shell.app/Contents/MacOS/Wish Shell");
 //sh                if (stat(filename, &statbuf) >= 0)
 //sh                    goto foundit;
//sh                strcpy(filename,  "/Applications/Wish.app/Contents/MacOS/Wish");
//sh             foundit:
//sh 				printf("s_inter.c: found wish..%s\n guiDir is.. %s\n",filename , guidir);
//sh                 sprintf(cmdbuf, "\"%s\" %s/pd.tk %d\n", filename, guidir, portno);
 //sh                sys_guicmd = cmdbuf;
//sh             }
//sh             if (sys_verbose) 
//sh 				fprintf(stderr, "%s", sys_guicmd);
//sh 			printf("\ns_inter.c: gui is.. %s\n",sys_guicmd);
//sh             execl("/bin/sh", "sh", "-c", sys_guicmd, (char*)0);
//sh             perror("pd: exec");
//sh 			printf("\ns_inter.c: hereherehereherehere abnout to exit");
//sh             _exit(1);
//sh         }

//sh     }

//sh     if (sys_hipriority)
//sh     {
 //sh        struct sched_param param;
 //sh        int policy = SCHED_RR;
  //sh       int err;
  //sh       param.sched_priority = 80; /* adjust 0 : 100 */

 //sh        err = pthread_setschedparam(pthread_self(), policy, &param);
 //sh        if (err){
 //sh            post("warning: high priority scheduling failed\n");
//sh 			printf("\ns_inter.c: warning: high priority scheduling failed\n");
//sh 
//sh 		}
//sh     }

//sh     if (!sys_nogui && !sys_guisetportnumber)
//sh     {
     //   if (sys_verbose)
//sh             fprintf(stderr, "s_inter.c: Waiting for connection request... \n");
//sh         if (listen(xsock, 5) < 0) 
//sh 		{
//sh 			printf("s_inter.c: listen\n");
//sh 			sys_sockerror("listen");
//sh 		}
//sh 		printf( "s_inter.c: xsock %i\n", xsock);
//sh 		printf( "s_inter.c: server %i\n", server);
//sh 		printf( "s_inter.c: len %i\n", len);
//sh        sys_guisock = accept(xsock, (struct sockaddr *) &server, (socklen_t *)&len);
//sh 		printf("s_inter.c: ACCEPTED!!! \n");
		
//sh #ifdef OOPS
//sh 	close(xsock);
//sh #endif
//sh         if (sys_guisock < 0) 
//sh 			sys_sockerror("accept");
 //sh        if (sys_verbose)
//sh             fprintf(stderr, "... connected\n");
//sh     }

//sh     if (!sys_nogui)
//sh     {
//sh       char buf[256], buf2[256];
//sh          sys_socketreceiver = socketreceiver_new(0, 0, 0, 0);
//sh          sys_addpollfn(sys_guisock, (t_fdpollfn)socketreceiver_read, sys_socketreceiver);

		/* here is where we start the pinging. */
 //sh         sys_get_audio_apis(buf);
 //sh         sys_get_midi_apis(buf2);

//sh 		printf("s_inter.c: about to call gui start up in pd.tk \n");
//sh          sys_vgui("pdtk_pd_startup {%s} %s %s {%s}\n", pd_version, buf, buf2,  sys_font); 
//sh     }
//sh 	printf("\ns_inter.c: about to return\n");

//sh     return (0);

//sh }

//sh extern void sys_exit(void);

/* This is called when something bad has happened, like a segfault.
Call glob_quit() below to exit cleanly.
LATER try to save dirty documents even in the bad case. */
//sh void sys_bail(int n)
//sh {
//sh     static int reentered = 0;
//sh     if (!reentered)
//sh     {
//sh         reentered = 1;

 //sh        fprintf(stderr, "closing audio...\n");
//sh         sys_close_audio();
//sh         fprintf(stderr, "closing MIDI...\n");
//sh         sys_close_midi();
//sh         fprintf(stderr, "... done.\n");
//sh 
//sh        exit(n);
//sh    }
//sh     else _exit(1);
//sh }

//sh void glob_quit(void *dummy)
//sh {
//sh     sys_vgui("exit\n");
//sh     if (!sys_nogui)
//sh     {
//sh         close(sys_guisock);
//sh         sys_rmpollfn(sys_guisock);
//sh     }
//sh     sys_bail(0); 
//sh }

