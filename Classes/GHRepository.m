#import "GHRepository.h"
#import "GHResource.h"
#import "iOctocat.h"
#import "GHIssues.h"
#import "GHPullRequests.h"
#import "GHTags.h"
#import "GHForks.h"
#import "GHUsers.h"
#import "GHEvents.h"
#import "GHReadme.h"
#import "GHLabels.h"
#import "GHBranches.h"
#import "GHMilestones.h"
#import "GHFMarkdown.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"



@interface GHRepository ()
@property(nonatomic,strong)GHRepository *parent;
@property(nonatomic,strong)NSMutableAttributedString *attributedDescriptionText;
@end


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

- (void)setDescriptionText:(NSString *)descriptionText {
    _attributedDescriptionText = nil;
    _descriptionText = descriptionText;
}

- (NSMutableAttributedString *)attributedDescriptionText {
    if (!_attributedDescriptionText) {
        _attributedDescriptionText = [self.descriptionText mutableAttributedStringFromGHFMarkdownWithContextRepoId:self.repoId];
    }
    return _attributedDescriptionText;
}

- (NSURL *)htmlURL {
    if (!_htmlURL) {
        self.htmlURL = [NSURL URLWithFormat:@"/%@/%@", self.owner, self.name];
    }
    return _htmlURL;
}

- (void)setOwner:(NSString *)owner andName:(NSString *)name {
	self.owner = owner;
	self.name = name;
    self.resourcePath = [NSString stringWithFormat:kRepoFormat, self.owner, self.name];
}

- (GHUser *)user {
	return [iOctocat.sharedInstance userWithLogin:self.owner];
}

#pragma mark Associations

- (GHTags *)tags {
	if (!_tags) {
		_tags = [[GHTags alloc] initWithRepository:self];
	}
	return _tags;
}

- (GHForks *)forks {
	if (!_forks) {
		_forks = [[GHForks alloc] initWithRepository:self];
	}
	return _forks;
}

- (GHMilestones *)milestones {
	if (!_milestones) {
		_milestones = [[GHMilestones alloc] initWithRepository:self];
	}
	return _milestones;
}

- (GHLabels *)labels {
	if (!_labels) {
		_labels = [[GHLabels alloc] initWithRepository:self];
	}
	return _labels;
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

- (GHUsers *)assignees {
	if (!_assignees) {
		NSString *path = [NSString stringWithFormat:kRepoAssigneesFormat, self.owner, self.name];
		_assignees = [[GHUsers alloc] initWithPath:path];
	}
	return _assignees;
}

- (GHUsers *)contributors {
	if (!_contributors) {
		NSString *path = [NSString stringWithFormat:kRepoContributorsFormat, self.owner, self.name];
		_contributors = [[GHUsers alloc] initWithPath:path];
	}
	return _contributors;
}

- (GHUsers *)stargazers {
	if (!_stargazers) {
		NSString *path = [NSString stringWithFormat:kRepoStargazersFormat, self.owner, self.name];
		_stargazers = [[GHUsers alloc] initWithPath:path];
	}
	return _stargazers;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSDictionary *repoDict = [dict safeDictForKey:@"repository"];
    NSDictionary *resource = repoDict ? repoDict : dict;
    self.htmlURL = [resource safeURLForKey:@"html_url"];
    self.homepageURL = [resource safeURLForKey:@"homepage"];
    self.descriptionText = [resource safeStringForKey:@"description"];
    self.language = [resource safeStringForKey:@"language"];
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
    // if this is a fork, parent or source should be present
    NSDictionary *parentDict = [dict safeDictForKey:@"parent"];
    if (!parentDict) parentDict = [dict safeDictForKey:@"source"];
    if (parentDict) {
        NSString *owner = [parentDict safeStringForKeyPath:@"owner.login"];
        NSString *name = [parentDict safeStringForKey:@"name"];
        self.parent = [[GHRepository alloc] initWithOwner:owner andName:name];
    }
}

#pragma mark Repo Assignment

- (void)checkAssignment:(GHUser *)user usingBlock:(void (^)(BOOL isAssignee))block {
    void(^answer)(void) = ^{
        BOOL isAssignee = [self.assignees containsObject:user];
        if (block) block(isAssignee);
    };
	if (self.assignees.isLoaded) {
        answer();
    } else {
        [self.assignees loadWithParams:nil start:NULL success:^(GHResource *instance, id data) {
            answer();
        } failure:^(GHResource *instance, NSError *error) {
            answer();
        }];
    }
}

@end