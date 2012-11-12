#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHComment.h"


@class GHUser;

@interface GHIssueComment : GHComment {
	id parent; // a GHIssue or GHPullRequest instance
}

@property(nonatomic,retain)id parent;

+ (id)commentWithParent:(id)theParent andDictionary:(NSDictionary *)theDict;
+ (id)commentWithParent:(id)theParent;
- (id)initWithParent:(id)theParent andDictionary:(NSDictionary *)theDict;
- (id)initWithParent:(id)theParent;

@end
