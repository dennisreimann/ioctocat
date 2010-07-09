#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHIssue;

@interface GHIssueComments : GHResource {
	NSMutableArray *comments;
	GHIssue *issue;
}

@property(nonatomic,retain)NSMutableArray *comments;
@property(nonatomic,retain)GHIssue *issue;

+ (id)commentsWithIssue:(GHIssue *)theIssue;
- (id)initWithIssue:(GHIssue *)theIssue;

@end
