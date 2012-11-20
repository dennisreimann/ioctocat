#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHIssueComments : GHResource {
	NSMutableArray *comments;
	id parent; // a GHIssue or GHPullRequest instance
}

@property(nonatomic,retain)NSMutableArray *comments;
@property(nonatomic,retain)id parent;

+ (id)commentsWithParent:(id)theParent;
- (id)initWithParent:(id)theParent;

@end