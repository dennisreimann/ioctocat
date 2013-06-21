#import "GHBranch.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


@implementation GHBranch

- (id)initWithRepository:(GHRepository *)repo andName:(NSString *)name {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.name = name;
	}
	return self;
}

- (NSURL *)htmlURL {
    if (!_htmlURL) {
        self.htmlURL = [NSURL ioc_URLWithFormat:@"/%@/%@/tree/%@", self.repository.owner, self.repository.name, self.name];
    }
    return _htmlURL;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	// handle different formats in repo and pull request api
	NSString *sha = [dict ioc_stringForKey:@"sha"];
	NSString *authorLogin = [dict ioc_stringForKeyPath:@"author.login"];
	if ([authorLogin ioc_isEmpty]) authorLogin = [dict ioc_stringForKeyPath:@"user.login"];
	self.commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
	self.author = [iOctocat.sharedInstance userWithLogin:authorLogin];
}

@end