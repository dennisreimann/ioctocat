#import "GHRepoComment.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"


@interface GHRepoComment ()
@property(nonatomic,weak)GHRepository *repository;
@end

@implementation GHRepoComment

- (id)initWithRepo:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
	}
	return self;
}

- (void)setValues:(id)dict {
	[super setValues:dict];
	self.commitID = [dict safeStringForKey:@"commit_id"];
	self.path = [dict safeStringForKey:@"path"];
	self.line = [dict safeIntegerForKey:@"line"];
	self.position = [dict safeIntegerForKey:@"position"];
}

#pragma mark Saving

- (void)saveData {
	NSDictionary *values = @{@"body": self.body};
	NSString *savePath = [NSString stringWithFormat:kRepoCommentsFormat, self.repository.owner, self.repository.name, self.commitID];
	[self saveValues:values withPath:savePath andMethod:kRequestMethodPost useResult:^(id response) {
		[self setValues:response];
	}];
}

@end