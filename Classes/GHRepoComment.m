#import "GHRepoComment.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


@implementation GHRepoComment

@synthesize repository;
@synthesize commitID;
@synthesize path;
@synthesize position;
@synthesize line;

- (id)initWithRepo:(GHRepository *)theRepo andDictionary:(NSDictionary *)theDict {
	[self initWithRepo:theRepo];	
	
	NSString *createdAt = [theDict valueForKey:@"created_at"];
	NSString *updatedAt = [theDict valueForKey:@"updated_at"];
	self.user = [[iOctocat sharedInstance] userWithLogin:[theDict valueForKeyPath:@"user.login"]];
	self.created = [iOctocat parseDate:createdAt];
	self.updated = [iOctocat parseDate:updatedAt];
	self.body = [theDict valueForKey:@"body"];
	self.commitID = [theDict valueForKey:@"commit_id"];
	self.path = [theDict valueForKey:@"path"];
	self.position = (NSUInteger)[theDict valueForKey:@"position"];
	self.line = (NSUInteger)[theDict valueForKey:@"line"];
	
	return self;
}

- (id)initWithRepo:(GHRepository *)theRepo {
	[super init];
	self.repository = theRepo;
	return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[commitID release], commitID = nil;
	[path release], path = nil;
	[super dealloc];
}

#pragma mark Saving

- (void)saveData {
	NSDictionary *values = [NSDictionary dictionaryWithObject:body forKey:@"body"];
	NSString *savePath = [NSString stringWithFormat:kRepoCommentsFormat, repository.owner, repository.name, commitID];
	[self saveValues:values withPath:savePath andMethod:@"POST"];
}

@end
