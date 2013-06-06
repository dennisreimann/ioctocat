#import "IOCCollectionController.h"

@class GHRepository, GHUser;

@interface IOCIssuesController : IOCCollectionController
- (id)initWithRepository:(GHRepository *)repo;
- (id)initWithUser:(GHUser *)user;
- (void)reloadIssues;
@end