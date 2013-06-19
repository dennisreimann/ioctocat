#import "IOCCollectionController.h"
#import "IOCResourceEditingDelegate.h"


@class GHIssue;

@interface IOCMilestoneSelectionController : IOCCollectionController
@property(nonatomic,weak)id<IOCResourceEditingDelegate> delegate;

- (id)initWithIssue:(GHIssue *)issue;
@end