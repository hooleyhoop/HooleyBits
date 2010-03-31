#import "QCClasses.h"

@interface BBMagicContainer : QCPatch
{

    QCNumberPort *inputTickle;
}

// QCPatch
+ (int)executionMode;
+ (BOOL)allowsSubpatches;
- (id)setup:(id)p;
- (BOOL)execute:(QCOpenGLContext*)qcglctx time:(double)exec_time arguments:(id)arg;
- (void)cleanup:(id)p;

// private
// - ...

@end