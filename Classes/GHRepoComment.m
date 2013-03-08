#import "GHRepoComment.h"
#import "GHRepository.h"
#import "GHUser.h"
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
    self.user = [[iOctocat sharedInstance] userWithLogin:[dict safeStringForKeyPath:@"user.login"]];
    if (!self.user.gravatarURL) {
        self.user.gravatarURL = [dict safeURLForKeyPath:@"user.avatar_url"];
    }
}

- (NSString *)savePath {
	return [NSString stringWithFormat:kRepoCommentsFormat, self.repository.owner, self.repository.name, self.commitID];
}

@end