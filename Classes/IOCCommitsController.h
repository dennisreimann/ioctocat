#import <Foundation/Foundation.h>


@class GHCommits;

@interface IOCCommitsController : UITableViewController
- (id)initWithCommits:(GHCommits *)commits;
@end