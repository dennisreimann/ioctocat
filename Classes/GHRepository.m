#import "GHRepository.h"
#import "GHResource.h"
#import "iOctocat.h"
#import "GHIssues.h"
#import "GHPullRequests.h"
#import "GHForks.h"
#import "GHEvents.h"
#import "GHReadme.h"
#import "GHBranches.h"
#import "NSDictionary+Extensions.h"


@implementation GHRepository

- (id)initWithOwner:(NSString *)owner andName:(NSString *)name {
	self = [super init];
	if (self) {
		[self setOwner:owner andName:name];
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

- (void)setOwner:(NSString *)owner andName:(NSString *)name {
	self.owner = owner;
	self.name = name;
}

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:self.owner];
}

- (int)compareByRepoId:(GHRepository *)otherRepo {
    return [self.repoId localizedCaseInsensitiveCompare:otherRepo.repoId];
}

- (int)compareByRepoIdAndStatus:(GHRepository *)otherRepo {
    return [self.repoIdAndStatus localizedCaseInsensitiveCompare:otherRepo.repoIdAndStatus];
}

- (int)compareByName:(GHRepository *)otherRepo {
    return [self.name localizedCaseInsensitiveCompare:otherRepo.name];
}

#pragma mark Associations

- (GHForks *)forks {
	if (!_forks) {
		_forks = [[GHForks alloc] initWithRepository:self];
	}
	return _forks;
}

- (GHReadme *)readme {
	if (!_readme) {
		_readme = [[GHReadme alloc] initWithRepository:self];
	}
	return _readme;
}

- (GHEvents *)events {
	if (!_events) {
		_events = [[GHEvents alloc] initWithRepository:self];
	}
	return _events;
}

- (GHBranches *)branches {
	if (!_branches) {
		_branches = [[GHBranches alloc] initWithRepository:self];
	}
	return _branches;
}

- (GHIssues *)openIssues {
	if (!_openIssues) {
		_openIssues = [[GHIssues alloc] initWithRepository:self andState:kIssueStateOpen];
	}
	return _openIssues;
}

- (GHIssues *)closedIssues {
	if (!_closedIssues) {
		_closedIssues = [[GHIssues alloc] initWithRepository:self andState:kIssueStateClosed];
	}
	return _closedIssues;
}

- (GHPullRequests *)openPullRequests {
	if (!_openPullRequests) {
		_openPullRequests = [[GHPullRequests alloc] initWithRepository:self andState:kIssueStateOpen];
	}
	return _openPullRequests;
}

- (GHPullRequests *)closedPullRequests {
	if (!_closedPullRequests) {
		_closedPullRequests = [[GHPullRequests alloc] initWithRepository:self andState:kIssueStateClosed];
	}
	return _closedPullRequests;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSDictionary *repoDict = [dict safeDictForKey:@"repository"];
    NSDictionary *resource = repoDict ? repoDict : dict;
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
    self.mainBranch = [resource valueForKeyPath:@"master_branch" defaultsTo:nil] ?
        [resource valueForKeyPath:@"master_branch" defaultsTo:@"master"] :
        [resource valueForKeyPath:@"default_branch" defaultsTo:@"master"];
}

@end