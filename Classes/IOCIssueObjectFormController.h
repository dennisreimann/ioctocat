#import "IOCIssueManagementDelegate.h"


@interface IOCIssueObjectFormController : UIViewController
@property(nonatomic,weak)id<IOCIssueManagementDelegate> delegate;

- (id)initWithIssueObject:(id)object;
@end