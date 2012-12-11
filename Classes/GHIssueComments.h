#import <Foundation/Foundation.h>
#import "GHCollection.h"


@interface GHIssueComments : GHCollection
@property(nonatomic,strong)id parent; // a GHIssue or GHPullRequest instance

- (id)initWithParent:(id)theParent;
@end