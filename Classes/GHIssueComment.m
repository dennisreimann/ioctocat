#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHPullRequest.h"
#import "GHRepository.h"
#import "iOctocat.h"


@implementation GHIssueComment

- (id)initWithParent:(id)theParent andDictionary:(NSDictionary *)theDict {
	self = [self initWithParent:theParent];

	NSString *createdAt = [theDict valueForKey:@"created_at"];
	NSString *updatedAt = [theDict valueForKey:@"updated_at"];
	NSDictionary *userDict = [theDict valueForKey:@"user"];
	[self setUserWithValues:userDict];
	self.body = [theDict valueForKey:@"body"];
	self.created = [iOctocat parseDate:createdAt];
	self.updated = [iOctocat parseDate:updatedAt];

	return self;
}

- (id)initWithParent:(id)theParent {
	self = [super init];
	self.parent = theParent;
	return self;
}

#pragma mark Saving

- (void)saveData {
	NSDictionary *values = [NSDictionary dictionaryWithObject:self.body forKey:@"body"];
	GHRepository *repo = [(GHIssue *)self.parent repository];
	NSUInteger num = [(GHIssue *)self.parent num];
	NSString *path = [NSString stringWithFormat:kIssueCommentsFormat, repo.owner, repo.name, num];
	[self saveValues:values withPath:path andMethod:@"POST" useResult:nil];
}

@end