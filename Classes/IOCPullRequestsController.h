#import "IOCCollectionController.h"

@class GHRepository;

@interface IOCPullRequestsController : IOCCollectionController
- (id)initWithRepository:(GHRepository *)repo;
- (void)reloadPullRequests;
@end