#import "GHBranch.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


@interface GHBranch ()
@property(nonatomic,strong)NSString *authorLogin;
@end


@implementation GHBranch

- (id)initWithRepository:(GHRepository *)repo andName:(NSString *)name {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.name = name;
	}
	return self;
}

- (GHUser *)author {
	return [[iOctocat sharedInstance] userWithLogin:self.authorLogin];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	// handle different formats in repo and pull request api
	NSString *sha = dict[@"sha"];
	NSString *authorLogin = dict[@"author.login"] ? dict[@"author.login"] : dict[@"user.login"];
	if (sha) self.commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
	if (authorLogin) self.authorLogin = authorLogin;
}

@end