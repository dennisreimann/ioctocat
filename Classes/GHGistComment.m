#import "GHGistComment.h"
#import "GHGist.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


@implementation GHGistComment

@synthesize gist;

- (id)initWithGist:(GHGist *)theGist andDictionary:(NSDictionary *)theDict {
	[self initWithGist:theGist];

	NSString *createdAt = [theDict valueForKey:@"created_at"];
	NSString *updatedAt = [theDict valueForKey:@"updated_at"];
	self.body = [theDict valueForKey:@"body"];
	self.user = [[iOctocat sharedInstance] userWithLogin:[theDict valueForKeyPath:@"user.login"]];
	self.created = [iOctocat parseDate:createdAt];
	self.updated = [iOctocat parseDate:updatedAt];

	return self;
}

- (id)initWithGist:(GHGist *)theGist {
	[super init];
	self.gist = theGist;
	return self;
}

- (void)dealloc {
	[gist release], gist = nil;
	[super dealloc];
}

#pragma mark Saving

- (void)saveData {
	NSDictionary *values = [NSDictionary dictionaryWithObject:body forKey:@"body"];
	NSString *path = [NSString stringWithFormat:kGistCommentsFormat, gist.gistId];
	[self saveValues:values withPath:path andMethod:@"POST"];
}

@end
