#import "GHGistComment.h"
#import "GHGist.h"
#import "iOctocat.h"


@implementation GHGistComment

- (id)initWithGist:(GHGist *)theGist andDictionary:(NSDictionary *)theDict {
	self = [self initWithGist:theGist];
	if (self) {
		NSString *createdAt = [theDict valueForKey:@"created_at"];
		NSString *updatedAt = [theDict valueForKey:@"updated_at"];
		NSDictionary *userDict = [theDict valueForKey:@"user"];
		[self setUserWithValues:userDict];
		self.body = [theDict valueForKey:@"body"];
		self.created = [iOctocat parseDate:createdAt];
		self.updated = [iOctocat parseDate:updatedAt];
	}
	return self;
}

- (id)initWithGist:(GHGist *)theGist {
	self = [super init];
	if (self) {
		self.gist = theGist;
	}
	return self;
}

#pragma mark Saving

- (void)saveData {
	NSDictionary *values = @{@"body": self.body};
	NSString *path = [NSString stringWithFormat:kGistCommentsFormat, self.gist.gistId];
	[self saveValues:values withPath:path andMethod:kRequestMethodPost useResult:nil];
}

@end