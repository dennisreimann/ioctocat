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
		[self setUserWithValues:[dict valueForKey:@"user" defaultsTo:nil]];
		self.body = dict[@"body"];
		self.path = dict[@"path"];
		self.line = [[dict valueForKey:@"line" defaultsTo:nil] integerValue];
		self.created = [iOctocat parseDate:dict[@"created_at"]];
		self.updated = [iOctocat parseDate:dict[@"updated_at"]];
		self.position = [[dict valueForKey:@"position" defaultsTo:nil] integerValue];
		self.commitID = dict[@"commit_id"];
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