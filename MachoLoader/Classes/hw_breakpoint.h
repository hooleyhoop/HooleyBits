#import <mach/thread_act.h>

void clear_hw_breakpoint( thread_act_t thread );
void set_hw_breakpoint( void *addr, thread_act_t thread );
