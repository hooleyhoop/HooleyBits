#import "sw_breakpoint.h"

#include <string.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#include <inttypes.h>
#include <signal.h>
#include <mach/mach_types.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/ucontext.h>
#import <mach/mach_error.h>

// compile:
// monoco% gcc -m32 -o break2 break2.m 

uint8_t orig_dummy_byte = 0;

#define MACH_CHECK_ERROR(name,ret) \
if (ret != KERN_SUCCESS) { \
mach_error(#name, ret); \
exit(1); \
}

void clear_breakpoint(void* pc)
{
    *((uint8_t*)pc) = orig_dummy_byte;
}

void set_sw_breakpoint(void* addr, thread_act_t thread)
{
    // mprotect requires page-aligned addresses, so round it
    //
    uint32_t pagesize = getpagesize();
    uint32_t addrToProtect = (uint32_t)addr;
    addrToProtect -= (addrToProtect % pagesize);

    // mprotect the page to give ourselves write-access
    // since we'll be writing
    //
    int rc = mprotect((void*)addrToProtect, 1, PROT_READ | PROT_WRITE | PROT_EXEC);
    if(rc != 0)
    {
        perror("mprotect: ");
        return;
    }

    // Update the first byte of the target to be 0xCC
    // which is the opcode for INT3 which will generate
    // SIGTRAP when executed by the CPU
    //
    uint8_t* fptr = (uint8_t*)addr;
    orig_dummy_byte = *fptr;
    *fptr = (uint8_t)0xCC; // INT 3
}

void sw_breakpoint_handler(int signum, siginfo_t* signal_info, void* context)
{
    printf("***** HIT BREAKPOINT *****\n");

    // Dig through the context pointer info to get the
    // instruction pointer. It's going to point to the 
    // address AFTER where we wrote 0xCC. So back it up
    // one and store that to the context
    //
    ucontext_t* ucontext = (ucontext_t*)context;
    mcontext_t mcontext = ucontext->uc_mcontext;
    uint32_t pc = (uint32_t)mcontext->__ss.__eip;
    --pc;
    mcontext->__ss.__eip = pc;

    // Now replace the byte we overwrote in set_breakpoint
    //
    clear_breakpoint((void*)pc);
}

uint32_t sw_dummy(char c)
{
    printf("in dummy. c is %c [0x%x]\n", c, c);
    return 0xBABE;
}

void* sw_trampoline(void* arg)
{
    uint32_t* start = (uint32_t*)arg;
    
    // Wait until we're supposed to start
    while(*start != 1)
    {}
    
    printf("About to call dummy()\n");
    uint32_t result = sw_dummy('N');
    printf("Dummy complete: 0x%08x\n", result);
    return (void*)result;
}


int main2(int argc, char** argv)
{
    // Create a new thread
    //
    pthread_t thread;
    uint32_t start = 0;
    int rc = pthread_create(&thread, NULL, &sw_trampoline, &start);
    if(rc != 0)
    {
        perror("pthread_create: ");
        return(1);
    }
    
    thread_t mythread = pthread_mach_thread_np(thread);

    // Set our breakpoint on dummy
    //
    set_sw_breakpoint(&sw_dummy, mythread);
    
    // Setup a breakpoint handler
    {
        struct sigaction action;
        memset(&action, 0, sizeof(action));
        sigemptyset(&action.sa_mask);
        action.sa_flags |= SA_SIGINFO;
        action.sa_sigaction = &sw_breakpoint_handler;
        sigaction(SIGTRAP, &action, NULL);        
    }
    
    // Start the thread running.
    //
    start = 1;
    
    // Wait until it's done and cleanup.
    //
    void* result = 0;
    pthread_join(thread, &result);
    printf("All threads complete: 0x%08x\n", (uint32_t)result);
    return(0);
}