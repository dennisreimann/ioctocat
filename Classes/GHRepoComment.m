#import "GHRepoComment.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


@implementation GHRepoComment

@synthesize repository;
@synthesize sha;

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha andDictionary:(NSDictionary *)theDict {
	[self initWithRepo:theRepo andSha:theSha];	
	
	// Dates
	NSString *createdAt = [theDict valueForKey:@"created_at"];
	NSString *updatedAt = [theDict valueForKey:@"updated_at"];
	
	self.body = [theDict valueForKey:@"body"];
	self.user = [[iOctocat sharedInstance] userWithLogin:[theDict valueForKeyPath:@"user.login"]];
	self.created = [iOctocat parseDate:createdAt];
	self.updated = [iOctocat parseDate:updatedAt];
	
	return self;
}

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	[super init];
	self.repository = theRepo;
	self.sha = theSha;
	return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[sha release], sha = nil;
	
	[super dealloc];
}

#pragma mark Saving

- (void)saveData {
	NSDictionary *values = [NSDictionary dictionaryWithObject:body forKey:@"body"];
	NSURL *saveURL = [NSURL URLWithFormat:kRepoCommentsFormat, repository.owner, repository.name, sha];
	[self saveValues:values withURL:saveURL andMethod:@"POST"];
}

@end
