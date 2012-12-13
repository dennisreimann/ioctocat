#import "GHRepository.h"
#import "GHResource.h"
#import "iOctocat.h"
#import "GHIssues.h"
#import "GHPullRequests.h"
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
	self.openPullRequests = [[GHPullRequests alloc] initWithRepository:self andState:kIssueStateOpen];
	self.closedPullRequests = [[GHPullRequests alloc] initWithRepository:self andState:kIssueStateClosed];
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

- (void)setValues:(id)dict {
    NSDictionary *resource = dict[@"repository"] ? dict[@"repository"] : dict;
    self.htmlURL = [resource safeURLForKey:@"html_url"];
    self.homepageURL = [resource safeURLForKey:@"homepage"];
    self.descriptionText = [resource safeStringForKey:@"description"];
    self.isFork = [resource safeBoolForKey:@"fork"];
    self.isPrivate = [resource safeBoolForKey:@"private"];
    self.hasIssues = [resource safeBoolForKey:@"has_issues"];
    self.hasWiki = [resource safeBoolForKey:@"has_wiki"];
    self.hasDownloads = [resource safeBoolForKey:@"has_downloads"];
    self.forkCount = [resource safeIntegerForKey:@"forks"];
    self.watcherCount = [resource safeIntegerForKey:@"watchers"];
    self.pushedAtDate = [resource safeDateForKey:@"pushed_at"];
    // TODO: Remove master_branch once the API change is done.
    self.mainBranch = [resource valueForKeyPath:@"master_branch"] ?
        [resource valueForKeyPath:@"master_branch" defaultsTo:@"master"] :
        [resource valueForKeyPath:@"default_branch" defaultsTo:@"master"];
}

@end