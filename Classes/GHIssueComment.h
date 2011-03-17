#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHIssue, GHUser;

@interface GHIssueComment : GHResource <GHResourceImplementation> {
	GHIssue *issue;
	GHUser *user;
	NSUInteger commentID;
	NSString *body;
	NSDate *created;
	NSDate *updated;
}

@property(nonatomic,retain)GHIssue *issue;
@property(nonatomic,retain)GHUser *user;
@property(nonatomic,assign)NSUInteger commentID;
@property(nonatomic,retain)NSString *body;
@property(nonatomic,retain)NSDate *created;
@property(nonatomic,retain)NSDate *updated;

- (id)initWithIssue:(GHIssue *)theIssue andDictionary:(NSDictionary *)theDict;
- (id)initWithIssue:(GHIssue *)theIssue;
- (void)saveData;

@end
