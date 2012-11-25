#import <Foundation/Foundation.h>


@interface CommitsController : UITableViewController
+ (id)controllerWithCommits:(NSArray *)theCommits;
- (id)initWithCommits:(NSArray *)theCommits;
@end