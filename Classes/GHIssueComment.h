#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHComment.h"


@class GHIssue, GHUser;

@interface GHIssueComment : GHComment {
	GHIssue *issue;
}

@property(nonatomic,retain)GHIssue *issue;

+ (id)commentWithIssue:(GHIssue *)theIssue andDictionary:(NSDictionary *)theDict;
+ (id)commentWithIssue:(GHIssue *)theIssue;
- (id)initWithIssue:(GHIssue *)theIssue andDictionary:(NSDictionary *)theDict;
- (id)initWithIssue:(GHIssue *)theIssue;

@end
