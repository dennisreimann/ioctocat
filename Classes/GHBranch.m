#import "GHBranch.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


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
	NSString *sha = [dict safeStringForKey:@"sha"];
	NSString *authorLogin = [dict safeStringForKeyPath:@"author.login"];
	if ([authorLogin isEmpty]) authorLogin = [dict safeStringForKeyPath:@"user.login"];
	self.commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
	self.authorLogin = authorLogin;
}

@end