#import "GHRepository.h"
#import "GHResource.h"
#import "iOctocat.h"
#import "GHIssues.h"
#import "GHForks.h"
#import "GHEvents.h"
#import "GHReadme.h"
#import "GHBranches.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHRepository

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	self = [super init];
	if (self) {
		[self setOwner:theOwner andName:theName];
	}
	return self;
}

- (BOOL)isEqual:(id)anObject {
	return [self hash] == [anObject hash];
}

- (NSUInteger)hash {
	return [self.repoId hash];
}

- (NSString *)repoId {
    return [NSString stringWithFormat:@"%@/%@", self.owner, self.name];
}

- (NSString *)repoIdAndStatus {
    return [NSString stringWithFormat:@"%@/%@/%@", self.owner, self.isPrivate ? @"private" : @"public", self.name];
}

- (NSString *)resourcePath {
	// Dynamic path, because it depends on the owner and
	// name which are not always available in advance
	return [NSString stringWithFormat:kRepoFormat, self.owner, self.name];
}

- (void)setOwner:(NSString *)theOwner andName:(NSString *)theName {
	self.owner = theOwner;
	self.name = theName;
    self.forks = [[GHForks alloc] initWithRepository:self];
    self.readme = [[GHReadme alloc] initWithRepository:self];
    self.events = [[GHEvents alloc] initWithRepository:self];
    self.branches = [[GHBranches alloc] initWithRepository:self];
	self.openIssues = [[GHIssues alloc] initWithRepository:self andState:kIssueStateOpen];
	self.closedIssues = [[GHIssues alloc] initWithRepository:self andState:kIssueStateClosed];
}

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:self.owner];
}

- (int)compareByRepoId:(GHRepository *)theOtherRepository {
    return [self.repoId localizedCaseInsensitiveCompare:theOtherRepository.repoId];
}

- (int)compareByRepoIdAndStatus:(GHRepository *)theOtherRepository {
    return [self.repoIdAndStatus localizedCaseInsensitiveCompare:theOtherRepository.repoIdAndStatus];
}

- (int)compareByName:(GHRepository *)theOtherRepository {
    return [self.name localizedCaseInsensitiveCompare:theOtherRepository.name];
}

#pragma mark Loading

- (void)setValues:(id)theDict {
    NSDictionary *resource = [theDict objectForKey:@"repository"] ? [theDict objectForKey:@"repository"] : theDict;

    self.htmlURL = [NSURL URLWithString:[resource objectForKey:@"html_url"]];
    self.homepageURL = [NSURL smartURLFromString:[resource objectForKey:@"homepage"]];
    self.descriptionText = [theDict valueForKeyPath:@"description" defaultsTo:@""];
    self.mainBranch = [theDict valueForKeyPath:@"master_branch" defaultsTo:@"master"];
    self.isFork = [[resource objectForKey:@"fork"] boolValue];
    self.isPrivate = [[resource objectForKey:@"private"] boolValue];
    self.hasIssues = [[resource objectForKey:@"has_issues"] boolValue];
    self.hasWiki = [[resource objectForKey:@"has_wiki"] boolValue];
    self.hasDownloads = [[resource objectForKey:@"has_downloads"] boolValue];
    self.forkCount = [[resource objectForKey:@"forks"] integerValue];
    self.watcherCount = [[resource objectForKey:@"watchers"] integerValue];
	self.pushedAtDate = [resource objectForKey:@"pushed_at"];
}

@end