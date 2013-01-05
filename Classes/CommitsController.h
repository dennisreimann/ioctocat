#import <Foundation/Foundation.h>


@class GHCommits;

@interface CommitsController : UITableViewController
- (id)initWithCommits:(GHCommits *)commits;
@end