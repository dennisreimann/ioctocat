#import "IOCCollectionController.h"
#import "IOCResourceEditingDelegate.h"

@class GHIssue;

@interface IOCAssigneeSelectionController : IOCCollectionController
@property(nonatomic,weak)id<IOCResourceEditingDelegate> delegate;

- (id)initWithIssue:(GHIssue *)issue;
@end