#import "GHRepoComment.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"


@interface GHRepoComment ()
@property(nonatomic,weak)GHRepository *repository;
@end

@implementation GHRepoComment

- (id)initWithRepo:(GHRepository *)repo andDictionary:(NSDictionary *)dict {
	self = [self initWithRepo:repo];
	if (self) {
		[self setUserWithValues:[dict safeDictForKey:@"user"]];
		self.commitID = [dict safeStringForKey:@"commit_id"];
		self.body = [dict safeStringForKey:@"body"];
		self.path = [dict safeStringForKey:@"path"];
		self.line = [dict safeIntegerForKey:@"line"];
		self.position = [dict safeIntegerForKey:@"position"];
		self.created = [iOctocat parseDate:[dict safeStringForKey:@"created_at"]];
		self.updated = [iOctocat parseDate:[dict safeStringForKey:@"updated_at"]];
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