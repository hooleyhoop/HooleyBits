@interface QCInspector : NSObject
{
    IBOutlet NSView *view;
    QCPatch *_patch;
    void *_unused2[4];
}

+ (id)viewNibName;
+ (id)viewTitle;
- (id)init;
- (void)didLoadNib;
- (id)patch;
- (void)setupViewForPatch:(id)fp8;
- (void)resetView;
- (id)view;

@end
