

@protocol SHViewControllerProtocol <NSObject>

//- (int)refCount;
//- incrementCount;
//- decrementCount;
// - (void)setCentrePoint:(NSPoint) aNSPoint;


#pragma mark notification methods
- (void) willBeRemovedFromViewPort;
- (void) willBeAddedToViewPort;

#pragma mark action methods
- (void) syncWithNodeGraphModel;
- (void) enable;
- (void) disable;

#pragma mark accessor methods
 


@end
