#import "GHRepoComment.h"
#import "GHRepository.h"
#import "iOctocat.h"


@implementation GHRepoComment

- (id)initWithRepo:(GHRepository *)theRepo andDictionary:(NSDictionary *)theDict {
	self = [self initWithRepo:theRepo];
	if (self) {
		NSString *createdAt = [theDict valueForKey:@"created_at"];
		NSString *updatedAt = [theDict valueForKey:@"updated_at"];
		NSDictionary *userDict = [theDict valueForKey:@"user"];
		[self setUserWithValues:userDict];
		self.created = [iOctocat parseDate:createdAt];
		self.updated = [iOctocat parseDate:updatedAt];
		self.body = [theDict valueForKey:@"body"];
		self.commitID = [theDict valueForKey:@"commit_id"];
		self.path = [theDict valueForKey:@"path"];
		self.position = (NSUInteger)[theDict valueForKey:@"position"];
		self.line = (NSUInteger)[theDict valueForKey:@"line"];
	}
	return self;
}

- (id)initWithRepo:(GHRepository *)theRepo {
	self = [super init];
	if (self) {
		self.repository = theRepo;
	}
	return self;
}

#pragma mark Saving

- (void)saveData {
	NSDictionary *values = @{@"body": self.body};
	NSString *savePath = [NSString stringWithFormat:kRepoCommentsFormat, self.repository.owner, self.repository.name, self.commitID];
	[self saveValues:values withPath:savePath andMethod:kRequestMethodPost useResult:nil];
}

@end