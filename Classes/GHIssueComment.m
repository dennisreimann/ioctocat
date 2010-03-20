#import "GHIssueComment.h"
#import "iOctocat.h"


@implementation GHIssueComment

@synthesize issue;
@synthesize user;
@synthesize commentID;
@synthesize body;
@synthesize created;
@synthesize updated;

- (id)initWithIssue:(GHIssue *)theIssue andDictionary:(NSDictionary *)theDict {
	[super init];
	self.issue = theIssue;
	self.user = [[iOctocat sharedInstance] userWithLogin:[theDict valueForKey:@"user"]];
	self.body = [theDict valueForKey:@"body"];
	self.created = [[iOctocat sharedInstance] parseDate:[theDict valueForKey:@"created_at"]];
	self.updated = [[iOctocat sharedInstance] parseDate:[theDict valueForKey:@"updated_at"]];
	return self;
}

- (void)dealloc {
	[issue release], issue = nil;
	[user release], user = nil;
	[body release], body = nil;
	[created release], created = nil;
	[updated release], updated = nil;
	
	[super dealloc];
}

@end
