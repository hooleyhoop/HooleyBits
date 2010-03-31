// (C) best before/Anatol Ulrich

#import "QCClasses.h"

@class BBRenderingDimensions;

@interface BBRenderingDimensions : QCPatch
{
    QCNumberPort *outputWidth;
    QCNumberPort *outputHeight;
    QCNumberPort *outputWidthPx;
    QCNumberPort *outputHeightPx;
    QCNumberPort *outputResolution;
    QCNumberPort *outputAspectRatio;
}



@end