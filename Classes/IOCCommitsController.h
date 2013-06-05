#import "IOCCollectionController.h"

@class GHCommits;

@interface IOCCommitsController : IOCCollectionController
- (id)initWithCommits:(GHCommits *)commits;
@end